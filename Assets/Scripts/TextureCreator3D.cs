using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;

public class TextureCreator3D : MonoBehaviour
{
    // Start is called before the first frame update
    public struct Pixel {
        public Color color;
    }
    private Pixel[] pixels;

    public String textureName;

    public ComputeShader computeShader;

    public int resolution;

    void Start()
    {
        createPixelArray();
        fillPixelBuffer();
        pixelArrayTo3DTexture();
    }

    private void createPixelArray(){
        pixels = new Pixel[resolution * resolution * resolution];
        for(int i = 0; i < pixels.Length; i++){
            pixels[i].color = Color.black;
        }
    }

    private void fillPixelBuffer(){
        ComputeBuffer pixelBuffer = new ComputeBuffer(pixels.Length, sizeof(float) * 4);
        pixelBuffer.SetData(pixels);
        computeShader.SetBuffer(0, "pixels", pixelBuffer);
        computeShader.SetFloat("resolution", resolution);
        computeShader.Dispatch(0, resolution, resolution, resolution);
        pixelBuffer.GetData(pixels);
        pixelBuffer.Dispose();
    }

    private void pixelArrayTo3DTexture(){
        Texture3D texture = new Texture3D(resolution, resolution, resolution, TextureFormat.RGBA32, false);
        for(int x = 0; x < resolution; x++){
            for(int y = 0; y < resolution; y++){
                for(int z = 0; z < resolution; z++){
                    texture.SetPixel(x,y,z, pixels[x + y * resolution + z * resolution * resolution].color);
                }
            }
        }
        texture.Apply();

    string dateTimeString = System.DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss");
        string folderPath = Application.dataPath + "/Textures/" + textureName;
        System.IO.Directory.CreateDirectory(folderPath);

        AssetDatabase.CreateAsset(texture, "Assets/Textures/" + textureName + "/"  + textureName + "_" + dateTimeString + ".asset" );
        Debug.Log("3D Texture created");
    }
}
