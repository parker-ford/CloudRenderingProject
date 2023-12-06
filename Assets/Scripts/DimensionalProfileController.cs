using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DimensionalProfileController : MonoBehaviour
{
    public Material mat;
    public RenderTexture cloudCoverageRederTexture;
    public RenderTexture cloudTypeRenderTexture;
    public RenderTexture cloudGradientRenderTexture;
    public bool useCloudGradient = true;
    public bool viewCloudCoverageTexture = false;
    private int dimensionalProfileOptions;
    private int cloudGradientBit = 1;
    private int coverageTextureBit = 2;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        mat.SetTexture("_CloudCoverage", cloudCoverageRederTexture);
        mat.SetTexture("_CloudType", cloudTypeRenderTexture);
        mat.SetTexture("_CloudGradient", cloudGradientRenderTexture);

        dimensionalProfileOptions = 0;
        if(useCloudGradient){
            dimensionalProfileOptions |= cloudGradientBit;
        }
        if(viewCloudCoverageTexture){
            dimensionalProfileOptions |= coverageTextureBit;
        }
        mat.SetInt("_DimensionalProfileOptions", dimensionalProfileOptions);
    }
}
