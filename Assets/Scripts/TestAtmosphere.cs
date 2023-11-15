using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class TestAtmosphere : MonoBehaviour
{
    public Material mat;
    public float atmosphereHeight = 100;

    public int numSteps = 1;

    public enum TestMode {
        renderTestTexture = 1,
        renderCloudCoverageTexture = 2,
    }

    public TestMode testMode;
    // Start is called before the first frame update
    void Start()
    {

        MeshRenderer[] renderers = GetComponentsInChildren<MeshRenderer>();
        foreach(MeshRenderer renderer in renderers){
            renderer.enabled = false;
        }

        mat.SetVector("_PlanePosition", transform.position);
        mat.SetVector("_PlaneNormal", transform.forward);
        mat.SetVector("_PlaneRight", -transform.right);
        mat.SetVector("_PlaneUp", transform.up);
        mat.SetFloat("_PlaneHeight", transform.localScale.y / 2.0f);
        mat.SetFloat("_PlaneWidth", transform.localScale.x / 2.0f);
            
            
            
    }

    // Update is called once per frame
    void Update()
    {
        mat.SetFloat("_AtmosphereHeight", atmosphereHeight);
        mat.SetInt("_NumSteps", numSteps);
        mat.SetInt("_TestMode", (int)testMode);
    }
}
