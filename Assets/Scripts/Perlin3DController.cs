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
                    float noise = Noise.perlinNoise_3D(new Vector3(x,y,z) / textureSize, cellSize, textureSize);
                    noise = (noise + 1) / 2f;
                    //Debug.Log(noise);
                    Color color = new Color(noise, noise, noise, 1);
                    texture.SetPixel(x,y,z, color);
                }
            }
        }

        texture.Apply();

        AssetDatabase.CreateAsset(texture, "Assets/Textures/Perlin3D.asset");
        Debug.Log("3D Texture created");
    }

    // Update is called once per frame
    void Update()
    {

    }
}
