using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class Noise
{
    private static float fade(float x){
        return ((6.0f * x - 15.0f) * x + 10.0f) * x * x * x;
    }
    private static int pcgHash_i(int state){
        int word = ((state >> ((state >> 28) + 4)) ^ state) * 277803737;
        return (word >> 22) ^ word;
    }
    private static int seedGen_i3(Vector3Int input){
        int seed1 = input.x * 265443576;
        int seed2 = input.y * 224682251;
        int seed3 = input.z * 326648991;

        return seed1 + seed2 + seed3;
    }
    private static float remap_f(float value, float in_min, float in_max, float out_min, float out_max)
    {
        return (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
    }

    private static Vector3 remap_f3(Vector3 value, float in_min, float in_max, float out_min, float out_max)
    {
        Vector3 v = new Vector3(0, 0, 0);
        v.x = remap_f(value.x, in_min, in_max, out_min, out_max);
        v.y = remap_f(value.y, in_min, in_max, out_min, out_max);
        v.z = remap_f(value.z, in_min, in_max, out_min, out_max);
        return v;
    }

    private static Vector3 gradientVector_3D(Vector3 input, int textureSize)
    {
        Vector3[] vectors = new Vector3[12] {
            new Vector3(1.0f, 1.0f, 0.0f),
            new Vector3(-1.0f, 1.0f, 0.0f),
            new Vector3(1.0f, -1.0f, 0.0f),
            new Vector3(-1.0f, -1.0f, 0.0f),
            new Vector3(1.0f, 0.0f, 1.0f),
            new Vector3(-1.0f, 0.0f, 1.0f),
            new Vector3(1.0f, 0.0f, -1.0f),
            new Vector3(-1.0f, 0.0f, -1.0f),
            new Vector3(0.0f, 1.0f, 1.0f),
            new Vector3(0.0f, -1.0f, 1.0f),
            new Vector3(0.0f, 1.0f, -1.0f),
            new Vector3(0.0f, -1.0f, -1.0f)
        };

        //TODO: May need to fix this. Assumes all dimensions are the same
        int seed = seedGen_i3(new Vector3Int((int)(input.x * textureSize), (int)(input.y * textureSize), (int)(input.z * textureSize)));
        int r = pcgHash_i(seed);
        r = pcgHash_i(r);

        Vector3 v = vectors[r % 12];

        return v;
    }

    public static float perlinNoise_3D(Vector3 p, float cellSize, int textureSize)
    {
        //Interval between cells
        float i = 1.0f / cellSize;

        //Cell that point lies in
        Vector3 id = p * cellSize;
        id = new Vector3(Mathf.Floor(id.x), Mathf.Floor(id.y), Mathf.Floor(id.z));
        id = id / cellSize;

        //Coordinates of cell corners in 3D
        Vector3 c000 = new Vector3(id.x, id.y, id.z);
        Vector3 c001 = new Vector3(id.x, id.y, id.z + i);
        Vector3 c010 = new Vector3(id.x, id.y + i, id.z);
        Vector3 c011 = new Vector3(id.x, id.y + i, id.z + i);
        Vector3 c100 = new Vector3(id.x + i, id.y, id.z);
        Vector3 c101 = new Vector3(id.x + i, id.y, id.z + i);
        Vector3 c110 = new Vector3(id.x + i, id.y + i, id.z);
        Vector3 c111 = new Vector3(id.x + i, id.y + i, id.z + i);

        //Vectors from corners to point
        Vector3 v000 = remap_f3(p - c000, 0, i, 0, 1);
        Vector3 v001 = remap_f3(p - c001, 0, i, 0, 1);
        Vector3 v010 = remap_f3(p - c010, 0, i, 0, 1);
        Vector3 v011 = remap_f3(p - c011, 0, i, 0, 1);
        Vector3 v100 = remap_f3(p - c100, 0, i, 0, 1);
        Vector3 v101 = remap_f3(p - c101, 0, i, 0, 1);
        Vector3 v110 = remap_f3(p - c110, 0, i, 0, 1);
        Vector3 v111 = remap_f3(p - c111, 0, i, 0, 1);
        
        //Gradient vectors at each corner of cell
        Vector3 gv000 = gradientVector_3D(c000, textureSize);
        Vector3 gv001 = gradientVector_3D(c001, textureSize);
        Vector3 gv010 = gradientVector_3D(c010, textureSize);
        Vector3 gv011 = gradientVector_3D(c011, textureSize);
        Vector3 gv100 = gradientVector_3D(c100, textureSize);
        Vector3 gv101 = gradientVector_3D(c101, textureSize);
        Vector3 gv110 = gradientVector_3D(c110, textureSize);
        Vector3 gv111 = gradientVector_3D(c111, textureSize);

        //Fade values
        float fx = fade(p.x * cellSize - Mathf.Floor(p.x * cellSize));
        float fy = fade(p.y * cellSize - Mathf.Floor(p.y * cellSize));
        float fz = fade(p.z * cellSize - Mathf.Floor(p.z * cellSize));

        //Dot products
        float dot000 = Vector3.Dot(v000, gv000);
        float dot001 = Vector3.Dot(v001, gv001);
        float dot010 = Vector3.Dot(v010, gv010);
        float dot011 = Vector3.Dot(v011, gv011);
        float dot100 = Vector3.Dot(v100, gv100);
        float dot101 = Vector3.Dot(v101, gv101);
        float dot110 = Vector3.Dot(v110, gv110);
        float dot111 = Vector3.Dot(v111, gv111);

        //Trilinear interpolation
        float n1 = Mathf.Lerp(dot000, dot100, fx);
        float n2 = Mathf.Lerp(dot010, dot110, fx);
        float n3 = Mathf.Lerp(dot001, dot101, fx);
        float n4 = Mathf.Lerp(dot011, dot111, fx);

        float n5 = Mathf.Lerp(n1, n2, fy);
        float n6 = Mathf.Lerp(n3, n4, fy);

        float n = Mathf.Lerp(n5, n6, fz);

        return n;
    }
}
