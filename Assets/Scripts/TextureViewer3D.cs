using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextureViewer3D : MonoBehaviour
{
    public enum Channel {
        R = 0,
        G = 1,
        B = 2,
        A = 3,
        RGBA = 4,
    }
    public Channel channel = Channel.RGBA;

    public Texture3D texture;
    public Material textureView;

    [NonSerialized]
    public int currentSlice;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        textureView.SetTexture("_TextureView", texture);
        textureView.SetFloat("_Slice", (float)(currentSlice + 0.5f)/(float)texture.depth);
        textureView.SetInt("_Channel", (int)channel);
    }
}
