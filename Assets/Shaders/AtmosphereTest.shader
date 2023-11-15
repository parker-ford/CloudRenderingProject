Shader "Parker/AtmosphereTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TestTex ("Test Texture", 2D) = "white" {}
        _CloudCoverage ("Cloud Coverage Texture", 2D) = "white"
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
            sampler2D _TestTex;
            sampler2D _CloudCoverage;

            float3 _PlanePosition;
            float3 _PlaneNormal;
            float3 _PlaneRight;
            float3 _PlaneUp;
            float _PlaneHeight;
            float _PlaneWidth;
            float _AtmosphereHeight;
            float _DensityMultiplier;

            int _NumSteps;
            int _TestMode;

            float4 renderTestTexture(v2f i){
                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();
                float dist = _AtmosphereHeight;
                float distPerStep = dist / (float)_NumSteps;

                float4 color = tex2D(_MainTex, i.uv);

                for(int j = 0; j < _NumSteps; j++){
                    intersectData planeIntersect = planeIntersection(rayOrigin, rayDir, _PlanePosition + float3(0, (float)j * distPerStep, 0), _PlaneNormal, _PlaneUp, _PlaneWidth, _PlaneHeight);
                    float4 sampleCol = color;
                    if(planeIntersect.intersects){
                        float3 pos = rayOrigin + rayDir * planeIntersect.intersectPoints.x;
                        float2 samplePos;
                        samplePos.x = remap_f(dot(pos - _PlanePosition +  float3(0, (float)j * distPerStep, 0), _PlaneRight) , -_PlaneWidth, _PlaneWidth, 0.0, 1.0);
                        samplePos.y = remap_f(dot(pos - _PlanePosition +  float3(0, (float)j * distPerStep, 0), _PlaneUp), -_PlaneHeight, _PlaneHeight, 0.0, 1.0);
                        sampleCol = tex2D(_TestTex, samplePos);
                    }
                    color = lerp(color, sampleCol, 1.0 / (float) _NumSteps);
                }
                return color;
            }

            float4 renderCloudCoverageTexture(v2f i){
                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();
                float dist = _AtmosphereHeight;
                float distPerStep = dist / (float)_NumSteps;

                float4 color = tex2D(_MainTex, i.uv);

                for(int j = 0; j < _NumSteps; j++){
                    intersectData planeIntersect = planeIntersection(rayOrigin, rayDir, _PlanePosition + float3(0, (float)j * distPerStep, 0), _PlaneNormal, _PlaneUp, _PlaneWidth, _PlaneHeight);
                    float4 sampleCol = color;
                    if(planeIntersect.intersects){
                        float3 pos = rayOrigin + rayDir * planeIntersect.intersectPoints.x;
                        float2 samplePos;
                        samplePos.x = remap_f(dot(pos - _PlanePosition +  float3(0, (float)j * distPerStep, 0), _PlaneRight) , -_PlaneWidth, _PlaneWidth, 0.0, 1.0);
                        samplePos.y = remap_f(dot(pos - _PlanePosition +  float3(0, (float)j * distPerStep, 0), _PlaneUp), -_PlaneHeight, _PlaneHeight, 0.0, 1.0);
                        sampleCol = tex2D(_CloudCoverage, samplePos);
                    }
                    
                    color = lerp(color, sampleCol, 1.0 / (float) _NumSteps);
                }
                return color;

            }

            float4 renderCloudCoverage(v2f i){
                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();
                float dist = _AtmosphereHeight;
                float distPerStep = dist / (float)_NumSteps;
                float4 mainColor = tex2D(_MainTex, i.uv);
                float4 cloudColor = float4(1,1,1,0);
                float densitySample = 0;

                intersectData planeIntersect = planeIntersection(rayOrigin, rayDir, _PlanePosition, _PlaneNormal, _PlaneUp, _PlaneWidth, _PlaneHeight);

                for(int j = 0; j < _NumSteps; j++){
                    if(planeIntersect.intersects){

                        float3 pos = rayOrigin + rayDir * (planeIntersect.intersectPoints.x + distPerStep * j);
                        float2 samplePos;
                        samplePos.x = remap_f(dot(pos - _PlanePosition, _PlaneRight) , -_PlaneWidth, _PlaneWidth, 0.0, 1.0);
                        samplePos.y = remap_f(dot(pos - _PlanePosition, _PlaneUp), -_PlaneHeight, _PlaneHeight, 0.0, 1.0);
                        densitySample += tex2D(_CloudCoverage, samplePos).x;
                    }
                }

                return lerp(mainColor, cloudColor, densitySample * 1.0/(float)_NumSteps * _DensityMultiplier);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                if(_TestMode == 1){
                    return renderTestTexture(i);
                }
                else if(_TestMode == 2){
                    return renderCloudCoverageTexture(i);
                }
                else if(_TestMode == 3){
                    return renderCloudCoverage(i);
                }

                return fixed4(0,0,0,1);
            }
            ENDCG
        }
    }
}
