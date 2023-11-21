Shader "Parker/DimensionalProfile"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CloudCoverage ("CloudCoverage", 2D) = "white" {}
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

            float2 _AtmosphereDimensions;
            float _MaxViewDistance;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mainCol = tex2D(_MainTex, i.uv);

                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();

                float3 planePosition = _AtmosphereDimensions.x;
                float3 planeNormal = float3(0, -1, 0);

                int numSteps = 10;
                float spacingRatio = 1.8;

                intersectData planeIntersectBot = planeIntersection(rayOrigin, rayDir, _AtmosphereDimensions.x, planeNormal);
                intersectData planeIntersectTop = planeIntersection(rayOrigin, rayDir, _AtmosphereDimensions.y, planeNormal);

                if(planeIntersectBot.intersects ){
                    float3 startPos = rayOrigin + rayDir * planeIntersectBot.intersectPoints.x;
                    float3 endPos = rayOrigin + rayDir * planeIntersectTop.intersectPoints.x;
                    float dist = length(endPos - startPos);
                    if(length(startPos - rayOrigin) < _MaxViewDistance){
                        // /return tex2D(_CloudCoverage, remap_f2(startPos.xz, -_MaxViewDistance, _MaxViewDistance, 0.0, 1.1));
                        float totalFactor = 0;
                        for(int i = 0; i < numSteps; i++){
                            totalFactor += pow(spacingRatio, i);
                        }

                        float currentDistance = 0;
                        float density = 0;
                        for(int i = 0; i < numSteps; i++){
                            float3 pos = startPos + rayDir * currentDistance;

                            density += tex2D(_CloudCoverage, remap_f2(pos.xz, -_MaxViewDistance, _MaxViewDistance, 0.0, 1.0)).r;

                            float segment = dist * pow(spacingRatio, i) / totalFactor;
                            currentDistance += segment + 3.0f;
                        }

                        return lerp(mainCol, float4(1.0, 1.0, 1.0, 1.0), density * 100);
                    }
                }
                
                return mainCol;
            }
            ENDCG
        }
    }
}
