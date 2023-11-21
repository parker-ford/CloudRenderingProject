#ifndef _NOISE_CGINC_
#define _NOISE_CGINC_


#include "./shaderUtils.cginc"

int seedGen_ui3(int3 input){
    int seed1 = input.x * 2654435761u;
    int seed2 = input.y * 2246822519u;
    int seed3 = input.z * 3266489917u;

    return seed1 + seed2 + seed3;
}

int seedGen_ui2(int2 input){
    int seed1 = input.x * 2654435761u;
    int seed2 = input.y * 2246822519u;

    return seed1 + seed2;
}

float2 map_f2(float2 v, float cellSize){
    float i = 1.0 / cellSize;
    float2 _v = float2(0,0);
    _v.x = remap_f(v.x, 0.0, i, 0.0, 1.0);
    _v.y = remap_f(v.y, 0.0, i, 0.0, 1.0);
    return _v;
}


float2 gradientVector_2D(float2 input){

    //TODO: Maybe make more gradient vectors
    float2 vectors[8] = {
        float2(1.0, 1.0),
        float2(1.0, -1.0),
        float2(-1.0, 1.0),
        float2(-1.0, -1.0),
        float2(1.0, 0.0),
        float2(0.0, -1.0),
        float2(0.0, 1.0),
        float2(-1.0, 0.0),
    };

    int seed = seedGen_ui2(int2(input.x * _ScreenParams.x, input.y * _ScreenParams.y));
    int r = pcgHash_ui(seed);
    r = pcgHash_ui(r);
    float2 v = vectors[r & 7];

    return v;
}

float3 gradientVector_3D(float3 input){
    float3 vectors[12] = {
        float3(1.0, 1.0, 0.0),
        float3(-1.0, 1.0, 0.0),
        float3(1.0, -1.0, 0.0),
        float3(-1.0, -1.0, 0.0),
        float3(1.0, 0.0, 1.0),
        float3(-1.0, 0.0, 1.0),
        float3(1.0, 0.0, -1.0),
        float3(-1.0, 0.0, -1.0),
        float3(0.0, 1.0, 1.0),
        float3(0.0, -1.0, 1.0),
        float3(0.0, 1.0, -1.0),
        float3(0.0, -1.0, -1.0)
    };

    //TODO: May need to fix this. Assumes all dimensions are the same
    int seed = seedGen_ui3(int3(input.x * _ScreenParams.x, input.y * _ScreenParams.x, input.z * _ScreenParams.x));
    int r = pcgHash_ui(seed);
    r = pcgHash_ui(r);

    float3 v = vectors[r % 12];

    return v;
}

float fade(float x){
    return ((6.*x - 15.)*x + 10.)*x*x*x;
}

float perlinNoise_2D(float2 p, float cellSize) {
    
    //Interval between cells
    float i = 1.0 / cellSize;

    //Cell that this pixel lies in
    float2 id = floor(p * cellSize) / cellSize;

    //Cordinates of cell corners
    float2 tl = float2(id.x, id.y);
    float2 tr = float2(id.x + i, id.y);
    float2 bl = float2(id.x, id.y + i);
    float2 br = float2(id.x + i, id.y + i);

    //Vector from corners of cell to point
    float2 v_tl = remap_f2(float2(p.x - id.x, p.y - id.y), 0.0, i, 0.0, 1.0);
    float2 v_tr = remap_f2(float2(p.x - id.x - i, p.y - id.y), 0.0, i, 0.0, 1.0);
    float2 v_bl = remap_f2(float2(p.x - id.x, p.y - id.y - i), 0.0, i, 0.0, 1.0);
    float2 v_br = remap_f2(float2(p.x - id.x - i, p.y - id.y - i), 0.0, i, 0.0, 1.0);

    //Gradient vectors at each cell corner
    float2 gv_tl = gradientVector_2D(tl);
    float2 gv_tr = gradientVector_2D(tr);
    float2 gv_bl = gradientVector_2D(bl);
    float2 gv_br = gradientVector_2D(br);

    //Fade value
    float fx = fade((p.x * cellSize) - floor(p.x * cellSize));
    float fy = fade((p.y * cellSize) - floor(p.y * cellSize));

    //Dot product of corner gradient and vector to point
    float dot_tl = dot(v_tl, gv_tl);
    float dot_tr = dot(v_tr, gv_tr);
    float dot_bl = dot(v_bl, gv_bl);
    float dot_br = dot(v_br, gv_br);

    //Bilinear interpolation
    float n_t = lerp(dot_tl, dot_tr, fx);
    float n_b = lerp(dot_bl, dot_br, fx);
    float n = lerp(n_t, n_b, fy);

    return n;
}

float perlinNoise_3D(float3 p, float cellSize){
    
    //Interval between cells
    float i = 1.0 / cellSize;

    //Cell that point lies in
    float3 id = floor(p * cellSize) / cellSize;

    //Coordinates of cell corners in 3D
    float3 c000 = float3(id.x, id.y, id.z);
    float3 c001 = float3(id.x, id.y, id.z + i);
    float3 c010 = float3(id.x, id.y + i, id.z);
    float3 c011 = float3(id.x, id.y + i, id.z + i);
    float3 c100 = float3(id.x + i, id.y, id.z);
    float3 c101 = float3(id.x + i, id.y, id.z + i);
    float3 c110 = float3(id.x + i, id.y + i, id.z);
    float3 c111 = float3(id.x + i, id.y + i, id.z + i);

    //Vectors from corners to point
    float3 v000 = remap_f3(p - c000, 0, i, 0, 1);
    float3 v001 = remap_f3(p - c001, 0, i, 0, 1);
    float3 v010 = remap_f3(p - c010, 0, i, 0, 1);
    float3 v011 = remap_f3(p - c011, 0, i, 0, 1);
    float3 v100 = remap_f3(p - c100, 0, i, 0, 1);
    float3 v101 = remap_f3(p - c101, 0, i, 0, 1);
    float3 v110 = remap_f3(p - c110, 0, i, 0, 1);
    float3 v111 = remap_f3(p - c111, 0, i, 0, 1);

    //Gradient vectors at each corner of cell
    float3 gv000 = gradientVector_3D(c000);
    float3 gv001 = gradientVector_3D(c001);
    float3 gv010 = gradientVector_3D(c010);
    float3 gv011 = gradientVector_3D(c011);
    float3 gv100 = gradientVector_3D(c100);
    float3 gv101 = gradientVector_3D(c101);
    float3 gv110 = gradientVector_3D(c110);
    float3 gv111 = gradientVector_3D(c111);

    //Fade values
    float fx = fade(fract(p.x * cellSize));
    float fy = fade(fract(p.y * cellSize));
    float fz = fade(fract(p.z * cellSize));

    //Dot products
    float dot000 = dot(v000, gv000);
    float dot001 = dot(v001, gv001);
    float dot010 = dot(v010, gv010);
    float dot011 = dot(v011, gv011);
    float dot100 = dot(v100, gv100);
    float dot101 = dot(v101, gv101);
    float dot110 = dot(v110, gv110);
    float dot111 = dot(v111, gv111);

    //Trilinear interpolation
    float n1 = lerp(dot000, dot100, fx);
    float n2 = lerp(dot010, dot110, fx);
    float n3 = lerp(dot001, dot101, fx);
    float n4 = lerp(dot011, dot111, fx);

    float n5 = lerp(n1, n2, fy);
    float n6 = lerp(n3, n4, fy);

    float n = lerp(n5, n6, fz);

    return n;
}

uint seedCount = 0;
float whiteNoise_2D(float2 p, uint seedOffset){
    int seed = seedGen_ui2(uint2(uint(p.x * _ScreenParams.x), uint(p.y * _ScreenParams.y)));
    seedCount++;
    return normalize_ui(pcgHash_ui(seed * seedOffset + seedCount));
}

#endif