Shader "Parker/CloudType"
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
            #include "./shaderUtils.cginc"

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
                float val = 0;
                // val += (sin(i.uv.x * 25) + 1.0) / 8.0f;
                // val += (cos(i.uv.y * 18) + 0.0) / 8.0f;
                float2 uv = i.uv;
                uv = remap_f2(uv, 0, 1, -1, 1);
                val += (sin(length(uv * 10)) + 1.0) * 0.5f  * 0.25f;
                uv += float2(0.3f, -0.6f);
                val += (sin(length(uv * 10)) + 1.0) * 0.5f  * 0.25f;
                uv += float2(-0.8f, 0.3f);
                val += (sin(length(uv * 10)) + 1.0) * 0.5f  * 0.25f;

                return fixed4(val, val, val, 1);
            }
            ENDCG
        }
    }
}
