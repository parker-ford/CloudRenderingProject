
#define PI 3.14159265359

float remap_f(float value, float in_min, float in_max, float out_min, float out_max){
    return (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

float2 remap_f2(float2 value,float in_min, float in_max, float out_min, float out_max){
    float2 v = float2(0,0);
    v.x = remap_f(value.x, in_min, in_max, out_min, out_max);
    v.y = remap_f(value.y, in_min, in_max, out_min, out_max);
    return v;
}

float tan_d(float deg){
    float rad = deg * (PI / 180.0);
    return tan(rad);
}

//TODO: Add source for this
int pcgHash_i(int state){
    int word = ((state >> ((state >> 28) + 4)) ^ state) * 277803737;
    return (word >> 22) ^ word;
}

