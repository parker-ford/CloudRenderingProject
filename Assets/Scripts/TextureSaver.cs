using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextureSaver : MonoBehaviour {

    public string textureName;
    public Material imageEffect;
    private RenderTexture currentTexture;
    private int finalTextureSize = 1024;

    void Start()
    {
        currentTexture =  new RenderTexture(Screen.width, Screen.height, 16, RenderTextureFormat.ARGB32);
        currentTexture.Create();
        
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination){
        if(imageEffect != null){
            Graphics.Blit(source, destination, imageEffect);
            Graphics.Blit(destination, currentTexture);
        }
        else{
            Graphics.Blit(source,destination);
            Debug.LogError("Image effect material is null");
        }//
    }

    public void SaveCurrentTexture(){

        if(currentTexture != null){
            Texture2D texture2D = new Texture2D(currentTexture.width, currentTexture.height);
            RenderTexture.active = currentTexture;
            texture2D.ReadPixels(new Rect(0, 0, currentTexture.width, currentTexture.height), 0, 0);
            texture2D.Apply();

            Texture2D finalTexture = new Texture2D(finalTextureSize, finalTextureSize, TextureFormat.RGBA32, false);
            for(int y = 0; y < finalTexture.height; y++){
                for(int x = 0; x < finalTexture.width; x++){
                    float invertedY = 1f - (float)y / finalTexture.height;
                    Color color = texture2D.GetPixelBilinear((float)x / finalTexture.width, invertedY);
                    finalTexture.SetPixel(x,y,color);
                }
            }
            finalTexture.Apply();

            byte[] bytes = finalTexture.EncodeToPNG();
            string dateTimeString = System.DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss");

            string folderPath = Application.dataPath + "/Textures/" + textureName;
            System.IO.Directory.CreateDirectory(folderPath);

            System.IO.File.WriteAllBytes(folderPath + "/" + textureName + "_" + dateTimeString + ".png", bytes);
            Debug.Log("Saved current Texture");

        } 
        else{
            Debug.LogError("Current Texture is null");
        }
    }
}