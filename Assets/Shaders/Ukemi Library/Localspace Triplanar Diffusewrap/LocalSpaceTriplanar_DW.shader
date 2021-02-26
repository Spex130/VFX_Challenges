// Triplanar Shader that takes into account local coordinates - Ben Golus

Shader "Ukemi/BGolus/Localspace DiffuseWrap Triplanar" {
Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [NoScaleOffset] _NormalMap1("Normal Map", 2D) = "bump" {}
        [NoScaleOffset] _NormalMap2("Secondary Normal Map", 2D) = "bump" {}
        _TexScale ("Texture scale", Float) = 1
        _TexScale2 ("Secondary Normal Map scale", Float) = 1
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" "DisableBatching"="True" }
        LOD 200
   
        CGPROGRAM
        #pragma surface surf WrapLambert fullforwardshadows
        #pragma target 3.0

        #include "../DiffuseWrapFunction.hlsl"

        sampler2D _MainTex;
        sampler2D _NormalMap1;
        sampler2D _NormalMap2;
        float _TexScale;
        float _TexScale2;
        struct Input {
            float3 worldPos;
            float3 worldNormal;
            INTERNAL_DATA
        };
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        void surf (Input IN, inout SurfaceOutput o) {
 
            // get scale from matrix
            float3 scale = float3(
                length(unity_WorldToObject._m00_m01_m02),
                length(unity_WorldToObject._m10_m11_m12),
                length(unity_WorldToObject._m20_m21_m22)
                );
 
            // get translation from matrix
            float3 pos = unity_WorldToObject._m03_m13_m23 / scale;
 
            // get unscaled rotation from matrix
            float3x3 rot = float3x3(
                normalize(unity_WorldToObject._m00_m01_m02),
                normalize(unity_WorldToObject._m10_m11_m12),
                normalize(unity_WorldToObject._m20_m21_m22)
                );
            // make box mapping with rotation preserved
            float3 map = mul(rot, IN.worldPos) + pos;
            float3 norm = mul(rot, IN.worldNormal);
 
            float3 blend = abs(norm) / dot(abs(norm), float3(1,1,1));
            float2 uv;
            if (blend.x > max(blend.y, blend.z)) {
                uv = map.yz;
            } else if (blend.z > blend.y) {
                uv = map.xy;
            } else {
                uv = map.xz;
            }
            fixed4 c = tex2D(_MainTex, uv * (1/_TexScale));
            o.Albedo = c.rgb * _Color;

            half3 n = UnpackNormal(tex2D(_NormalMap1, uv * (1/_TexScale)));
            half3 n2 = UnpackNormal(tex2D(_NormalMap2, uv * (1/_TexScale2)));
            n = BlendNormals(n, n2);
            o.Albedo = c.rgb * _Color;
            //o.Normal += normalize(n);
 
            // Metallic and smoothness come from slider variables
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}