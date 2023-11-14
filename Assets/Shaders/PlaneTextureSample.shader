Shader "Parker/PlaneTextureSample"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Tex ("Texture", 2D) = "white" {}
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
            sampler2D _Tex;

            float3 _PlanePosition;
            float3 _PlaneNormal;
            float3 _PlaneRight;
            float3 _PlaneUp;
            float _PlaneHeight;
            float _PlaneWidth;
            int _OverlayOriginal;


            fixed4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0,0,0,1.0);
                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();
                intersectData planeIntersect = planeIntersection(rayOrigin, rayDir, _PlanePosition, _PlaneNormal, _PlaneUp, _PlaneWidth, _PlaneHeight);
                if(planeIntersect.intersects == true){
                    float3 pos = rayOrigin + rayDir * planeIntersect.intersectPoints.x;
                    float2 samplePos;
                    samplePos.x = remap_f(dot(pos - _PlanePosition, _PlaneRight) , -_PlaneWidth, _PlaneWidth, 0.0, 1.0);
                    samplePos.y = remap_f(dot(pos - _PlanePosition, _PlaneUp), -_PlaneHeight, _PlaneHeight, 0.0, 1.0);
                    // samplePos.x = remap_f(pos.x - _PlanePosition.x, -_PlaneWidth, _PlaneWidth, 0.0, 1.0);
                    // samplePos.y = remap_f(pos.y - _PlanePosition.y, -_PlaneHeight, _PlaneHeight, 0.0, 1.0);

                    color =  tex2D(_Tex, samplePos);
                    // return fixed4(1.0, 0.0, 0.0, 1.0);
                }

                if(_OverlayOriginal){
                    return lerp(tex2D(_MainTex, i.uv), color, 0.5);
                }
                return color;
            }
            ENDCG
        }
    }
}
