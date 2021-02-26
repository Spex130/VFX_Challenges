using System.Collections;
using System.Collections.Generic;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine;

public class PostProcessVolumeValidator : MonoBehaviour
{
    private void Start()
    {
        PostProcessProfile loadedProfile = Resources.Load<PostProcessProfile>("Cool2");
        GetComponent<PostProcessVolume>().profile = loadedProfile;
        Debug.Log("Loaded profile: " + loadedProfile);
        // PostProcessProfile profile =  GetComponent<PostProcessVolume>().profile;
        // Debug.Log("Profile Exists: " + profile != null);
        // Debug.Log("ColorTOp: " + profile.GetSetting<PixelatePostProcessing>().screencolortop.value.ToString());
    }
}
