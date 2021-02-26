Shader "Unlit/ScreenspaceCurvature"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Tint", Color) = (0, 0, 0, 1)
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = v.normal;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                /*
                vec3 n = normalize(normal);

                // Compute curvature
                vec3 dx = dFdx(n);
                vec3 dy = dFdy(n);
                vec3 xneg = n - dx;
                vec3 xpos = n + dx;
                vec3 yneg = n - dy;
                vec3 ypos = n + dy;
                float depth = length(vertex);
                float curvature = (cross(xneg, xpos).y - cross(yneg, ypos).x) * 4.0 / depth;

                // Compute surface properties
                vec3 light = vec3(0,0,0);
                vec3 ambient = vec3(curvature + 0.5);
                vec3 diffuse = vec3(0,0,0);
                vec3 specular = vec3(0,0,0);
                float shininess = 0.0;

                // Compute final color
                float cosAngle = dot(n, light);
                gl_FragColor.rgb = ambient + diffuse * max(0.0, cosAngle) + specular * pow(max(0.0, cosAngle), shininess);
                */

                // sample the texture
                fixed4 col = fixed4(i.normal.x,  i.normal.y,  i.normal.z, 1);
                fixed4 n = normalize(col);
                fixed4 dx = ddx(n);
                fixed4 dy = ddy(n);
                fixed4 xneg = n - dx;
                fixed4 xpos = n + dx;
                fixed4 yneg = n - dy;
                fixed4 ypos = n + dy;
                float depth = length(i.vertex);
                float curvature = (cross(xneg, xpos).y - cross(yneg, ypos).x) * 4.0 / depth;

                fixed4 light = fixed4(0,0,0,0);
                fixed4 ambient = fixed4(curvature + 0.5, curvature + 0.5, curvature + 0.5, curvature + 0.5);
                fixed4 diffuse = fixed4(0,0,0,0);
                fixed4 specular = fixed4(0,0,0,0);
                float shininess = 0.0;

                float cosAngle = dot(n, light);
                fixed4 fin = ambient + diffuse * max(0.0, cosAngle) + specular * pow(max(0.0, cosAngle), shininess);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, fin);
                return col;
            }
            ENDCG
        }
    }
}
