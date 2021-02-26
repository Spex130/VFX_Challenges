Shader "HarryChallenge/LoadingScreen/ThrusterShader"
{
    Properties
    {
        _Color("Main Color", Color) = (0.5,0.5,0.5,1)
        _MainTex ("Texture 1", 2D) = "white" {}
        _SecondTex("Texture 2", 2D) = "white" {}
        _AlphaStart("Alpha Start Height", range(0,1)) = 0
        _AlphaPow("Alpha Power", range(0,2)) = 1
        _ScrollSpeed("Scroll Speed", float) = 1
         _ColorBoost("Color Boost", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        Cull Off
        ZWrite Off
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD2;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _SecondTex;
            float4 _SecondTex_ST;
            float _AlphaStart, _AlphaPow, _ScrollSpeed, _ColorBoost;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.uv, _SecondTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 dist = tex2D(_SecondTex, i.uv2);
                
                fixed4 col = tex2D(_MainTex, float2(i.uv.x + dist.r, i.uv.y - _Time.x*_ScrollSpeed)) * pow(max(0, 1-i.uv.y - _AlphaStart), _AlphaPow) + _ColorBoost;
                col.a = col.r - _ColorBoost;// *(1 - i.uv.y - _AlphaStart);
                col *= _Color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
