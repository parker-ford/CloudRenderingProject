using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class TextureCreator3D : MonoBehaviour
{
    // Start is called before the first frame update
    public struct Pixel {
        public Color color;
    }
    private Pixel[] pixels;


    public ComputeShader computeShader;

    public int resolution;

    void Start()
    {
        createPixelArray();
        fillPixelBuffer();
        pixelArrayTo3DTexture();

        // RenderTexture renderTexture = new RenderTexture(resolution, resolution, resolution, RenderTextureFormat.ARGB32);
        // renderTexture.dimension = UnityEngine.Rendering.TextureDimension.Tex3D;
        // renderTexture.volumeDepth = resolution;
        // renderTexture.enableRandomWrite = true;
        // renderTexture.Create();

        // computeShader.SetTexture(0, "Result", renderTexture);

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
        AssetDatabase.CreateAsset(texture, "Assets/Textures/TestTexture3D.asset");
        Debug.Log("3D Texture created");
    }
}
