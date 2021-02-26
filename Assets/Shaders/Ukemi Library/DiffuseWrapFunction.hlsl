
half4 LightingWrapLambert (SurfaceOutput s, half3 lightDir, half atten) {
  half NdotL = dot (s.Normal, lightDir);
  half diff = NdotL * 0.5 + 0.5;
  half4 c;
  c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten);
  c.a = s.Alpha;
  return c;
}
