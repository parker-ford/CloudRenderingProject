#include "./shaderUtils.cginc"

float _CameraAspect;
float _CameraFOV;

float3 getPixelRayInWorld(float2 uv){

    //TODO: Shift uv to center of pixel
    //uv = float2(uv.x + (1. / _ScreenParams.x), uv.y - (1. / _ScreenParams.y));

    //Convert to screen space uv (-1 - 1)
    uv = remap_f2(uv, 0, 1, -1, 1);

    //Account for aspect ratio and FOV
    uv *= tan_d(_CameraFOV * 0.5);
    uv.x *= _CameraAspect;

    //Get ray
    //TODO: Test if the z component should be -1 or 1
    float3 ray = normalize(float3(uv.x, uv.y, 1.0));

    //Transform ray to world space
    float4 rayWorldHomog = mul(unity_CameraToWorld, float4(ray, 0.0));
    float3 rayWorld = normalize(rayWorldHomog.xyz);

    return rayWorld;

}

float3 getCameraOriginInWorld(){
    //Transform Camera Position to world space;
    float3 camOrigin = float3(0,0,0);
    float4 camWorldHomog = mul(unity_CameraToWorld, float4(camOrigin, 1.0));
    float3 camWorld = camWorldHomog.xyz / camWorldHomog.w;
    return camWorld;
}