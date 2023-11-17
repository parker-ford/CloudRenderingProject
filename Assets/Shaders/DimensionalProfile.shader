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

                intersectData planeIntersect = planeIntersection(rayOrigin, rayDir, planePosition, planeNormal);

                if(planeIntersect.intersects ){
                    float3 startPos = rayOrigin + rayDir * planeIntersect.intersectPoints.x;
                    if(length(startPos - rayOrigin) < _MaxViewDistance){
                        return tex2D(_CloudCoverage, remap_f2(startPos.xz, -_MaxViewDistance, _MaxViewDistance, 0.0, 1.1));
                    }
                }
                
                return mainCol;
            }
            ENDCG
        }
    }
}
