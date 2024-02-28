Shader "Parker/PixelSuperSampling"
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
            float _RayOffsetWeight;

            float3 getCameraOriginInWorldLocal(){
                //Transform Camera Position to world space;
                float3 camOrigin = float3(0,0,0);
                float4 camWorldHomog = mul(unity_CameraToWorld, float4(camOrigin, 1.0));
                float3 camWorld = camWorldHomog.xyz / camWorldHomog.w;
                return camWorld;
            }

            float3 getPixelRayInWorldLocal(float2 uv){

                //Move uv to center
                uv += float2((1.0 / _ScreenParams.x) * 0.5 , (1.0 / _ScreenParams.y) * 0.5);

                float2 offset;
                // offset = float2((1.0 / _ScreenParams.x) * (random() - 0.5) , (1.0 / _ScreenParams.x) * (random() - 0.5));
                offset = float2((1.0 / _ScreenParams.x), -(1.0 / _ScreenParams.y));
                offset *= _RayOffsetWeight;
                uv += offset;

                //uv = float2(uv.x + (1. / _ScreenParams.x) * random(), uv.y + (1. / _ScreenParams.y) * random());

                //Convert to screen space uv (-1 - 1)
                uv = remap_f2(uv, 0, 1, -1, 1);

                //Account for aspect ratio and FOV
                uv *= tan_d(_CameraFOV * 0.5);
                uv.x *= _CameraAspect;

                //Get ray
                //TODO: Test if the z component should be -1 or 1
                float3 ray = normalize(float3(uv.x, uv.y, 1.0));


                //Transform ray to world space
                float4 rayWorldHomog = mul(unity_CameraToWorld, float4(ray, 0.0));
                float3 rayWorld = normalize(rayWorldHomog.xyz);

                return rayWorld;

            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 mainColor = tex2D(_MainTex, i.uv);
                float3 origin = getCameraOriginInWorldLocal();
                float3 ray = getPixelRayInWorldLocal(i.uv);

                float3 spherePos = float3(0,0,5);
                float sphereRadius = 1;

                intersectData intersect = sphereIntersection(origin, ray, spherePos, sphereRadius);

                if(intersect.intersects){
                    return float4(1,0,0,1);
                }


                return mainColor;
            }
            ENDCG
        }
    }
}
