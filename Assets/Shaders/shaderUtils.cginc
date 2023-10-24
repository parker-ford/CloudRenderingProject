
#define PI 3.14159265359

float remap_f(float value, float in_min, float in_max, float out_min, float out_max){
    return (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

float2 remap_f2(float2 value,float in_min, float in_max, float out_min, float out_max){
    return float2(
        (value.x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min,
        (value.y - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
    );
}

float tan_d(float deg){
    float rad = deg * (PI / 180.0);
    return tan(rad);
}

