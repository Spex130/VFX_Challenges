using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[System.Serializable]
[PostProcess(typeof(PixelatePostProcessingRenderer), PostProcessEvent.AfterStack, "Stylized/Pixelate")]
public class PixelatePostProcessing : PostProcessEffectSettings
{
    public enum Target { ViewSpace, WorldSpace }

    [System.Serializable]
    public sealed class TargetParameter : ParameterOverride<Target> {}

    public TextureParameter ditherTexture = new TextureParameter { value = null };

    public TargetParameter target = new TargetParameter();
    public FloatParameter columns = new FloatParameter() { value = 64f };
    public FloatParameter rows = new FloatParameter() { value = 64f };

    public FloatParameter step1 = new FloatParameter() { value = .2f };
    public FloatParameter step2 = new FloatParameter() { value = .4f };
    public FloatParameter step3 = new FloatParameter() { value = .6f };
    public FloatParameter step4 = new FloatParameter() { value = .8f };
    public FloatParameter ditherThreshold = new FloatParameter() { value = .1f };

    public FloatParameter ditherScale = new FloatParameter() { value = 1.0f };

    public FloatParameter bwBlend = new FloatParameter() { value = 0f };
    public ColorParameter  screencolor = new ColorParameter () { value = UnityEngine.Color.black };
    public ColorParameter screencolortop = new ColorParameter () { value = UnityEngine.Color.white };
    
}

public class PixelatePostProcessingRenderer<T> : PostProcessEffectRenderer<T> where T : PixelatePostProcessing
{
    private int _ColumnsID, _RowsID, _bwBlendID, _ScreenColorID, _ScreenColorTopID, _Step1ID, _Step2ID, _Step3ID, _Step4ID, _DitherThresholdID, _DitherTextureID, _DitherScaleID;

    private Shader shader;

    public override void Init()
    {
        base.Init();
        shader = Shader.Find("Hidden/PixelatePostProcess");
        _ColumnsID = Shader.PropertyToID("_Columns");
        _RowsID = Shader.PropertyToID("_Rows");
        _Step1ID = Shader.PropertyToID("_Step1");
        _Step2ID = Shader.PropertyToID("_Step2");
        _Step3ID = Shader.PropertyToID("_Step3");
        _Step4ID = Shader.PropertyToID("_Step4");
        _bwBlendID = Shader.PropertyToID("_bwBlend");
        _ScreenColorID = Shader.PropertyToID("_ScreenColor");
        _ScreenColorTopID = Shader.PropertyToID("_ScreenColorTop");
        _DitherThresholdID = Shader.PropertyToID("_DitherThreshold");
        _DitherTextureID = Shader.PropertyToID("_DitherTex");
        _DitherScaleID = Shader.PropertyToID("_DitherScale");

    }

    public override void Render(PostProcessRenderContext context)
    {
        var cmd = context.command;
        cmd.BeginSample("Oil Paint");
        var sheet = context.propertySheets.Get(shader);

        var ditherTexture = settings.ditherTexture.value == null ? RuntimeUtilities.transparentTexture : settings.ditherTexture.value;

        settings.bwBlend.value = Mathf.Clamp(settings.bwBlend.value,0,1);

        sheet.properties.SetFloat(_ColumnsID, settings.columns);
        sheet.properties.SetFloat(_RowsID, settings.rows);
        sheet.properties.SetFloat(_bwBlendID, settings.bwBlend);

        sheet.properties.SetFloat(_Step1ID, settings.step1);
        sheet.properties.SetFloat(_Step2ID, settings.step2);
        sheet.properties.SetFloat(_Step3ID, settings.step3);
        sheet.properties.SetFloat(_Step4ID, settings.step4);
        sheet.properties.SetFloat(_DitherThresholdID, settings.ditherThreshold);
        sheet.properties.SetTexture(_DitherTextureID, ditherTexture);
        sheet.properties.SetFloat(_DitherScaleID, settings.ditherScale);


        sheet.properties.SetColor(_ScreenColorID, settings.screencolor);
        sheet.properties.SetColor(_ScreenColorTopID, settings.screencolortop);

        var pass = (int)settings.target.value;
        cmd.BlitFullscreenTriangle(context.source, context.destination, sheet, pass);

        cmd.EndSample("Oil Paint");
    }

    // public override DepthTextureMode GetCameraFlags()
    // {
    //     // if (settings == null)
    //     return DepthTextureMode.None;

    //     // return DepthTextureMode.Depth;
    //     // return base.GetCameraFlags();
    // }
}

// [System.Serializable]
// [PostProcess(typeof(PixelatePostProcessingRenderer), PostProcessEvent.AfterStack, "Stylized/Pixelate")]
// public sealed class Pixelate : PixelatePostProcessing { }

public sealed class PixelatePostProcessingRenderer : PixelatePostProcessingRenderer<PixelatePostProcessing> { }
