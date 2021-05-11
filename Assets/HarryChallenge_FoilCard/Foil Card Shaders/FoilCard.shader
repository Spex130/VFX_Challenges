Shader "Spex130/CardChallenge/FoilCard"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _TransparencyGuide("Transparency Guide Texture (R)", 2D) = "white" {}
        _HoloColor("Holographic Color Gradient (L/R)", 2D) = "white" {}
        _Holo("Holographic Distortion Pattern (BW)", 2D) = "white" {}
        _HoloMod("Holographic Size Modifier", Range(0, 10)) = 1
        _HoloPower("Holographic Power", Range(0, 3)) = 1
        _CutoffThres("Cutoff Threshold", Range(0, .5)) = 0.0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float4 tangent : TANGENT;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 viewDir : TEXCOORD2;
                float4 objPos : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _TransparencyGuide;
            sampler2D _Holo;
            sampler2D _HoloColor;
            float _HoloMod;
            float _CutoffThres;
            float _HoloPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float4 objCam = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0));
                float3 viewDir = v.vertex.xyz - objCam.xyz;
                float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                float3 bitangent = cross(v.normal.xyz, v.tangent.xyz) * tangentSign;
                o.viewDir = float4(
                    dot(viewDir, v.tangent.xyz),
                    dot(viewDir, bitangent.xyz),
                    dot(viewDir, v.normal.xyz), 
                    1
                );
                o.objPos = mul(unity_ObjectToWorld, v.vertex);;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 holoDistort = tex2D(_Holo, (i.objPos+i.viewDir).xy  * _HoloMod); //(i.objPos+i.viewDir).xy //i.viewDir.xy * _HoloMod
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 holoColor = tex2D(_HoloColor, holoDistort);
                fixed4 transparency = tex2D(_TransparencyGuide, i.uv);
                clip((1-transparency.r) - _CutoffThres);

                float4 nViewDir = i.viewDir * -1;//Negate ViewDir

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return lerp(col, holoColor * col, .5) * _HoloPower;
            }
            ENDCG
        }
    }
}
