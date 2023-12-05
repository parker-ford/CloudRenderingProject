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

            fixed4 frag (v2f i) : SV_Target
            {
                setPixelID(i.uv);
                fixed4 mainCol = tex2D(_MainTex, i.uv);
                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();
                float maxDist = 5000;

                intersectData planeIntersect = planeIntersection(rayOrigin, rayDir, float3(0,100,0), float3(0,-1,0));

                if(planeIntersect.intersects){
                   float3 startPos = rayOrigin + rayDir * planeIntersect.intersectPoints.x;
                   if(length(startPos) < maxDist){
                    float2 samplePos = remap_f2(startPos.xz, -512, 512, 0, 1);
                    return tex2D(_CloudCoverage, samplePos);
                   }
                }

                return mainCol;
            }
            ENDCG
        }
    }
}
