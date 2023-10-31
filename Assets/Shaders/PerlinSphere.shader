Shader "Parker/PerlinSphere"
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
            float3 _SpherePosition;
            float _SphereRadius;

            fixed4 frag (v2f i) : SV_Target
            {
                float3 dir = getPixelRayInWorld(i.uv);
                float3 o = getCameraOriginInWorld();
                //ray equation {p = o + dt}
                //sphere equation {(p-c)^2 = r^2}
                //plug in {((o + dt) - c)^2 = r^2}
                //rearrange {(d*d)t^2 + 2(d(o-c))t + (o - c)(o - c)-r^2 = 0 }
                //a = d*d
                //b = 2d * (o-c)
                //c = (o-c)^2 - r^2
                //t = (-b+-sqrt(b^2-4ac)) / 2a
                //if b^2 is > 0 there are two real solution
                // if b^2 is == 0, one solution, tangent
                // else there are no solutions

                float3 L = _SpherePosition - o;
                float a = 1.0f; //assuming that dir is normalized, should be dot(dir, dir);
                float b = 2.0f * dot(dir, L);
                float c = dot(L,L) - (_SphereRadius * _SphereRadius);
                float discrim = b * b - 4.0f * a * c;
                float test = discrim < 0.0f ? 0.0f : 1.0f;
                // //if(discrim > 0){
                //     float q = (b > 0) ? -0.5 * (b + sqrt(discrim)) : -0.5 * (b - sqrt(discrim));

                // //}
                // float x0 = q / a;
                // float x1 = c / q;
                // float t = 0;
                // if(x0 < 0 && x1 < 0){
                //     t = 0;
                // }
                // else if(x1 < 0){
                //     t = x0;
                // }
                // else if(x0 < 0){
                //     t = x1;
                // }
                // else{
                //     t = min(x0, x1);
                // }

                float3 col = lerp(tex2D(_MainTex, i.uv), float3(1,0,0) * test, 0.5f);
                // return fixed4(_CameraFOV - 60.0, 0, 0, 1.0);
                return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}
