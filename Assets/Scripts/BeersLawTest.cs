using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BeersLawTest : MonoBehaviour
{
    public Material mat;
    public GameObject myLight;
    public float density = 0.1f;
    public int lightSteps  = 5;
    public bool animateLight = false;
    public Transform sphere;

    // Start is called before the first frame update
    void Start()
    {
        Debug.Assert(myLight);
        Debug.Assert(mat);

        
    }

    // Update is called once per frame
    void Update()
    {

        if(animateLight){
            myLight.transform.position = new Vector3(Mathf.Cos(Time.time), myLight.transform.position.y, Mathf.Sin(Time.time));
        }

        mat.SetVector("_SphereCenter", sphere.transform.position);
        mat.SetFloat("_SphereRadius", sphere.transform.localScale.y / 2.0f);
        mat.SetFloat("_SphereDensity", density);
        mat.SetVector("_LightDirection", myLight.transform.position.normalized);
        mat.SetVector("_LightPosition", myLight.transform.position);
        mat.SetInt("_LightSteps", lightSteps);
        // mat.SetVector("_LightDirection", -myLight.transform.position);

    }
}
