using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DimensionalProfileController : MonoBehaviour
{
    public Material mat;
    public RenderTexture cloudCoverageRederTexture;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        mat.SetTexture("_CloudCoverage", cloudCoverageRederTexture);
    }
}
