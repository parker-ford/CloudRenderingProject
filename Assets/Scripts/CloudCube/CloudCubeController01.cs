using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CloudCubeController01 : MonoBehaviour
{
    public Material material;
    public GameObject cube;
    public float absorption = 0.1f;
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

    }
}
