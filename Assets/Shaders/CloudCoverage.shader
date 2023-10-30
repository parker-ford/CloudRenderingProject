Shader "Parker/CloudCoverage"
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
            #include "./noise.cginc"

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
            float _NodeSize1;
            float _NodeSize2;
            float _NodeSize3;
            float _NodeWeight1;
            float _NodeWeight2;
            float _NodeWeight3;


            fixed4 frag (v2f i) : SV_Target
            {
                float noise = 0;
                noise += perlinNoise(i.uv, _NodeSize1) * _NodeWeight1;
                noise += perlinNoise(i.uv, _NodeSize2) * _NodeWeight2;
                noise += perlinNoise(i.uv, _NodeSize3) * _NodeWeight3;
                // noise = (noise + 1.0) / 2.0;
                
                return fixed4(noise, noise, noise, 1.0);
            }
            ENDCG
        }
    }
}
