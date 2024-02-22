using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class AnalysisPanelController : MonoBehaviour
{
    public TextMeshProUGUI chiSquareControl;
    public TextMeshProUGUI chiSquareTest;
    public TextMeshProUGUI averageNearestNeighborControl;
    public TextMeshProUGUI averageNearestNeighborTest;


    // Start is called before the first frame update
    void Start()
    {
        
    }

    public void setChiSquareControl(float chiSquare){
        chiSquareControl.text = chiSquare.ToString();
    }

    public void setChiSquareTest(float chiSquare){
        chiSquareTest.text = chiSquare.ToString();
    }

    public void setAverageNearestNeighborControl(float averageNearestNeighbor){
        averageNearestNeighborControl.text = averageNearestNeighbor.ToString("F3");
    }

    public void setAverageNearestNeighborTest(float averageNearestNeighbor){
        averageNearestNeighborTest.text = averageNearestNeighbor.ToString("F3");
    }
}
