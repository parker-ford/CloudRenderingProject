using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class ApplyGeneralImageEffectShader : MonoBehaviour
{
    public Shader imageEffect;
    private Material material;

    void Start()
    {
        Debug.Assert(imageEffect != null);

        material = new Material(imageEffect)
        {
            hideFlags = HideFlags.HideAndDontSave
        };
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination){
        if(material != null){
            Graphics.Blit(source, destination, material);
        }
        else{
            Graphics.Blit(source,destination);
            Debug.LogError("Image effect material is null");
        }
    }
}
