using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PixelSampleVisualization : MonoBehaviour
{
    public AnalysisPanelController analysisPanelController;
    public Material activeSampleMat;
    public Material unactiveSampleMat;

    public GameObject pixelSamplePos;
    public GameObject pixelSamplePath;

    GameObject currentPixel;
    public int numSamples = 8;

    public enum OffsetType {
        GoldenRatio,
        Uniform,
        GoldenRatioWithUniform,
        BlueNoise,
        WhiteNoise,
        N_Rooks,
    };
    public OffsetType offsetType = OffsetType.GoldenRatio;

    const float GoldenRatio = 1.61803398875f;

    public Texture2D blueNoiseTexture;

    private List<GameObject> controlSamples = new List<GameObject>();
    private List<GameObject> testSamples = new List<GameObject>();

    public bool recalculate = false;

    public List<int> rookPositions = new List<int>();

    // Start is called before the first frame update
    void Start()
    {
        // frame = Random.Range(0, 100);
        // Color blueNosieSample = blueNoiseTexture.GetPixel(frame, 0);

        // float x = blueNosieSample.r;
        // float y = blueNosieSample.g;
        // initialPixelPos = new Vector2(x, y);

        // currentPixel = Instantiate(pixelSamplePos, new Vector3(initialPixelPos.x, initialPixelPos.y, 0), Quaternion.identity);
        // currentPixel.GetComponent<Renderer>().material = activeSampleMat;
        //GenerateBaselineSamples();
        GenerateRookPositions();
        AnalyzePoints();
    }

    void GenerateRookPositions(){
        rookPositions.Clear();
        for(int i = 0; i < numSamples; i++){
            rookPositions.Add(i);
        }

        System.Random rng = new System.Random();
        int n = rookPositions.Count;
        while(n > 1){
            n--;
            int k = rng.Next(n + 1);
            int value = rookPositions[k];
            rookPositions[k] = rookPositions[n];
            rookPositions[n] = value;
        }
    }

    void AnalyzePoints(){
        ClearSamples();
        GenerateBaselineSamples();
        GenerateTestSamples();
        PerformChiSquareTest();
        PerformAverageNearestNeighbor();
    }

    void ClearSamples(){
        foreach(GameObject sample in controlSamples){
            Destroy(sample);
        }
        controlSamples.Clear();

        foreach(GameObject sample in testSamples){
            Destroy(sample);
        }
        testSamples.Clear();
    }

    void GenerateBaselineSamples(){
        int gridSize = (int)Mathf.Sqrt(numSamples);
        for(int i = 0; i < gridSize; i++){
            for(int j = 0; j < gridSize; j++){
                float x = (float)i / (float)gridSize + 0.5f / (float)gridSize;
                float y = (float)j / (float)gridSize + 0.5f / (float)gridSize;
                GameObject sample = Instantiate(pixelSamplePos, new Vector3(x, y, 0), Quaternion.identity);
                sample.GetComponent<Renderer>().material = unactiveSampleMat;
                controlSamples.Add(sample);
            }
        }
    }

    void GenerateTestSamples(){
        int frame = UnityEngine.Random.Range(0, 100);
        Color blueNosieSample = blueNoiseTexture.GetPixel(frame, 0);
        float x = blueNosieSample.r;
        float y = blueNosieSample.g;
        Vector2 initialPixelPos = new Vector2(x, y);

        GameObject initSample = Instantiate(pixelSamplePos, new Vector3(initialPixelPos.x, initialPixelPos.y, 0), Quaternion.identity);
        initSample.GetComponent<Renderer>().material = activeSampleMat;
        testSamples.Add(initSample);

        for(int i = 1; i < numSamples; i++){
            Vector2 pos = GetSamplePixelPosition(initialPixelPos, i + frame);
            GameObject sample = Instantiate(pixelSamplePos, new Vector3(pos.x, pos.y, 0), Quaternion.identity);
            sample.GetComponent<Renderer>().material = activeSampleMat;
            testSamples.Add(sample);
        }
    }

    Vector2 GetSamplePixelPosition(Vector2 initialPixelPos, int frame){
       Vector2 pos = new Vector2();

        if(offsetType == OffsetType.GoldenRatio){
            pos.x = initialPixelPos.x + frame * GoldenRatio;
            pos.y = initialPixelPos.y + frame * GoldenRatio;
        }
        else if(offsetType == OffsetType.Uniform){
            pos.x = initialPixelPos.x + (float)(frame) / (float)numSamples;
            pos.y = initialPixelPos.y + (float)(frame) / (float)numSamples;
        }
        else if(offsetType == OffsetType.GoldenRatioWithUniform){
            pos.x = initialPixelPos.x + (frame) * 0.1f;
            pos.y = initialPixelPos.y + (frame) / (float)numSamples;
        }
        else if(offsetType == OffsetType.BlueNoise){
            Color blueNosieSample = blueNoiseTexture.GetPixel(0, frame);
            pos.x = initialPixelPos.x + blueNosieSample.r;
            pos.y = initialPixelPos.y + blueNosieSample.g;
        }
        else if(offsetType == OffsetType.WhiteNoise){
            pos.x = initialPixelPos.x + UnityEngine.Random.value;
            pos.y = initialPixelPos.y + UnityEngine.Random.value;
        }
        else if(offsetType == OffsetType.N_Rooks){
            pos.x = initialPixelPos.x + frame / (float)numSamples;
            pos.y = initialPixelPos.y + (float)rookPositions[frame % numSamples] / (float)numSamples;
        }
        pos = fract(pos);

       return pos; 
    }

    Vector2 fract(Vector2 v){
        return new Vector2(v.x - Mathf.Floor(v.x), v.y - Mathf.Floor(v.y));
    }

    public bool IsPointInGrid(Vector2 point, Vector2 grid, float gridSize){
        return point.x >= grid.x && point.x < grid.x + gridSize && point.y >= grid.y && point.y < grid.y + gridSize;
    }

    void PerformChiSquareTest(){
        int gridSize = (int)Mathf.Sqrt(numSamples);
        float chiSquareControl = 0;
        float chiSquareTest = 0;
        for(int i = 0; i < gridSize; i++){
            for(int j = 0; j < gridSize; j++){
                float x = (float)i / (float)gridSize;
                float y = (float)j / (float)gridSize;
                Vector2 grid = new Vector2(x, y);
                float controlFrequency = 0;
                float testFrequency = 0;
                foreach(GameObject sample in controlSamples){
                    if(IsPointInGrid(sample.transform.position, grid, 1.0f / (float)gridSize)){
                        controlFrequency++;
                    }
                }
                foreach(GameObject sample in testSamples){
                    if(IsPointInGrid(sample.transform.position, grid, 1.0f / (float)gridSize)){
                        testFrequency++;
                    }
                }
                chiSquareControl += Mathf.Pow(controlFrequency - 1, 2) / 1.0f;
                chiSquareTest += Mathf.Pow(testFrequency - 1, 2) / 1.0f;
            }
        }
        analysisPanelController.setChiSquareControl(chiSquareControl);
        analysisPanelController.setChiSquareTest(chiSquareTest);
    }

    void PerformAverageNearestNeighbor(){
        float averageNearestNeighborControl = 0;
        for(int i = 0; i < controlSamples.Count; i++){
            float nearestNeightBorControl = float.MaxValue;
            for(int j = 0; j < controlSamples.Count; j++){
                if(i != j){
                    float distance = Vector3.Distance(controlSamples[i].transform.position, controlSamples[j].transform.position);
                    if(distance < nearestNeightBorControl){
                        nearestNeightBorControl = distance;
                    }
                }
            }
            averageNearestNeighborControl += nearestNeightBorControl;
        }
        averageNearestNeighborControl /= controlSamples.Count;
        analysisPanelController.setAverageNearestNeighborControl(averageNearestNeighborControl);

        float averageNearestNeighborTest = 0;
        for(int i = 0; i < testSamples.Count; i++){
            float nearestNeightBorTest = float.MaxValue;
            for(int j = 0; j < testSamples.Count; j++){
                if(i != j){
                    float distance = Vector3.Distance(testSamples[i].transform.position, testSamples[j].transform.position);
                    if(distance < nearestNeightBorTest){
                        nearestNeightBorTest = distance;
                    }
                }
            }
            averageNearestNeighborTest += nearestNeightBorTest;
        }
        averageNearestNeighborTest /= testSamples.Count;
        analysisPanelController.setAverageNearestNeighborTest(averageNearestNeighborTest);
    
    }

    // Update is called once per frame
    void Update()
    {
        if(recalculate){
            recalculate = false;
            AnalyzePoints();
        }
    }
}
