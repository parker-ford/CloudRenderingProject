using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlueNoiseController : MonoBehaviour
{
     public Material material;
    public GameObject cube;
    public float absorption = 0.1f;
    public float noiseTiling = 24;
    public MyDirectionalLight myDirectionalLight;
    public float lightIntensity = 1.0f;
    public float lightAbsorption = 1.0f;
    void Start()
    {
        cube.GetComponent<MeshRenderer>().enabled = false;
    }

    // Update is called once per frame
    void Update()
    {
        material.SetVector("_CubePosition", cube.transform.position);
        material.SetFloat("_CubeLength", cube.transform.localScale.x);
        material.SetFloat("_Absorption", absorption);
        material.SetFloat("_NoiseTiling", noiseTiling);
        material.SetVector("_LightDir", myDirectionalLight.lightDirection);
        material.SetFloat("_LightIntensity", lightIntensity);
        material.SetFloat("_LightAbsorption", lightAbsorption);

    }
}
