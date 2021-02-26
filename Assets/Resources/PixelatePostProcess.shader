Shader "Hidden/PixelatePostProcess"
{
    HLSLINCLUDE

    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    TEXTURE2D_SAMPLER2D(_DitherTex, sampler_DitherTex);

    uniform float _Columns;
    uniform float _Rows;
    uniform float _bwBlend = 1;

    uniform float _Step1 = .2f;
    uniform float _Step2 = .4f;
    uniform float _Step3 = .6f;
    uniform float _Step4 = .8f;
    uniform float _DitherThreshold = .1f;
    uniform float _DitherScale = 1.0f;

    float4 _ScreenColor = float4(0.2,0.2,0.8,1);
    float4 _ScreenColorTop = float4(0.2,0.2,0.8,1);

    struct vertInput
    {
        float4 vertex : POSITION;
    };

    struct Varyings {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
        float4 screenPosition : TEXCOORD1;
    };

    float4 frag (Varyings i) : SV_Target
    {
        float2 uv = i.uv;
        uv.x *= _Columns;
        uv.y *= _Rows;
        uv.x = round(uv.x);
        uv.y = round(uv.y);
        uv.x /= _Columns;
        uv.y /= _Rows;

        float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);

        float lum = col.r*.3 + col.g*.59 + col.b*.11;
        float4 bw = float4( lum, lum, lum, 1); 
        
        float texColor = col.r;

        //value from the dither pattern
        float2 screenPos = i.screenPosition.xy / i.screenPosition.w;
        float aspect = _ScreenParams.x / _ScreenParams.y;
        screenPos.x = screenPos.x * aspect;
        //uv = uv * aspect * 1000000.0f;
        float2 fixedDitherUV = float2(i.uv.x * aspect, i.uv.y);
        float4 ditherTex = SAMPLE_TEXTURE2D(_DitherTex, sampler_DitherTex, fixedDitherUV * _DitherScale);

        float2 ditherCoordinate = screenPos * _ScreenParams.xy * ditherTex.xy;
        float ditherValue = ditherTex.r;

        //combine dither pattern with texture value to get final result
        float ditheredValue = step(ditherValue, texColor);
        float4 colo = lerp(_ScreenColor, _ScreenColorTop, ditheredValue);

        if(bw.r < _Step1)
        {
            bw = _ScreenColor * .5;
        }
        else if(bw.r >= _Step1 && bw.r < _Step2)
        {
            bw = _ScreenColor;
        }
        else if(bw.r >= _Step2 && bw.r < _Step3)
        {
            bw = lerp(_ScreenColor, _ScreenColorTop, _Step1);  
        }
        else if(bw.r >= _Step3 && bw.r < _Step4)
        {
            bw = lerp(_ScreenColor, _ScreenColorTop, _Step2); 
        }
        else if(bw.r >= _Step4 && bw.r < .9f)
        {
            bw = lerp(_ScreenColor, _ScreenColorTop, _Step3);
            //bw = lerp(_ScreenColor, _ScreenColorTop, .8);
        }
        else{
            bw = _ScreenColorTop;
        }



        if(lum.r > (_Step1 - _DitherThreshold) && lum.r <= _Step1)
        {

            bw = bw * colo;
        }
        else if(lum.r < (_Step1 + _DitherThreshold) && lum.r > _Step1)
        {
            bw = bw * colo;
        }
        else if(lum.r > (_Step2 - _DitherThreshold) && lum.r <= (_Step2 + _DitherThreshold))
        {
            if(ditherTex.r == 1)
            {
                bw = _ScreenColor;
            }
            else
            {
                bw = lerp(_ScreenColor, _ScreenColorTop, _Step1); 
            }
            //bw = ditherTex;
        }
        else if(lum.r > (_Step3 - _DitherThreshold) && lum.r <= (_Step3 + _DitherThreshold))
        {
            if(ditherTex.r == 1)
            {
                bw = lerp(_ScreenColor, _ScreenColorTop, _Step1); 
            }
            else
            {
                bw = lerp(_ScreenColor, _ScreenColorTop, _Step2);  
            }
        } 
        else if(lum.r > (_Step4 - _DitherThreshold) && lum.r <= (_Step4 + _DitherThreshold))
        {
            if(ditherTex.r == 1)
            {
                bw = lerp(_ScreenColor, _ScreenColorTop, _Step2); 
            }
            else
            {
                bw = lerp(_ScreenColor, _ScreenColorTop, _Step3);  
            }
        } 
//**/

        return bw;
    }

    ENDHLSL


    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM
            #pragma vertex VertDefault
            #pragma fragment frag
            ENDHLSL
        }
    }
}
