Shader "Ukemi/CloudCover/CloudCover (TexturedNoise)"
{
	Properties
	{
        _Color1 ("Color Height", Color) = (1,1,1,1)
        _Color2 ("Color Depth", Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white" {}
		_NoiseTex("Wave Noise 1", 2D) = "white" {}
		_Speed("Wave Speed", Range(0,1)) = 0.5
		_Amount("Wave Amount", Range(0,1)) = 0.5
		_Height("Wave Height", Range(-1,1)) = 0
		_Foam("Cloud Depth Thickness", Range(0,1)) = 0.1
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _NoiseScale("Noise Scale", Float) = 10
        _ScrollSpeed("Scroll Speed", Float) = 1
        _ScrollSpeed2("Scroll Speed 2", Float) = 1
        _CloudPower("Cloud Power", Float) = 1
        _Brightness("Cloud Brightness", Range(.1, 2)) = 1
		
	}
	SubShader
	{
		Tags { "RenderType"="Opaque"  "Queue" = "Transparent" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv: TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 scrPos : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            float4 _Color1;
            fixed4 _Color2;
            uniform sampler2D _CameraDepthTexture; //Depth Texture
            sampler2D _MainTex, _NoiseTex;//
            float4 _MainTex_ST;
            float _Speed, _Amount, _Height, _Foam;
            float _NoiseScale, _ScrollSpeed, _ScrollSpeed2, _CloudPower, _Brightness;
            float noiseVar; 
			
            float Unity_Remap_float(float4 In, float2 InMinMax, float2 OutMinMax)
            {
                float Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                return Out;
            }

			v2f vert (appdata v)
			{
				v2f o;
                float4 tex = tex2Dlod(_MainTex, float4((v.uv.xy + _Time.x * _ScrollSpeed)/_NoiseScale, 0, 0));
                float4 noiseTex = tex2Dlod(_NoiseTex, float4((v.uv.xy + _Time.x * _ScrollSpeed2)/_NoiseScale, 0, 0));
                o.worldPos = mul (unity_ObjectToWorld, v.vertex).xyz;
                v.vertex.xyz += v.normal * ((tex + noiseTex) * _CloudPower) + _Height;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.scrPos = ComputeScreenPos(o.vertex);
                return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
			
				half4 c = tex2D(_MainTex, (i.uv + _Time.x * _ScrollSpeed)/_NoiseScale);
                half4 n = tex2D(_NoiseTex, (i.uv + _Time.x * _ScrollSpeed2)/_NoiseScale);
                c = c+n;
                c = Unity_Remap_float(c, float2(0,1), float2(-1,1));
                half depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos))); // depth
				half4 depthLine =1 - saturate(_Foam * (depth - i.scrPos.w));// foam line by comparing depth and screenposition
				c = lerp(_Color2, _Color1, c) + (lerp(_Color2, _Color1, c) * _Brightness);

                c.a = 1- depthLine;
                return c ;
			}
			ENDCG
		}
	}
}