using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CloudCubeController : MonoBehaviour
{
    public Material material;
    public GameObject cube;
    void Start()
    {
        cube.GetComponent<MeshRenderer>().enabled = false;
    }

    // Update is called once per frame
    void Update()
    {
        material.SetVector("_CubePosition", cube.transform.position);
        material.SetFloat("_CubeLength", cube.transform.localScale.x);
    }
}
