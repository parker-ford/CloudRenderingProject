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
            float3 _SpherePosition;
            float _SphereRadius;

            fixed4 frag (v2f i) : SV_Target
            {
                //Get ray origin and direction
                float3 dir = getPixelRayInWorld(i.uv);
                float3 o = getCameraOriginInWorld();

                
                //Ray origin to sphere center
                float3 L = o - _SpherePosition;

                //Calculating a,b,c for quadratic formula
                float a = 1.0f; //assuming that dir is normalized, should be dot(dir, dir);
                float b = 2.0f * dot(dir, L);
                float c = dot(L,L) - (_SphereRadius * _SphereRadius);

                //Calculating discriminant
                float discrim = b * b - 4.0f * a * c;

                //If discriminant is less than 0, we know the ray does not intersect
                if(discrim > 0){
                    float q = (b > 0) ? -0.5f * (b + sqrt(discrim)) : -0.5f * (b - sqrt(discrim));
                    
                    //Two potential intersection distances on ray
                    float x0 = q / a;
                    float x1 = c / q;
                    float2 t = float2(0,0);

                    if(x0 < 0 && x1 < 0){
                        //Both distances are negative, meaning the the sphere is behind us... ignoring this case for now
                    }
                    else if(x1 < 0){
                        // Only one direction is behind us
                        t.x = 0;
                        t.y = x0;
                    }
                    else if(x0 < 0){
                        // Only one direction is behind us
                        t.x = 0;
                        t.y = x1;
                    }
                    else{
                        //Both distances are in the forward direction
                        t.x = min(x0, x1);
                        t.y = max(x0, x1);
                    }


                    float dist = (t.y - t.x);
                    int steps = 10;
                    float densityResult = 1.0f;
                    float density = 0.5f;
                    bool samplePerlin = true;
                    float test = 1.0;
                    float noiseThreshold = 0.8f;
                    for(int j = 0; j < steps; j++){
                        float currDist = (float)j/dist;
                        float3 pos = o + dir * (t.x * currDist);
                        float densitySample = density;
                        if(samplePerlin){
                            float3 samplePos = pos + float3(0.5,0.5,0.5);
                            float noise = tex3D( _Perlin3DTexture, samplePos);
                            noise = (noise + 1) / 2.0f;
                            densitySample = densitySample * noise;
                            if(noise > noiseThreshold){
                                densityResult = 0;
                                break;
                            }
                        }
                        //densityResult *=  exp(-(dist/steps) * densitySample);
                    }

                    float3 col = lerp( float3(1,0,0),  tex2D(_MainTex, i.uv), densityResult);
                    return fixed4(col, 1);

                }
                else{
                    float3 col = lerp(tex2D(_MainTex, i.uv), float3(0,0,0), 0.0f);
                    return fixed4(col, 1.0);
                }
            }
            ENDCG
        }
    }
}
