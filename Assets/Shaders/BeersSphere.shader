Shader "Parker/BeersSphere"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            float3 _SpherePosition;
            float _SphereRadius;
            float _SphereDensity;
            int _DensitySteps;
            int _LightSteps;

            float3 _LightDirection;

            float densityToLight(float3 pos){
                float dist = 2.0;
                float distPerStep = dist / (float)_LightSteps;

                float distToEdge = 0;
                float density = 0;

                for(int j = 0; j < _LightSteps; j++){
                    float3 newPos = pos + _LightDirection * distPerStep * (float) j;
                    if(length(newPos - _SpherePosition) < _SphereRadius){
                        density += _SphereDensity;
                    }
                }

                return density;

            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();
                intersectData sphereIntersect = sphereIntersection(rayOrigin, rayDir, _SpherePosition, _SphereRadius);
                if(sphereIntersect.intersects){

                    float dist = length(sphereIntersect.intersectPoints.y - sphereIntersect.intersectPoints.x);
                    float distPerStep = dist / (float) _DensitySteps;
                    float sampledDensity = 1.0;
                    float totalLight = 0.0;

                    for(int j = 0; j < _DensitySteps; j++){
                        float3 pos = rayOrigin + rayDir * (sphereIntersect.intersectPoints.x + distPerStep * (float) j);
                        sampledDensity *=  exp(-(dist/(float)_DensitySteps) * _SphereDensity);
                        float lightAmount = densityToLight(pos);
                        totalLight += lightAmount * (((float) _DensitySteps - (float) j)/ (float)_DensitySteps);
                    }
                    float4 color = float4(1,0,0,1) * exp(totalLight);
                    return lerp(color, tex2D(_MainTex, i.uv), sampledDensity);
                }

                return tex2D(_MainTex, i.uv);

                // float3 origin = float3(0,0.1,0);
                // float3 direction = float3(0,1,0);

                // float3 c = float3(0,0,0);
                // float r = 0.5;

                // intersectData sphereIntersect = sphereIntersection(origin, direction, c, r);
                // if(sphereIntersect.intersects){
                //     // return float4(1,0,0,1);
                //     return float4(origin + direction * sphereIntersect.intersectPoints.x, 1.0);
                // }

                // return float4(1,0,1,1);
            }
            ENDCG
        }
    }
}
