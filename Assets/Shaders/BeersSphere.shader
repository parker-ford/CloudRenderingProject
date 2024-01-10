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

            float3 _SphereCenter;
            float _SphereRadius;
            float _SphereDensity;
            int _DensitySteps;
            int _LightSteps;
            float3 _LightDirection;

            //This function should aproximate distsance
            float getLightInformation(float3 origin){
                float density = 0;
                for(int i = 0; i < 5; i++){
                    float3 pos = getMarchPosition(origin, _LightDirection, 0, float(i), 0.2f);
                    if(length(pos - _SphereCenter) < _SphereRadius){
                        density += (1 - density) * _SphereDensity;
                    }
                }

                return density;
            }


            float4 getRayColor(v2f i){
                float4 mainCol = tex2D(_MainTex, i.uv);
                float4 color = float4(1.0, 0.0, 0.0, 1.0);
                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();
                intersectData sphereIntersect = sphereIntersection(rayOrigin, rayDir, _SphereCenter, _SphereRadius);
                if(sphereIntersect.intersects){
                    float dist = sphereIntersect.intersectPoints.y - sphereIntersect.intersectPoints.x;
                    // float distPerStep = dist / (float)_MarchSteps;
                    float distPerStep = 0.1;
                    float density = 0;
                    float light = 0;
                    float totalOcularDepth = 0;
                    for(int j = 0; j < _MarchSteps; j++){
                        float3 pos = getMarchPosition(rayOrigin, rayDir, sphereIntersect.intersectPoints.x, float(j), distPerStep);
                        if(length(pos - _SphereCenter) < _SphereRadius){
                            density += (1 - density) * _SphereDensity;
                            light += (1 - light) * getLightInformation(pos);
                        }
                    }
                    // return float4(exp(-light), 0, 0, 1);
                    //return lerp(mainCol, color * exp(-light), density);
                    return float4(light, light, light, 1.0);
                }

                return mainCol;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                setPixelID(i.uv);
                float4 color = float4(0,0,0,0);
                for(int j = 0; j < _RayPerPixel; j++){
                    color += getRayColor(i);
                }
                return color / (float)_RayPerPixel;

            }
            ENDCG
        }
    }
}
