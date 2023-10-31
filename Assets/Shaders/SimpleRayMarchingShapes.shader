// Upgrade NOTE: commented out 'float4x4 _CameraToWorld', a built-in variable
// Upgrade NOTE: replaced '_CameraToWorld' with 'unity_CameraToWorld'

Shader "Parker/SimpleRayMarchingShapes"
{
    Properties
    {

    }
    SubShader
    { 

        // Blend SrcAlpha OneMinusSrcAlpha
        // ZWrite Off
        // ZTest Always
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "./shaderUtils.cginc"
            #include "./ray.cginc"

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
            
            float3 _SpherePosition;
            float _SphereRadius;

            float3 _LightDirection;

            sampler2D _MainTex;

            float distanceFromSphere(float3 p, float3 c, float r){
                return length(c - p) - r;
            }

            float worldDistance(float3 p){
                float sphere_0 = distanceFromSphere(p, _SpherePosition, _SphereRadius);
                //More shapes go here:

                return sphere_0;
            }

            float3 calculateNormal(float3 p){
                const float GRADIENT_STEP_SIZE = 0.001;
                float3 gradientStep = float3(GRADIENT_STEP_SIZE, 0.0, 0.0);

                float gradientX = worldDistance(p + gradientStep.xyy) - worldDistance(p - gradientStep.xyy);
                float gradientY = worldDistance(p + gradientStep.yxy) - worldDistance(p - gradientStep.yxy);
                float gradientZ = worldDistance(p + gradientStep.yyx) - worldDistance(p - gradientStep.yyx);

                return normalize(float3(gradientX, gradientY, gradientZ));
            }

            float4 rayMarch(float3 p, float3 dir){

                const int STEPS = 100;
                const float MIN_HIT = 0.001;
                const float MAX_DIST = 1000.;

                float distanceTraveled = 0;

                for(int i = 0; i < STEPS; i++){
                    float3 currentSample = p + distanceTraveled * dir;

                    float distanceToClosest = worldDistance(currentSample);

                    if(distanceToClosest <= MIN_HIT){
                        float3 normal = calculateNormal(currentSample);
                        float3 col = float3(1., 1., 1.) * clamp(dot(normal, _LightDirection), 0., 1.);
                        col += float3(1., 1., 1.) * 0.5;
                        return float4(col, 1.);
                    }

                    if(distanceTraveled >= MAX_DIST){
                        break;
                    }

                    distanceTraveled += distanceToClosest;

                }

                return float4(0., 0., 0., 0.);

            }


            fixed4 frag (v2f i) : SV_Target
            {
                //Get camera origin and pixel ray in world space
                float3 rayWorld = getPixelRayInWorld(i.uv);
                float3 camWorld = getCameraOriginInWorld();

                //Get color of ray march
                float4 c1 = rayMarch(camWorld, rayWorld);

                //Get color from main camera
                float4 c2 = tex2D(_MainTex, i.uv);

                //Render result of ray march over main camera
                return lerp(c2, c1, c1.a);
            }


            ENDCG
        }
    }
}
