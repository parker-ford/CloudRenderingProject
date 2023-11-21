Shader "Parker/SphereIntersectTesting"
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
            #include "noise.cginc"

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

            int _OverlayOriginal;
            float3 _SphereCenter;
            float _SphereRadius;
            int _TestMode;
            int _MarchSteps;
            int _RayPerPixel;


            float4 getRayColor(v2f i){

                float4 color = float4(0.0, 0.0, 0.0, 1.0);
                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();
                intersectData sphereIntersect = sphereIntersection(rayOrigin, rayDir, _SphereCenter, _SphereRadius);
                
                if(sphereIntersect.intersects){
                    if(_TestMode == 1){
                        color = float4(1.0, 0.0, 0.0, 1.0);
                    }
                    if(_TestMode == 2){
                        float distToCenter = length(_SphereCenter - rayOrigin);
                        float offset = distToCenter - _SphereRadius;
                        float value = sphereIntersect.intersectPoints.x - offset;
                        color = float4(value, 0.0, 0.0, 1.0);
                    }
                    if(_TestMode == 3){
                        float offset = length(_SphereCenter - rayOrigin);
                        float value = sphereIntersect.intersectPoints.y - offset;
                        color = float4(value, 0.0, 0.0, 1.0);
                    }
                    if(_TestMode == 4){
                        float dist = sphereIntersect.intersectPoints.y - sphereIntersect.intersectPoints.x;
                        float distPerStep = dist / (float)_MarchSteps;
                        for(int j = 0; j < _MarchSteps; j++){
                            float3 pos = rayOrigin + rayDir * (sphereIntersect.intersectPoints.x + distPerStep * j);
                            float distToCenter = length(_SphereCenter - pos);
                            if(distToCenter < _SphereRadius * 0.2){
                                color += float4(1, 0, 0, 1);
                            }
                            else if(distToCenter < _SphereRadius * 0.4){
                                color += float4(0, 1, 0, 1);
                            }
                            else if(distToCenter < _SphereRadius * 0.6){
                                color += float4(0, 0, 1, 1);
                            }
                            else if(distToCenter < _SphereRadius * 0.8){
                                color += float4(1, 0, 1, 1);
                            }
                            else{
                                color += float4(0, 1, 1, 1);
                            }
                        }

                        color /= (float) _MarchSteps;
                    }
                }

                if(_OverlayOriginal){
                    return lerp(tex2D(_MainTex, i.uv), color, 0.5);
                }
                else{
                    return color;
                }
            }


            fixed4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0,0,0,0);
                for(int j = 0; j < _RayPerPixel; j++){
                    color += getRayColor(i);
                    //float noise = whiteNoise_2D(i.uv, _Time.y * 10 + (1000));
                    //color += float4(noise, noise, noise, 1.0);
                }

                return color / (float)_RayPerPixel;
                
            }
            ENDCG
        }
    }
}
