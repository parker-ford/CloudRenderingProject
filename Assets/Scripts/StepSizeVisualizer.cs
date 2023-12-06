using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using Unity.VisualScripting;
using UnityEngine;

public class StepSizeVisualizer : MonoBehaviour
{
    public GameObject dot;
    public GameObject endDot;
    public GameObject line;

    public GameObject atmosphereLower;
    public GameObject atmosphereHigher;

    public int numSteps = 10;

    public float nearStepSize = 3.0f;
    public float farStepSizeOffset = 60.0f;
    
    public float stepAdjustmentDistance = 16384.0f;

    public Vector2 atmosphereDimensions;

    public enum StepMode {
        uniform,
        increasing

    }

    public StepMode stepMode;

    public float spacingRatio;

    List<GameObject> dots = new List<GameObject>();
    GameObject dotStart;
    GameObject dotEnd;
    // Start is called before the first frame update
    void Start()
    {
        for(int i = 0; i < numSteps; i++){
            dots.Add(Instantiate(dot));
        }
        dotStart = Instantiate(endDot);
        dotEnd = Instantiate(endDot);

    }

    // Update is called once per frame

    Vector3 getMarchPosition(Vector3 origin, Vector3 direction, float intersectionDist, float iteration, float distPerStep){
        Vector3 pos = origin + direction * (intersectionDist + (distPerStep * iteration));
        return pos;
    }

    Vector3 getMarchPositionIncreasing(Vector3 origin, Vector3 direction, float intersectionDist, float iteration, float distPerStep){
        float distSoFar = ((iteration * (iteration + 1)) / numSteps);
        float distConst = ((2*numSteps) / (numSteps + 1));
        float distThisStep = distSoFar * distConst;
        Vector3 pos = origin + direction * (intersectionDist + (distPerStep * distThisStep));
        Debug.Log(pos);
        return pos;
    }


    void Update()
    {
        atmosphereLower.transform.position = Vector3.up * atmosphereDimensions.x;
        atmosphereHigher.transform.position = Vector3.up * atmosphereDimensions.y;


        line.transform.position = Camera.main.transform.position;
        line.transform.position += Camera.main.transform.forward * line.transform.localScale.y;
        line.transform.up = Camera.main.transform.forward;

        Vector3 origin = Camera.main.transform.position;
        Vector3 dir = Camera.main.transform.forward;
        float t1 = Vector3.Dot(-Vector3.up, Vector3.up * atmosphereDimensions.x - origin) / Vector3.Dot(-Vector3.up, dir);
        float t2 = Vector3.Dot(-Vector3.up, Vector3.up * atmosphereDimensions.y - origin) / Vector3.Dot(-Vector3.up, dir);

        Vector3 startPos = origin + dir * t1;
        Vector3 endPos = origin + dir * t2;
        dotStart.transform.position = startPos;
        dotEnd.transform.position = endPos;
        

        float dist = (endPos - startPos).magnitude;

        if(stepMode == StepMode.uniform){
            float distPerStep = dist/(float) numSteps;
            for(int i = 0; i < numSteps; i++){
                // dots[i].transform.position = startPos + dir * (distPerStep * i);
                dots[i].transform.position = getMarchPosition(Camera.main.transform.position, dir, t1, i, distPerStep);
            }
        }
        else if(stepMode == StepMode.increasing){

            float distPerStep = dist/(float)numSteps;
            for(int i = 0; i < numSteps; i++){
                // dots[i].transform.position = startPos + dir * (distPerStep * i);
                dots[i].transform.position = getMarchPositionIncreasing(Camera.main.transform.position, dir, t1, i, distPerStep);
            }

            // float distPerStep = dist/(float) numSteps;
            // for(int i = 0; i < numSteps; i++){
            //     dots[i].transform.position = startPos + dir * (Mathf.Pow(distPerStep, i) * i);
            // }

            // float distanceFromCamera = (origin - startPos).magnitude;
            // float accumulatedDistance = 0.0f; // Initialize accumulated distance

            // for(int i = 0; i < numSteps; i++) {
            //     float stepSize = nearStepSize + ((farStepSizeOffset * distanceFromCamera) / stepAdjustmentDistance);
            //     accumulatedDistance += stepSize; // Accumulate the distance traveled
            //     Vector3 pos = startPos + dir * accumulatedDistance; // Use accumulated distance
            //     dots[i].transform.position = pos;

            //     distanceFromCamera = (pos - origin).magnitude; // Update the distance from camera
            // }


            // float totalFactor = 0;
            // for (int i = 0; i < numSteps; i++)
            // {
            //     totalFactor += (float)Math.Pow(spacingRatio, i);
            // }

            // float currentDistance = 0;
            // for (int i = 0; i < numSteps; i++)
            // {
            //     Vector3 pos = startPos + dir * (currentDistance);
            //     dots[i].transform.position = pos;
            //     float segment = dist * (float)Math.Pow(spacingRatio, i) / totalFactor;
            //     currentDistance += segment + 3.0f;


            //     dots[i].transform.position = 
            // }


            // float totalFactor = 1;
            // float currentSegment = dist / (1 * (float)Mathf.Pow(spacingRatio, numSteps - 1));
            // for(int i = 0; i < numSteps; i++){
            //     dots[i].transform.position = startPos + dir * currentSegment * totalFactor;
            //     totalFactor += Mathf.Pow(spacingRatio, i + i);
            // }
        }

        // for(int i = 0; i < numSteps; i++){
        //     float x = -Mathf.Log(numSteps) * (numSteps - i - 1) / numSteps;
        //     float stepSize = Mathf.Exp(x);
        //     Debug.Log(stepSize);
        //     Vector3 pos = startPos + dir * stepSize;
        //     dots[i].transform.position = pos;
        // }

        // float distanceFromCamera = (origin - startPos).magnitude;
        // for(int i = 0; i < numSteps; i++){
        //     float stepSize = nearStepSize + ((farStepSizeOffset * distanceFromCamera) / stepAdjustmentDistance);
        //     Vector3 pos = startPos + dir * stepSize;
        //     dots[i].transform.position = pos;
        //     distanceFromCamera = (pos - origin).magnitude;
        // }

        line.transform.localScale = new Vector3(line.transform.localScale.x, (origin - endPos).magnitude / 2.0f, line.transform.localScale.z);
    }
}
