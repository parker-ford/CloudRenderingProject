Shader "Parker/CloudCube"
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

            sampler2D _MainTex;
            float3 _CubePosition;
            float _CubeLength;
            int _CubeOptions;
            float _Absorption;

            float4 cubeRayIntersection(v2f i){
                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();
                fixed4 mainCol = tex2D(_MainTex, i.uv);
                float4 cubeCol = float4(0,1,0,1);
                intersectData cubeIntersect = cubeIntersection(rayOrigin, rayDir, _CubePosition, _CubeLength);
                if(cubeIntersect.intersects){
                    return cubeCol;
                }


                return mainCol;
            }

            float4 cubeConstantBeerLaw(v2f i){
                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();
                fixed4 mainCol = tex2D(_MainTex, i.uv);
                float4 cubeCol = float4(1,1,0,1);
                intersectData cubeIntersect = cubeIntersection(rayOrigin, rayDir, _CubePosition, _CubeLength);
                float density = 0;
                if(cubeIntersect.intersects){
                    float3 enterPoint = rayOrigin + rayDir * cubeIntersect.intersectPoints.x;
                    float3 exitPoint = rayOrigin + rayDir * cubeIntersect.intersectPoints.y;
                    float distance = length(exitPoint - enterPoint);
                    density = 1 - exp(-distance * _Absorption);

                }
                return lerp(mainCol, cubeCol, density);
            }

            float4 getRayColor(v2f i){

                if(_CubeOptions == 0){
                    return cubeRayIntersection(i);
                }
                else if(_CubeOptions == 1){
                    return cubeConstantBeerLaw(i);
                }

                return float4(0,0,0,0);
            }

            fixed4 frag (v2f i) : SV_Target
            {

                setPixelID(i.uv);
                float4 color = 0;
                 for(int j = 0; j < _RayPerPixel; j++){
                    color += getRayColor(i);
                }

                return color / _RayPerPixel;
            }
            ENDCG
        }
    }
}
