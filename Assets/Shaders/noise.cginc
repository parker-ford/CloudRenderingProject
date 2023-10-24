//TODO: Only include this if not already included
#include "./shaderUtils.cginc"

int seedGen_i3(int3 input){
    int seed1 = input.x * 2654435761;
    int seed2 = input.y * 2246822519;
    int seed3 = input.z * 3266489917;

    return seed1 + seed2 + seed3;
}

int seedGen_i2(int2 input){
    int seed1 = input.x * 2654435761;
    int seed2 = input.y * 2246822519;

    return seed1 + seed2;
}


float2 gradientVector(float2 input){

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

    int seed = seedGen_i2(input);
    int r = pcgHash_i(seed);
    r = pcgHash_i(r);
    float2 v = vectors[r & 7];

    return v;
}

float fade(float x){
    return ((6.*x - 15.)*x + 10.)*x*x*x;
}

float perlinNoise(float2 p, float cellSize) {
    
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
    float v_tl = remap_f2(float2(p.x - id.x, p.y - id.y), 0.0, i, 0.0, 1.0);
    float v_tr = remap_f2(float2(p.x - id.x - i, p.y - id.y), 0.0, i, 0.0, 1.0);
    float v_bl = remap_f2(float2(p.x - id.x, p.y - id.y - i), 0.0, i, 0.0, 1.0);
    float v_br = remap_f2(float2(p.x - id.x - i, p.y - id.y - i), 0.0, i, 0.0, 1.0);

    //Gradient vectors at each cell corner
    float2 gv_tl = gradientVector(tl);
    float2 gv_tr = gradientVector(tr);
    float2 gv_bl = gradientVector(bl);
    float2 gv_br = gradientVector(br);

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