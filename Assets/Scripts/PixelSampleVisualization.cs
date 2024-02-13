using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class PixelSampleVisualization : MonoBehaviour
{
    public Material activeSampleMat;
    public Material unactiveSampleMat;

    public GameObject pixelSamplePos;
    public GameObject pixelSamplePath;

    GameObject currentPixel;
    Vector2 initialPixelPos;
    Vector2 currentPixelPos;
    int frame;
    public int numSamples = 8;

    public enum OffsetType {
        GoldenRatio,
        Uniform,
        GoldenRatioWithUniform,
        BlueNoise,
        WhiteNoise,
    };
    public OffsetType offsetType = OffsetType.GoldenRatio;

    const float GoldenRatio = 1.61803398875f;

    public Texture2D blueNoiseTexture;

    // Start is called before the first frame update
    void Start()
    {
        frame = Random.Range(0, 100);
        Color blueNosieSample = blueNoiseTexture.GetPixel(frame, 0);

        float x = blueNosieSample.r;
        float y = blueNosieSample.g;
        initialPixelPos = new Vector2(x, y);

        currentPixel = Instantiate(pixelSamplePos, new Vector3(initialPixelPos.x, initialPixelPos.y, 0), Quaternion.identity);
        currentPixel.GetComponent<Renderer>().material = activeSampleMat;
    }

    Vector2 fract(Vector2 v){
        return new Vector2(v.x - Mathf.Floor(v.x), v.y - Mathf.Floor(v.y));
    }

    void UpdatePixelOffset(){
        if(offsetType == OffsetType.GoldenRatio){
            currentPixelPos.x = initialPixelPos.x + (frame % numSamples) * GoldenRatio;
            currentPixelPos.y = initialPixelPos.y + (frame % numSamples) * GoldenRatio;
        }
        else if(offsetType == OffsetType.Uniform){
            currentPixelPos.x = initialPixelPos.x + (float)(frame % numSamples) / (float)numSamples;
            currentPixelPos.y = initialPixelPos.y + (float)(frame % numSamples) / (float)numSamples;
        }
        else if(offsetType == OffsetType.GoldenRatioWithUniform){
            currentPixelPos.x = initialPixelPos.x + (frame % numSamples) * 0.1f;
            currentPixelPos.y = initialPixelPos.y + (float)(frame % numSamples) / (float)numSamples;
        }
        else if(offsetType == OffsetType.BlueNoise){
            Color blueNosieSample = blueNoiseTexture.GetPixel(0, frame);
            currentPixelPos.x = initialPixelPos.x + blueNosieSample.r;
            currentPixelPos.y = initialPixelPos.y + blueNosieSample.g;
        }
        else if(offsetType == OffsetType.WhiteNoise){
            currentPixelPos.x = initialPixelPos.x + Random.value;
            currentPixelPos.y = initialPixelPos.y + Random.value;
        }
        currentPixelPos = fract(currentPixelPos);
        //Debug.Log("Current Pixel Pos: " + currentPixelPos);
    }

    void GetNextPixel(){
        currentPixel.GetComponent<Renderer>().material = unactiveSampleMat;
        frame++;
        UpdatePixelOffset();

        currentPixel = Instantiate(pixelSamplePos, new Vector3(currentPixelPos.x, currentPixelPos.y, 0), Quaternion.identity);
        currentPixel.GetComponent<Renderer>().material = activeSampleMat;
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKeyDown(KeyCode.Space)){
            GetNextPixel();
        }
    }
}
