using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class Perlin3DController : MonoBehaviour
{
    public ComputeShader computeShader;
    public int textureSize = 64;
    public int cellSize;

    // Start is called before the first frame update
    void Start()
    {


        Texture3D texture = new Texture3D(textureSize, textureSize, textureSize, TextureFormat.RGBA32, false);
        texture.wrapMode = TextureWrapMode.Repeat;
        texture.filterMode = FilterMode.Bilinear;

        Color[] colorArray = new Color[textureSize * textureSize * textureSize];

        for (int x = 0; x < textureSize; x++)
        {
            for (int y = 0; y < textureSize; y++)
            {
                for (int z = 0; z < textureSize; z++)
                {
                    //Original
                    // float noise = Noise.perlinNoise_3D(new Vector3(x,y,z) / textureSize, cellSize, textureSize);   
                    // noise = (noise + 1) / 2f;
                    // Color color = new Color(noise, noise, noise, 1);
                    // texture.SetPixel(x,y,z, color);

                    //FBM
                    float noise = 0;
                    noise += Noise.perlinNoise_3D(new Vector3(x,y,z) / textureSize, cellSize, textureSize);
                    noise += Noise.perlinNoise_3D(new Vector3(x,y,z) / textureSize, cellSize * 2, textureSize) * 0.5f;
                    noise += Noise.perlinNoise_3D(new Vector3(x,y,z) / textureSize, cellSize * 4, textureSize) * 0.25f;
                    noise += Noise.perlinNoise_3D(new Vector3(x,y,z) / textureSize, cellSize * 8, textureSize) * 0.125f;
                    noise += Noise.perlinNoise_3D(new Vector3(x,y,z) / textureSize, cellSize * 16, textureSize) * 0.0625f;
                    noise += Noise.perlinNoise_3D(new Vector3(x,y,z) / textureSize, cellSize * 32, textureSize) * 0.03125f;

                    noise = (noise + 1) / 2f;

                    Color color = new Color(noise, noise, noise, 1);
                    texture.SetPixel(x,y,z, color);
                }
            }
        }

        texture.Apply();

        AssetDatabase.CreateAsset(texture, "Assets/Textures/FBM_Perlin3D.asset");
        Debug.Log("3D Texture created");
    }

    // Update is called once per frame
    void Update()
    {

    }
}
