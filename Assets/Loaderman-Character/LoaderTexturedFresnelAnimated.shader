Shader "HarryChallenge/Fresnel/LoaderTexturedFresnelAnimated" {
	//show values to edit in inspector
	Properties{
		_Color("Tint", Color) = (0, 0, 0, 1)
		_MainTex("Monochromatic Texture", 2D) = "white" {}
		_TexBright("Texture Brightness", Range(0, 10)) = 0
		_Smoothness("Smoothness", Range(0, 1)) = 0
		_Metallic("Metalness", Range(0, 1)) = 0
		_Emission("Emission", Range(0, 1)) = 0
		_TimeScale("Scroll Speed", Range(-10, 10)) = 1
		_FresnelColor("Fresnel Color", Color) = (1,1,1,1)
		[PowerSlider(4)] _FresnelExponent("Fresnel Exponent", Range(0.25, 8)) = 1
		_FresnelAdditive("Fresnel Additive", Float) = 1
	}
		SubShader{
			//the material is completely non-transparent and is rendered at the same time as the other opaque geometry
			Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
			LOD 100
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM

			//the shader is a surface shader, meaning that it will be extended by unity in the background to have fancy lighting and other features
			//our surface shader function is called surf and we use the standard lighting model, which means PBR lighting
			//fullforwardshadows makes sure unity adds the shadow passes the shader might need
			#pragma surface surf Standard fullforwardshadows alpha
			#pragma target 3.0

			sampler2D _MainTex;
			fixed4 _Color;

			half _Smoothness;
			half _TexBright;
			half _Metallic;
			half _Emission;
			half _TimeScale;

			float3 _FresnelColor;
			float _FresnelExponent;
			float _FresnelAdditive;

			//input struct which is automatically filled by unity
			struct Input {
				float2 uv_MainTex;
				float3 worldNormal;
				float3 viewDir;
				INTERNAL_DATA
			};

			//the surface shader function which sets parameters the lighting function then uses
			void surf(Input i, inout SurfaceOutputStandard o) {
				//sample and tint albedo texture
				fixed4 col = tex2D(_MainTex, i.uv_MainTex + _Time.x * _TimeScale);
				col *= _Color;
				o.Albedo = col.r + _TexBright;
				 
				//just apply the values for metalness and smoothness
				o.Metallic = _Metallic;
				o.Smoothness = _Smoothness;

				//get the dot product between the normal and the view direction
				float fresnel = dot(i.worldNormal, i.viewDir);
				//invert the fresnel so the big values are on the outside
				fresnel = saturate(1 - fresnel);
				//raise the fresnel value to the exponents power to be able to adjust it
				fresnel = pow(fresnel, _FresnelExponent) * _FresnelAdditive;
				//combine the fresnel value with a color
				float3 fresnelColor = fresnel * _FresnelColor;
				//apply the fresnel value to the emission
				o.Emission = _Emission * (col.r + _TexBright)* col.a + fresnelColor* _Emission;
				o.Alpha = col.a;
			}
			ENDCG
		}
			FallBack "Standard"
}

