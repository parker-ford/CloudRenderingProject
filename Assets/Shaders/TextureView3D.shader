Shader "Parker/TextureView3D"
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
            sampler3D _TextureView;
            float _Slice;
            int _Channel;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex3D(_TextureView, float3(i.uv, _Slice));
                if(_Channel == 0){
                    col = float4(col.r, col.r, col.r, 1.0);
                }
                if(_Channel == 1){
                    col = float4(col.g, col.g, col.g, 1.0);
                }
                if(_Channel == 2){
                    col = float4(col.b, col.b, col.b, 1.0);
                }
                if(_Channel == 3){
                    col = float4(col.a, col.a, col.a, 1.0);
                }
                return col;
            }
            ENDCG
        }
    }
}
