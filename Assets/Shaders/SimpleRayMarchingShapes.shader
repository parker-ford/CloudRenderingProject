Shader "Hidden/SimpleRayMarchingShapes"
{
    Properties
    {

    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "./shaderUtils.cginc"

            #define PI 3.14159265359

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float3 _CameraPosition;
            float3 _CameraOrientation;
            float _CameraFOV;
            float _CameraAspect;
            float _CameraNearPlane;


            float3 getPixelRayDir(float2 uv, float imageHeight, float imageWidth){
                float3 ray = float3(uv.x * (imageWidth / 2.), uv.y * (imageHeight / 2.), _CameraNearPlane);
                return normalize(ray);
            }

            float distanceFromSphere(float3 p, float3 c, float r){
                return length(c - p) - r;
            }

            float3 rayMarch(float3 p, float3 dir){

                const int STEPS = 32;
                const float MIN_HIT = 0.0001;
                const float MAX_DIST = 1000.;

                float distanceTraveled = 0;

                for(int i = 0; i < STEPS; i++){
                    float3 currentSample = p + distanceTraveled * dir;

                    float distnaceToClosest = distanceFromSphere(currentSample, float3(0., 1., 3.), 1.);

                    if(distnaceToClosest <= MIN_HIT){
                        return float3(1., 0., 0.);
                    }

                    if(distanceTraveled >= MAX_DIST){
                        break;
                    }

                    distanceTraveled += distnaceToClosest;

                }

                return float3(0., 0., 0.);

            }

            fixed4 frag (v2f i) : SV_Target
            {

                float imageHeight = 2. * (tan(_CameraFOV * (PI / 180.)) * _CameraNearPlane);
                float imageWidth = _CameraAspect * imageHeight;
                float3 pixelDir = getPixelRayDir(remap_f2(i.uv, 0., 1., -1., 1.), imageHeight, imageWidth);

                // return fixed4(_CameraFOV, 0., 0., 1.0);
                return fixed4(rayMarch(_CameraPosition, pixelDir), 1.);
            }


            ENDCG
        }
    }
}
