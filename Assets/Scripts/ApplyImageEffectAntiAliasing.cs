using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

public class ApplyImageEffectAntiAliasing : MonoBehaviour
{
    public Material material;
    public Material anitAliasingMaterial;
    public Material blurMaterial;
    [Range(1, 9)]
    public int numSamples = 1;
    private int numSamplesFinal;
    int frame = 0;
    RenderTexture[] buffers;
    RenderTexture antiAliasedBuffer;
    public enum NoiseAnimationMode {
        GoldenRatio = 0,
        Uniform = 1,
        None = 2,
    };
    public NoiseAnimationMode noiseAnimationMode = NoiseAnimationMode.GoldenRatio;
    public bool useBlur = false;
    public enum BlurMode {
        Gaussian3x3 = 0,
        Gaussian5x5 = 1,
    }
    public BlurMode blurMode = BlurMode.Gaussian3x3;

    void Start()
    {
        Debug.Assert(material != null);
        Debug.Assert(anitAliasingMaterial != null);
        Debug.Assert(blurMaterial != null);
        
        numSamplesFinal = numSamples;
        buffers = new RenderTexture[numSamplesFinal];
        for(int i = 0; i < numSamplesFinal; i++){
            buffers[i] = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBFloat);
        }
        antiAliasedBuffer = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBFloat);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination){

        anitAliasingMaterial.SetInt("_Frame", frame);
        anitAliasingMaterial.SetInt("_NumSamples", numSamplesFinal);
        material.SetInt("_Frame", frame);
        material.SetInt("_NumSamples", numSamplesFinal);
        material.SetInt("_NoiseMode", (int)noiseAnimationMode);
        blurMaterial.SetInt("_Mode", (int)blurMode);


        if(material != null && anitAliasingMaterial != null && blurMaterial != null){

            //Before frame threshold
            if(frame < numSamplesFinal){
                Graphics.Blit(source, buffers[frame], material);
                anitAliasingMaterial.SetTexture("_FrameTex", buffers[frame]);
                RenderTexture temp = RenderTexture.GetTemporary(antiAliasedBuffer.width, antiAliasedBuffer.height, antiAliasedBuffer.depth, antiAliasedBuffer.format);
                Graphics.Blit(antiAliasedBuffer, temp, anitAliasingMaterial);
                Graphics.Blit(temp,antiAliasedBuffer);
                RenderTexture.ReleaseTemporary(temp);
            }
            else{

                //Subract oldest frame
                anitAliasingMaterial.SetInt("_Mode",0);
                anitAliasingMaterial.SetTexture("_FrameTex", buffers[frame % numSamplesFinal]);
                RenderTexture temp = RenderTexture.GetTemporary(antiAliasedBuffer.width, antiAliasedBuffer.height, antiAliasedBuffer.depth, antiAliasedBuffer.format);
                Graphics.Blit(antiAliasedBuffer, temp,  anitAliasingMaterial);
                Graphics.Blit(temp,antiAliasedBuffer);
                RenderTexture.ReleaseTemporary(temp);

                //Add new frame
                Graphics.Blit(source, buffers[frame % numSamplesFinal], material);
                anitAliasingMaterial.SetInt("_Mode", 1);
                anitAliasingMaterial.SetTexture("_FrameTex", buffers[frame % numSamplesFinal]);
                temp = RenderTexture.GetTemporary(antiAliasedBuffer.width, antiAliasedBuffer.height, antiAliasedBuffer.depth, antiAliasedBuffer.format);
                Graphics.Blit(antiAliasedBuffer, temp, anitAliasingMaterial);
                Graphics.Blit(temp,antiAliasedBuffer);
                RenderTexture.ReleaseTemporary(temp);
            }

            if(useBlur){
                Graphics.Blit(antiAliasedBuffer, destination, blurMaterial);
            }
            else{
                Graphics.Blit(antiAliasedBuffer, destination);
            }
            

            //Graphics.Blit(source, buffers[frame % numSamplesFinal], material);


        }
        else{
            Graphics.Blit(source,destination);
            Debug.LogError("Image effect material is null");
        }

        frame++;
    }

}
