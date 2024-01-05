#ifndef _SHADERUTILS_CGINC_
#define _SHADERUTILS_CGINC_


#define PI 3.14159265359
#define MAX_INT 2147483647
#define MAX_UINT 4294967295

uint g_pixelID = 0u;

//TODO: Add source for this
uint pcgHash_ui(uint state){
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}

void setPixelID(float2 uv){
    float2 pixelPosition = float2(uv.x * _ScreenParams.x, uv.y * _ScreenParams.y);
    uint x = uint(pixelPosition.x);
    uint y = uint(pixelPosition.y);
    g_pixelID = pcgHash_ui(x) + pcgHash_ui(y);

}

float remap_f(float value, float in_min, float in_max, float out_min, float out_max){
    return out_min + (((value - in_min) / (in_max - in_min)) * (out_max - out_min));
}

float2 remap_f2(float2 value,float in_min, float in_max, float out_min, float out_max){
    float2 v = float2(0,0);
    v.x = remap_f(value.x, in_min, in_max, out_min, out_max);
    v.y = remap_f(value.y, in_min, in_max, out_min, out_max);
    return v;
}

float3 remap_f3(float3 value, float in_min, float in_max, float out_min, float out_max){
    float3 v = float3(0,0,0);
    v.x = remap_f(value.x, in_min, in_max, out_min, out_max);
    v.y = remap_f(value.y, in_min, in_max, out_min, out_max);
    v.z = remap_f(value.z, in_min, in_max, out_min, out_max);
    return v;
}

float tan_d(float deg){
    float rad = deg * (PI / 180.0);
    return tan(rad);
}

float normalize_ui(uint input){
    return float(input) / 4294967295.0;
}

uint randomIterations = 12345u;
float random(){
    randomIterations++;
    return normalize_ui(pcgHash_ui(g_pixelID + randomIterations));
}
float random(uint i){
    randomIterations++;
    return normalize_ui(pcgHash_ui(i * randomIterations));
}
float2 random_2D(uint i){
    uint r1 = pcgHash_ui(i);
    uint r2 = pcgHash_ui(r1);
    uint r3 = pcgHash_ui(r2);

    return float2(normalize_ui(r3), normalize_ui(r2));
}


float fract(float input){
    return input - floor(input);
}

int checkBit(int options, int bit){
    return options & bit;
}


#endif

