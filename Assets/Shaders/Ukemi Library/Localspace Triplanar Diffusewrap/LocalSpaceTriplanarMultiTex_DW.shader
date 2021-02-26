// Triplanar Shader that takes into account local coordinates - Ben Golus

Shader "Ukemi/BGolus/Localspace DiffuseWrap Triplanar (Multi-Texture)" {
Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Top Texture", 2D) = "white" {}
        _BottomTex ("Non-Top Texture", 2D) = "white" {}
        _Normal("Edge Bump/Normal Map", 2D) = "bump" {}
        _TexScale ("Texture scale", Float) = 1
        _TexScale2 ("Secondary Texture scale", Float) = 1
        _NormalScale ("Normal Map scale", Float) = 1
        _TopSpread("TopSpread", Range(-2,2)) = 1
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        [Toggle] _BlenderAngles("Use Blender Matrices", Float) = 0
    }
    SubShader {
        Tags { "RenderType"="Opaque" "DisableBatching"="True" }
        LOD 200
   
        CGPROGRAM
        #pragma surface surf WrapLambert fullforwardshadows
        #pragma target 3.0

        #include "../DiffuseWrapFunction.hlsl"

        sampler2D _MainTex, _BottomTex, _Normal;
        float _TexScale, _TexScale2, _NormalScale;
        float _TopSpread, _BlenderAngles;
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
 
            float3x3 rot;

            if(_BlenderAngles > 0)
            {
                rot = float3x3(
                    normalize(unity_WorldToObject._m10_m11_m12),
                    normalize(unity_WorldToObject._m20_m21_m22),
                    normalize(unity_WorldToObject._m00_m01_m02)
                    );
            }
            else{
                rot = float3x3(
                    normalize(unity_WorldToObject._m00_m01_m02),
                    normalize(unity_WorldToObject._m10_m11_m12),
                    normalize(unity_WorldToObject._m20_m21_m22)
                    );
            }
            // get unscaled rotation from matrix

            // make box mapping with rotation preserved
            float3 map = mul(rot, IN.worldPos) + pos;
            float3 norm = mul(rot, IN.worldNormal);
 
            float3 blend = abs(norm) / dot(abs(norm), float3(1,1,1));

            // normal noise triplanar for x, y, z sides
            float3 xn = tex2D(_Normal, map.zy * (1/_NormalScale));
            float3 yn = tex2D(_Normal, map.zx * (1/_NormalScale));
            float3 zn = tex2D(_Normal, map.xy * (1/_NormalScale));

            // lerped together all sides for noise texture
            float3 noisetexture = zn;
            noisetexture = lerp(noisetexture, xn, blend.x);
            noisetexture = lerp(noisetexture, yn, blend.y);

            // triplanar for top texture for x, y, z sides
            float3 xm = tex2D(_MainTex, map.zy * (1/_TexScale));
            float3 zm = tex2D(_MainTex, map.xy * (1/_TexScale));
            float3 ym = tex2D(_MainTex, map.zx * (1/_TexScale));

            // lerped together all sides for top texture
            float3 toptexture = zm;
            toptexture = lerp(toptexture, xm, blend.x);
            toptexture = lerp(toptexture, ym, blend.y);

            // triplanar for side and bottom texture, x,y,z sides
            float3 x = tex2D(_BottomTex, map.zy * (1/_TexScale2));
            float3 y = tex2D(_BottomTex, map.zx * (1/_TexScale2));
            float3 z = tex2D(_BottomTex, map.xy * (1/_TexScale2));

            // lerped together all sides for side bottom texture
            float3 sidetexture = z;
            sidetexture = lerp(sidetexture, x, blend.x);
            sidetexture = lerp(sidetexture, y, blend.y);

            // dot product of world normal and surface normal + noise
		    float worldNormalDotNoise = dot(norm + (noisetexture.y + (noisetexture * 0.5)), blend.y);


            // if dot product is higher than the top spread slider, multiplied by triplanar mapped top texture
            // step is replacing an if statement to avoid branching :
            // if (worldNormalDotNoise > _TopSpread{ o.Albedo = toptexture}
            float3 topTextureResult = step(_TopSpread, worldNormalDotNoise) * toptexture;

            // if dot product is lower than the top spread slider, multiplied by triplanar mapped side/bottom texture
            float3 sideTextureResult = step(worldNormalDotNoise, _TopSpread) * sidetexture;

            // if dot product is in between the two, make the texture darker
            //float3 topTextureEdgeResult = step(_TopSpread, worldNormalDotNoise) * step(worldNormalDotNoise, _TopSpread + _EdgeWidth) *  -0.15;


            o.Albedo = (topTextureResult + sideTextureResult) * _Color;
            //o.Normal += normalize(n);
 
            // Metallic and smoothness come from slider variables
            //o.Metallic = _Metallic;
            //o.Smoothness = _Glossiness;
            //o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}