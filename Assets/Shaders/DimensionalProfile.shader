Shader "Parker/DimensionalProfile"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CloudCoverage ("CloudCoverage", 2D) = "white" {}
        _CloudType ("CloudCoverage", 2D) = "white" {}
        _CloudGradient ("CloudCoverage", 2D) = "white" {}
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
            #include "ray.cginc"

            #define ATMOSPHERE_LOWER_BOUND 100.0
            #define ATMOSPHERE_UPPER_BOUND 300.0

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

            sampler2D _MainTex;
            sampler2D _CloudCoverage;
            sampler2D _CloudType;
            sampler2D _CloudGradient;

            fixed4 getRayColor (v2f i)
            {
                
                fixed4 mainCol = tex2D(_MainTex, i.uv);
                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();
                float maxDist = 5000;

                intersectData planeIntersectLower = planeIntersection(rayOrigin, rayDir, float3(0,ATMOSPHERE_LOWER_BOUND,0), float3(0,-1,0));
                intersectData planeIntersectUpper = planeIntersection(rayOrigin, rayDir, float3(0,ATMOSPHERE_UPPER_BOUND,0), float3(0,-1,0));
//
                if(planeIntersectLower.intersects && planeIntersectUpper.intersects){
                    float3 startPos = rayOrigin + rayDir * planeIntersectLower.intersectPoints.x;
                    float3 endPos = rayOrigin + rayDir * planeIntersectUpper.intersectPoints.x;
                    float dist = length(endPos - startPos);
                    float distPerStep = dist / (float)_MarchSteps;
                    float cloudDensity = 0;
                    float4 cloudCol = float4(1,1,1,1);
                    if(length(startPos) < maxDist){
                        [unroll(50)]
                        for(int j = 0; j < _MarchSteps; j++){
                            float3 pos = getMarchPosition(rayOrigin, rayDir, planeIntersectLower.intersectPoints.x , float(j), distPerStep);
                            float3 samplePos;
                            samplePos.x = remap_f(pos.x, -512.0, 512.0, 0.0, 1.0);
                            samplePos.z = remap_f(pos.z, -512.0, 512.0, 0.0, 1.0);
                            samplePos.y = remap_f(pos.y, ATMOSPHERE_LOWER_BOUND, ATMOSPHERE_UPPER_BOUND, 0.0, 1.0);
                            float coverageDensitySample = tex2D(_CloudCoverage, samplePos.xz).x;
                            float typeSample = tex2D(_CloudType, samplePos.xz).x;
                            float heightDensitySample = tex2D(_CloudGradient, float2(typeSample, samplePos.y));
                            cloudDensity += (1 - cloudDensity) * coverageDensitySample * heightDensitySample;
                        }

                        return lerp(mainCol, cloudCol, cloudDensity);
                    }
                }

                return mainCol;
            }


            fixed4 frag (v2f i) : SV_Target{
                setPixelID(i.uv);
                float4 color = 0;
                for(int j = 0; j < _RayPerPixel; j++){
                    color += getRayColor(i);
                }

                return color / (float)_RayPerPixel;
            }

            ENDCG
        }
    }
}
