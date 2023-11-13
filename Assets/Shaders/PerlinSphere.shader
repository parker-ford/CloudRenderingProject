Shader "Parker/PerlinSphere"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Perlin3DTexture ("Perlin 3D Texture", 3D) = "" {}
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
            sampler3D _Perlin3DTexture;
            float4 _Perlin3DTexture_ST;

            fixed4 frag (v2f i) : SV_Target
            {
                //Get ray origin and direction
                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();

                intersectData sphereIntersect = sphereIntersection(rayOrigin, rayDir, float3(0,0,0), 0.5);

                if(sphereIntersect.intersects == true){
                    return lerp(tex2D(_MainTex, i.uv), float4(1.0, 0.0, 0.0, 1.0), sphereIntersect.intersectPoints.y - sphereIntersect.intersectPoints.x);
                } 


                return tex2D(_MainTex, i.uv);

            }
            ENDCG
        }
    }
}
