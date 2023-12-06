using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CloudTypeController : MonoBehaviour
{
    public Material mat;
    [Range(0f, 25f)]
    public float nodeSize1 = 8f;
    [Range(0f, 25f)]
    public float nodeSize2 = 15f;
    [Range(0f, 25f)]
    public float nodeSize3 = 20f;
    [Range(0.01f, 1f)]
    public float nodeWeight1 = 0.6f;
    [Range(0.01f, 1f)]
    public float nodeWeight2 = 0.3f;
    [Range(0.01f, 1f)]
    public float nodeWeight3 = 0.1f;
    [Range(0f,1f)]
    public float noiseThreshold = 0.8f;
    [Range(-5f,5f)]
    public float noiseShift = 0.0f;
    [Range(0f,5f)]
    public float noiseMultiplier = 1f;
    public bool animate = false;
    [Range(0.001f, 1f)]
    public float animateSpeed = 0.2f;
    private float elapsedTime = 0f;
    void Start()
    {
        Debug.Assert(mat != null);

    }

    void Update()
    {
        mat.SetFloat("_NodeSize1", nodeSize1);
        mat.SetFloat("_NodeSize2", nodeSize2);
        mat.SetFloat("_NodeSize3", nodeSize3);
        
        float weightTotal = nodeWeight1 + nodeWeight2 + nodeWeight3;

        mat.SetFloat("_NodeWeight1", nodeWeight1 / weightTotal);
        mat.SetFloat("_NodeWeight2", nodeWeight2 / weightTotal);
        mat.SetFloat("_NodeWeight3", nodeWeight3 / weightTotal);

        mat.SetFloat("_NoiseShift", noiseShift);
        mat.SetFloat("_NoiseMultiplier", noiseMultiplier);
        mat.SetFloat("_NoiseThreshold", noiseThreshold);


        if(animate){
            elapsedTime += (Time.deltaTime * animateSpeed);
        }

        mat.SetFloat("_ZSlice", elapsedTime);
    }
}
