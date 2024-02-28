using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
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
    //public OffsetType offsetType = OffsetType.GoldenRatio;
    private OffsetType offsetType;

    const float GoldenRatio = 1.61803398875f;

    public Texture2D blueNoiseTexture;

    private List<Vector3> controlSamples = new List<Vector3>();
    private List<Vector3> testSamples = new List<Vector3>();

    public bool recalculate = false;

    public List<int> rookPositions = new List<int>();

    private Vector2 bestWhiteNosie = new Vector2(float.MaxValue, float.MaxValue);
    private List<Vector3> bestWhiteNoiseSamples = new List<Vector3>();
    private float whiteNoiseChiAverage = 0;
    private float whiteNoiseNeighborAverage = 0;

    private Vector2 bestN_Rooks = new Vector2(float.MaxValue, float.MaxValue);
    private List<Vector3> bestN_RooksSamples = new List<Vector3>();
    private float n_rooksChiAverage = 0;
    private float n_rooksNeighborAverage = 0;

    private int numberOfTests = 10000;

    private List<GameObject> baselineVisuals = new List<GameObject>();
    private List<GameObject> sampleVisuals = new List<GameObject>();

    public OffsetType showOffsetType;
    public bool showVisuals = false;


    // Start is called before the first frame update
    void Start()
    {
        AnalyzePoints();
    }

    void WriteToFile(){
        string filePath = Path.Combine(Application.dataPath, "PixelSamples.txt");
        using (StreamWriter writer = new StreamWriter(filePath, true))
        {
            writer.WriteLine("--------------------");
            writer.WriteLine("PIXEL SAMPLE ANALYSIS FOR " + numSamples + " SAMPLES");

            writer.WriteLine("Baseline Samples: ");
            writer.Write("{");
            for(int i = 0; i < controlSamples.Count; i++){
                writer.Write("{" + controlSamples[i].x + ", " + controlSamples[i].y + "}");
                if(i != controlSamples.Count - 1){
                    writer.Write(", ");
                }
            }
            writer.WriteLine("}\n\n");

            writer.WriteLine("WHITE NOISE");
            writer.WriteLine("Chi Square Average: " + whiteNoiseChiAverage);
            writer.WriteLine("Average Nearest Neighbor: " + whiteNoiseNeighborAverage);
            writer.WriteLine("Best Chi Square: " + bestWhiteNosie.x);
            writer.WriteLine("Best Average Nearest Neighbor: " + bestWhiteNosie.y);
            writer.WriteLine("Best Samples: ");
            writer.Write("{");
            for(int i = 0; i < bestWhiteNoiseSamples.Count; i++){
                writer.Write("{" + bestWhiteNoiseSamples[i].x + ", " + bestWhiteNoiseSamples[i].y + "}");
                if(i != bestWhiteNoiseSamples.Count - 1){
                    writer.Write(", ");
                }
            }
            writer.WriteLine("}\n\n");

            writer.WriteLine("N ROOKS");
            writer.WriteLine("Chi Square Average: " + n_rooksChiAverage);
            writer.WriteLine("Average Nearest Neighbor: " + n_rooksNeighborAverage);
            writer.WriteLine("Best Chi Square: " + bestN_Rooks.x);
            writer.WriteLine("Best Average Nearest Neighbor: " + bestN_Rooks.y);
            writer.WriteLine("Best Samples: ");
            writer.Write("{");
            for(int i = 0; i < bestN_RooksSamples.Count; i++){
                writer.Write("{" + bestN_RooksSamples[i].x + ", " + bestN_RooksSamples[i].y + "}");
                if(i != bestN_RooksSamples.Count - 1){
                    writer.Write(", ");
                }
            }
            writer.WriteLine("}\n\n");


            writer.WriteLine("--------------------");
        }
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
        GenerateRookPositions();
        ClearSamples();
        GenerateBaselineSamples();
        whiteNoiseChiAverage = 0;
        whiteNoiseNeighborAverage = 0;
        //White Noise
        offsetType = OffsetType.WhiteNoise;
        for(int i = 0; i < numberOfTests; i++){
            GenerateTestSamples();
            float chiResult = PerformChiSquareTest();
            float neighborResult = PerformAverageNearestNeighbor();
            whiteNoiseChiAverage += chiResult;
            whiteNoiseNeighborAverage += neighborResult;
            if(chiResult < bestWhiteNosie.x && neighborResult < bestWhiteNosie.y){
                bestWhiteNosie = new Vector2(chiResult, neighborResult);
                bestWhiteNoiseSamples = new List<Vector3>(testSamples);
            }
            ClearSamples();
            GenerateBaselineSamples();
        }
        whiteNoiseChiAverage /= numberOfTests;
        whiteNoiseNeighborAverage /= numberOfTests;

        ClearSamples();
        GenerateBaselineSamples();
        n_rooksChiAverage = 0;
        n_rooksNeighborAverage = 0;
        //N Rooks
        offsetType = OffsetType.N_Rooks;
        for(int i = 0; i < numberOfTests; i++){
            GenerateTestSamples();
            float chiResult = PerformChiSquareTest();
            float neighborResult = PerformAverageNearestNeighbor();
            n_rooksChiAverage += chiResult;
            n_rooksNeighborAverage += neighborResult;
            if(chiResult < bestN_Rooks.x && neighborResult < bestN_Rooks.y){
                bestN_Rooks = new Vector2(chiResult, neighborResult);
                bestN_RooksSamples = new List<Vector3>(testSamples);
            }

            ClearSamples();
            GenerateBaselineSamples();
        }
        n_rooksChiAverage /= numberOfTests;
        n_rooksNeighborAverage /= numberOfTests;

        //PerformChiSquareTest();
        //PerformAverageNearestNeighbor();
        WriteToFile();
    }

    void ClearSamples(){
        // foreach(GameObject sample in controlSamples){
        //     Destroy(sample);
        // }
        controlSamples.Clear();

        // foreach(GameObject sample in testSamples){
        //     Destroy(sample);
        // }
        testSamples.Clear();
    }

    void GenerateBaselineSamples(){
        int gridSize = (int)Mathf.Sqrt(numSamples);
        for(int i = 0; i < gridSize; i++){
            for(int j = 0; j < gridSize; j++){
                float x = (float)i / (float)gridSize + 0.5f / (float)gridSize;
                float y = (float)j / (float)gridSize + 0.5f / (float)gridSize;
                Vector3 sample =new Vector3(x, y, 0);
                // sample.GetComponent<Renderer>().material = unactiveSampleMat;
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

        Vector3 initSample = new Vector3(initialPixelPos.x, initialPixelPos.y, 0);
        // initSample.GetComponent<Renderer>().material = activeSampleMat;
        testSamples.Add(initSample);

        for(int i = 1; i < numSamples; i++){
            Vector2 pos = GetSamplePixelPosition(initialPixelPos, i + frame);
            Vector3 sample = new Vector3(pos.x, pos.y, 0);
            // sample.GetComponent<Renderer>().material = activeSampleMat;
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

    float PerformChiSquareTest(){
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
                foreach(Vector3 sample in controlSamples){
                    if(IsPointInGrid(sample, grid, 1.0f / (float)gridSize)){
                        controlFrequency++;
                    }
                }
                foreach(Vector3 sample in testSamples){
                    if(IsPointInGrid(sample, grid, 1.0f / (float)gridSize)){
                        testFrequency++;
                    }
                }
                chiSquareControl += Mathf.Pow(controlFrequency - 1, 2) / 1.0f;
                chiSquareTest += Mathf.Pow(testFrequency - 1, 2) / 1.0f;
            }
        }
        //analysisPanelController.setChiSquareControl(chiSquareControl);
        //analysisPanelController.setChiSquareTest(chiSquareTest);

        return chiSquareTest;
    }

    float PerformAverageNearestNeighbor(){
        float averageNearestNeighborControl = 0;
        for(int i = 0; i < controlSamples.Count; i++){
            float nearestNeightBorControl = float.MaxValue;
            if(controlSamples.Count == 1){
                nearestNeightBorControl = 1;
            }
            for(int j = 0; j < controlSamples.Count; j++){
                if(i != j){
                    float distance = Vector3.Distance(controlSamples[i], controlSamples[j]);
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
            if(testSamples.Count == 1){
                nearestNeightBorTest = 1;
            }
            for(int j = 0; j < testSamples.Count; j++){
                if(i != j){
                    float distance = Vector3.Distance(testSamples[i], testSamples[j]);
                    if(distance < nearestNeightBorTest){
                        nearestNeightBorTest = distance;
                    }
                }
            }
            averageNearestNeighborTest += nearestNeightBorTest;
        }
        averageNearestNeighborTest /= testSamples.Count;
        analysisPanelController.setAverageNearestNeighborTest(averageNearestNeighborTest);

        return Math.Abs(averageNearestNeighborControl - averageNearestNeighborTest);
    }


    void ClearVisuals(){
        foreach(GameObject sample in baselineVisuals){
            Destroy(sample);
        }
        baselineVisuals.Clear();

        foreach(GameObject sample in sampleVisuals){
            Destroy(sample);
        }
        sampleVisuals.Clear();
    
    }

    void ShowVisuals(){
        foreach(Vector3 sample in controlSamples){
            GameObject sampleVisual = Instantiate(pixelSamplePos, sample, Quaternion.identity);
            sampleVisual.GetComponent<Renderer>().material = unactiveSampleMat;
            baselineVisuals.Add(sampleVisual);
        }

        List<Vector3> showSamples = new List<Vector3>();
        if(showOffsetType == OffsetType.WhiteNoise){
            showSamples = bestWhiteNoiseSamples;
        }
        else if(showOffsetType == OffsetType.N_Rooks){
            showSamples = bestN_RooksSamples;
        }

        foreach(Vector3 sample in showSamples){
            GameObject sampleVisual = Instantiate(pixelSamplePos, sample, Quaternion.identity);
            sampleVisual.GetComponent<Renderer>().material = activeSampleMat;
            sampleVisuals.Add(sampleVisual);
        }
    }


    void Update()
    {
        if(recalculate){
            recalculate = false;
            AnalyzePoints();
        }
        if(showVisuals){
            showVisuals = false;
            ClearVisuals();
            ShowVisuals();
        }
    }
}
