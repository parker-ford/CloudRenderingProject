#ifndef _RAY_CGINC_
#define _RAY_CGINC_

#include "./shaderUtils.cginc"
#include "./noise.cginc"

#define RANDOM_BIT 1
#define INTERVAL_BIT 2

float _CameraAspect;
float _CameraFOV;
int _MarchSteps;
int _RayPerPixel;
int _RaycastOptions;

float3 getPixelRayInWorld(float2 uv){

    //Shift uv by random amount
    if(checkBit(_RaycastOptions, RANDOM_BIT)){
        uv = float2(uv.x + (1. / _ScreenParams.x) * random(), uv.y + (1. / _ScreenParams.y) * random());
    }

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

struct intersectData{
    bool intersects;
    float2 intersectPoints;

};

intersectData intersectUnitCube(float3 rayOrigin, float3 rayDir){
    //This code will only work for unit cube with no rotation
    float3 up = float3(0.0, 1.0, 0.0);
    float3 right = float3(1.0, 0.0, 0.0);
    float3 forward = float3(0.0, 0.0, 1.0);

    float3 cubeFaceVectors[6][3];

    cubeFaceVectors[0][0] = up;
    cubeFaceVectors[0][1] = forward;
    cubeFaceVectors[0][2] = right;

    cubeFaceVectors[1][0] = -up;
    cubeFaceVectors[1][1] = forward;
    cubeFaceVectors[1][2] = right;

    cubeFaceVectors[2][0] = forward;
    cubeFaceVectors[2][1] = up;
    cubeFaceVectors[2][2] = right;

    cubeFaceVectors[3][0] = -forward;
    cubeFaceVectors[3][1] = up;
    cubeFaceVectors[3][2] = right;

    cubeFaceVectors[4][0] = right;
    cubeFaceVectors[4][1] = up;
    cubeFaceVectors[4][2] = forward;

    cubeFaceVectors[5][0] = -right;
    cubeFaceVectors[5][1] = up;
    cubeFaceVectors[5][2] = forward;

    float scale = 0.5f;
    float3 cubePosition = float3(0,0,0);

    float intersectPoints[2];
    int foundPoints = 0;

    for(int i = 0; i < 6; i++){
        float3 n = cubeFaceVectors[i][0];
        float3 u = cubeFaceVectors[i][1];
        float3 v = cubeFaceVectors[i][2];

        float3 p = cubePosition + n * scale;
        float t = dot(n, p - rayOrigin) / dot(n, rayDir);
        
        float3 pos = rayOrigin + rayDir * t;
        float pos_u = dot(pos - p, u);
        float pos_v = dot(pos - p, v);

        if(abs(pos_u) < scale && abs(pos_v) < scale){
            if(foundPoints < 2 && t > 0){
                intersectPoints[foundPoints] = t;
                foundPoints++;
            }
        }
    }

    intersectData result;
    result.intersects = false;
    result.intersectPoints = float2(0,0);
    
    if(foundPoints == 2){
        result.intersects = true;
        result.intersectPoints.x = min(intersectPoints[0],intersectPoints[1]);
        result.intersectPoints.x = max(intersectPoints[0],intersectPoints[1]);
    }

    return result; 

}

intersectData sphereIntersection(float3 rayOrigin, float3 rayDirection, float3 center, float radius){
    
    intersectData result;
    result.intersects = false;
    result.intersectPoints = float2(0,0);

    //Vector from ray origin to center of sphere
    float3 L = center - rayOrigin;

    //projected point from sphere center to view ray
    float tc = dot(L, normalize(rayDirection));

    //If tc is negative we know the ray does not intersect and can return early
    if(tc < 0){
        return result;
    }

    //Distance from center of sphere to view ray
    float d = sqrt((length(L) * length(L)) - (tc * tc));

    //If d is greater than the radius, we know that the ray does not intersect and we can return early
    if(d > radius){
        return result;
    }

    //The distance from the edge of the sphere to the projected point
    float t1c = sqrt(pow(radius,2) - pow(d,2));

    //The final distances for the intersect points
    result.intersectPoints.x = tc - t1c;
    result.intersectPoints.y = tc + t1c;
    result.intersects = true;

    return result;

}

intersectData planeIntersection(float3 rayOrigin, float3 rayDir, float3 pos, float3 n){
    intersectData result;
    result.intersects = false;
    result.intersectPoints = float2(0,0);

    float t = dot(n, pos - rayOrigin) / dot(n, rayDir);

    if(t > 0){
        result.intersects = true;
        result.intersectPoints = float2(t,t);
    }

    return result;

}


intersectData planeIntersection(float3 rayOrigin, float3 rayDir, float3 pos, float3 n, float3 up, float width, float height){
    intersectData result;
    result.intersects = false;
    result.intersectPoints = float2(0,0);

    float t = dot(n, pos - rayOrigin) / dot(n, rayDir);

    if(t > 0){

        float3 right = cross(up, n);

        float3 p = rayOrigin + rayDir * t;
        float pos_up = dot(p - pos, up);
        float pos_right = dot(p - pos, right);

        if(abs(pos_up) < height && abs(pos_right) < width){
            result.intersects = true;
            result.intersectPoints = float2(t,t);
        }

        
    }

    return result;

}

float3 getMarchPosition(float3 origin, float3 direction, float intersectionDist, float iteration, float distPerStep){
    float3 pos;
    if(checkBit(_RaycastOptions, RANDOM_BIT)){
        if(checkBit(_RaycastOptions, INTERVAL_BIT)){
            float distSoFar = ((iteration * (iteration + 1)) / _MarchSteps);
            float distConst = ((2*_MarchSteps) / (_MarchSteps + 1));
            float distThisStep = distSoFar * distConst;
            pos = origin + direction * (intersectionDist + (distPerStep * distThisStep) + (random() * distPerStep));
        }
        else{
            pos = origin + direction * (intersectionDist + (distPerStep * iteration) + (random() * distPerStep));
        }
    }
    else{
        if(checkBit(_RaycastOptions, INTERVAL_BIT)){
            float distSoFar = ((iteration * (iteration + 1)) / _MarchSteps);
            float distConst = ((2*_MarchSteps) / (_MarchSteps + 1));
            float distThisStep = distSoFar * distConst;
            pos = origin + direction * (intersectionDist + (distPerStep * distThisStep));
        }
        else{
            pos = origin + direction * (intersectionDist + (distPerStep * iteration));
        }
    }

    return pos;
}

float3 getMarchPosition(float3 origin, float3 direction, float intersectionDist, float iteration, float distPerStep, float totalFactor){
    
}


#endif