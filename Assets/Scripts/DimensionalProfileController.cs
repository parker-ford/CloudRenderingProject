using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DimensionalProfileController : MonoBehaviour
{
    public Material mat;
    public Vector2 atmoshpereDimensions;
    public float maxViewDistance;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        mat.SetVector("_AtmosphereDimensions", atmoshpereDimensions);
        mat.SetFloat("_MaxViewDistance", maxViewDistance);
    }
}
