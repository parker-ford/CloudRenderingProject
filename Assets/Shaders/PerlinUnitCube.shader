Shader "Parker/PerlinUnitCube"
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

            fixed4 frag (v2f i) : SV_Target
            {
                float3 dir = getPixelRayInWorld(i.uv);
                float3 o = getCameraOriginInWorld();

                //This code will only work for unit cube with no rotation
                float3 up = float3(0.0, 1.0, 0.0);
                float3 right = float3(1.0, 0.0, 0.0);
                float3 forward = float3(0.0, 0.0, 1.0);

                float3 cubeFaceVectors[6][3];

                cubeFaceVectors[0][0] = up;
                cubeFaceVectors[0][1] = forward;
                cubeFaceVectors[0][2] = right;

                cubeFaceVectors[1][0] = -up;
                cubeFaceVectors[1][1] = forward;
                cubeFaceVectors[1][2] = right;

                cubeFaceVectors[2][0] = forward;
                cubeFaceVectors[2][1] = up;
                cubeFaceVectors[2][2] = right;

                cubeFaceVectors[3][0] = -forward;
                cubeFaceVectors[3][1] = up;
                cubeFaceVectors[3][2] = right;

                cubeFaceVectors[4][0] = right;
                cubeFaceVectors[4][1] = up;
                cubeFaceVectors[4][2] = forward;

                cubeFaceVectors[5][0] = -right;
                cubeFaceVectors[5][1] = up;
                cubeFaceVectors[5][2] = forward;
                //

                float scale = 0.5f;
                float3 cubePosition = float3(0,0,0);

                float intersectPoints[2];
                int foundPoints = 0;

                for(int i = 0; i < 6; i++){
                    float3 n = cubeFaceVectors[i][0];
                    float3 u = cubeFaceVectors[i][1];
                    float3 v = cubeFaceVectors[i][2];

                    float3 p = cubePosition + n * scale;
                    float t = dot(n, p - o) / dot(n, dir);
                    
                    float3 pos = o + dir * t;
                    float pos_u = dot(pos - p, u);
                    float pos_v = dot(pos - p, v);

                    if(abs(pos_u) < scale && abs(pos_v) < scale){
                        if(foundPoints < 2){
                            intersectPoints[foundPoints] = t;
                            foundPoints++;
                        }
                    }

                }

                if(foundPoints == 2){

                    return fixed4(1.0,0,0,1);
                }

                return fixed4(0.0,0,0,1);
            }
            ENDCG
        }
    }
}
