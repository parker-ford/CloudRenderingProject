using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class TestAtmosphere : MonoBehaviour
{
    public Material mat;
    public float atmosphereHeight = 100;
    public float densityMultiplier = 1;
    public float distanceMultiplier = 0;
    public GameObject plane;

    public enum TestMode {
        renderTestTexture = 1,
        renderCloudCoverageTexture = 2,
        rednerCloudCoverage = 3,
        renderCurvedAtmosphere = 4,
    }

    public bool infinitePlane = false;

    public TestMode testMode;
    // Start is called before the first frame update
    void Start()
    {

        MeshRenderer[] renderers = GetComponentsInChildren<MeshRenderer>();
        foreach(MeshRenderer renderer in renderers){
            renderer.enabled = false;
        }

        mat.SetVector("_PlanePosition", plane.transform.position);
        mat.SetVector("_PlaneNormal", plane.transform.forward);
        mat.SetVector("_PlaneRight", -plane.transform.right);
        mat.SetVector("_PlaneUp", plane.transform.up);
        mat.SetFloat("_PlaneHeight", plane.transform.localScale.y / 2.0f);
        mat.SetFloat("_PlaneWidth", plane.transform.localScale.x / 2.0f);
            
            
            
    }

    // Update is called once per frame
    void Update()
    {
        mat.SetFloat("_AtmosphereHeight", atmosphereHeight);
        mat.SetInt("_TestMode", (int)testMode);
        mat.SetFloat("_DensityMultiplier", densityMultiplier);
        mat.SetInt("_InfinitePlane", infinitePlane ? 1 : 0);
        mat.SetFloat("_DistanceMultiplier", distanceMultiplier);
    }
}
