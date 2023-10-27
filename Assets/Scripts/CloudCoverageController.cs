using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CloudCoverageController : MonoBehaviour
{
    public Shader imageEffect;
    private Material material;
    private RenderTexture currentTexture;

    void Start()
    {
        Debug.Assert(imageEffect != null);

        material = new Material(imageEffect)
        {
            hideFlags = HideFlags.HideAndDontSave
        };
        Debug.Log(Screen.width + " " + Screen.height);
        currentTexture =  new RenderTexture(Screen.width, Screen.height, 16, RenderTextureFormat.ARGB32);
        currentTexture.Create();
        
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination){
        if(material != null){
            Graphics.Blit(source, destination, material);
            Graphics.Blit(destination, currentTexture);
            // if(currentTexture != null){
            //     Debug.Log("currentTexture is not null");
            // }
            // else{
            //     Debug.Log("currentTexture is null");
            // }
        }
        else{
            Graphics.Blit(source,destination);
            Debug.LogError("Image effect material is null");
        }
    }

    public void SaveCurrentTexture(){

        if(currentTexture != null){
            Texture2D texture2D = new Texture2D(currentTexture.width, currentTexture.height);
            RenderTexture.active = currentTexture;
            texture2D.ReadPixels(new Rect(0, 0, currentTexture.width, currentTexture.height), 0, 0);
            texture2D.Apply();

            byte[] bytes = texture2D.EncodeToPNG();
            System.IO.File.WriteAllBytes(Application.dataPath + "/CloudCoverage.png", bytes);
            Debug.Log("Saved current Texture");

        } 
        else{
            Debug.Log("test");
        }
    }


}
