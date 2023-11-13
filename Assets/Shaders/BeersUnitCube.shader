Shader "Parker/BeersUnitCube"
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

            fixed4 frag (v2f i) : SV_Target
            {
                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();

                intersectData uci = intersectUnitCube(rayOrigin, rayDir);

                int dist = 0;


                if(uci.intersects){
                    dist = length(uci.intersectPoints.x - uci.intersectPoints.y);
                }

                return lerp(tex2D(_MainTex, i.uv), float4(1.0, 0.0, 0.0, 1.0), dist * 0.25);

            }
            ENDCG
        }
    }
}
