Shader "Parker/AntiAliasingTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlueNoise ("Blue Noise", 2D) = "white" {}
        _ImageTex ("Image Texture", 2D) = "white" {}
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

            #define GOLDEN_RATIO  1.61803398875

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
            sampler2D _BlueNoise;
            sampler2D _ImageTex;
            uint _Frame;
            int _NumSamples;
            int _Mode;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 pixel = i.uv * float2(_ScreenParams.x / 256.0, _ScreenParams.y / 256.0) + 0.5;
                float4 blueNoiseSample = tex2D(_BlueNoise, pixel);
                blueNoiseSample.r = fract(blueNoiseSample.r + float(_Frame % _NumSamples) * GOLDEN_RATIO);
                blueNoiseSample.g = fract(blueNoiseSample.g + (float(_Frame % _NumSamples) / float(_NumSamples)));



                // float2 imageSample = i.uv + _Time.y * 1.1;
                float2 imageSample = i.uv;

                if(_Mode == 0){
                    if(tex2D(_ImageTex, imageSample).r > blueNoiseSample.r){
                        return float4(1, 1, 1, 1);
                    }
                    else{
                        return float4(0, 0, 0, 1);
                    }
                }
                else if(_Mode == 1){
                    if(tex2D(_ImageTex, imageSample).r > blueNoiseSample.g){
                        return float4(1, 1, 1, 1);
                    }
                    else{
                        return float4(0, 0, 0, 1);
                    }
                }
                else{
                    if(tex2D(_ImageTex, imageSample).r > blueNoiseSample.b){
                        return float4(1, 1, 1, 1);
                    }
                    else{
                        return float4(0, 0, 0, 1);
                    }
                }


                //return blueNoiseSample;
            }
            ENDCG
        }
    }
}
