Shader "CloudCube/03_CubeBeersLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Noise3D ("Noise 3D", 3D) = "white" {}
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
            // #include "../ray.cginc"

            #define SUN_COLOR float3(1., 1., 1.)

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
            sampler3D _Noise3D;
            float3 _CubePosition;
            float _CubeLength;
            float _Absorption;
            float _NoiseTiling;
            float3 _LightDirection;
            int _LightSteps;
            float _LightAbsorption;
            float4 _LightCol;
            float _LightIntensity;
            int _UseBeersPowder;
            int _UseHenyeyGreenstein;

            // float henyeyGreenstein( float sunDot, float g) {
            //     float g2 = g * g;
            //     return (.25 / PI) * ((1. - g2) / pow( 1. + g2 - 2. * g * sunDot, 1.5));
            // }

            // bool pointInsideCube(float3 p, float3 cubePosition, float cubeLength){
            //     float3 min = cubePosition - cubeLength / 2;
            //     float3 max = cubePosition + cubeLength / 2;
            //     return p.x > min.x && p.x < max.x && p.y > min.y && p.y < max.y && p.z > min.z && p.z < max.z;
            // }

            // float marchTowardsLight(float3 p){
            //     float totalDensity = 0;
            //     float maxDistance = sqrt(_CubeLength * _CubeLength + _CubeLength * _CubeLength + _CubeLength * _CubeLength);
            //     float distPerStep = maxDistance / 5.0 * 0.9;
            //     float3 rayDir = normalize(_LightDirection);
            //     [unroll(6)]
            //     for(int i = 0; i < 6; i++){
            //         float3 pos = getMarchPosition(p, rayDir, 0, float(i), distPerStep);
            //         if(pointInsideCube(pos, _CubePosition, _CubeLength)){
            //             float3 samplePos = remap_f3(pos, -_NoiseTiling, _NoiseTiling, 0, 1);
            //             totalDensity += tex3D(_Noise3D, samplePos).r * distPerStep;
            //         }
            //     }

            //     if(_UseBeersPowder){
            //         return _LightIntensity * exp(-totalDensity * _LightAbsorption) * (1. - exp(-totalDensity * 10.));
            //     }
            //     else{
            //         return _LightIntensity * exp(-totalDensity * _LightAbsorption);
            //     }

            // }

            float4 cubeLight(v2f i){
                // float3 rayDir = getPixelRayInWorld(i.uv);
                // float3 rayOrigin = getCameraOriginInWorld();
                // fixed4 mainCol = tex2D(_MainTex, i.uv);
                // float4 cubeCol = float4(135.0/256.0, 206.0/256.0, 235.0/256.0, 0);
                // intersectData cubeIntersect = cubeIntersection(rayOrigin, rayDir, _CubePosition, _CubeLength);
                // float alpha = 0;
                // float lightDensity = 0;
                // float lightDot = max(0., dot(rayDir, _LightDirection));
                // float hgPhase = lerp(henyeyGreenstein(lightDot, .4), henyeyGreenstein(lightDot, -.1), .5);
                // if(cubeIntersect.intersects){
                //     float maxDistance = sqrt(_CubeLength * _CubeLength + _CubeLength * _CubeLength + _CubeLength * _CubeLength);
                //     float distPerStep = maxDistance / _MarchSteps;
                //     float totalDensity = 0;
                //     float4 interScatterTrans = float4(0,0,0,1);
                //     [unroll(8)]
                //     for(int j = 0; j < _MarchSteps; j++){
                //         float3 pos = getMarchPosition(rayOrigin, rayDir, cubeIntersect.intersectPoints.x, float(j), distPerStep);
                //         float3 samplePos = remap_f3(pos, -_NoiseTiling, _NoiseTiling, 0, 1);
                //         float density = tex3D(_Noise3D, samplePos);
                //         if(pointInsideCube(pos, _CubePosition, _CubeLength)){

                //             //illumination
                //             float3 luminance = float3(0,0,0);
                //             if(_UseHenyeyGreenstein){
                //                 luminance = SUN_COLOR * hgPhase * marchTowardsLight(pos) * density;
                //             }
                //             else{
                //                 luminance = SUN_COLOR * marchTowardsLight(pos) * density;
                //             }

                //             float transmittance = exp(-density * distPerStep);
                //             float3 integScatter = (luminance - luminance * transmittance) * (1. / density);
                //             interScatterTrans.rgb += interScatterTrans.a * integScatter;
                //             interScatterTrans.a *= transmittance;

                //             //density
                //             totalDensity += density * distPerStep;
                //         }
                //     }
                //     cubeCol = float4(saturate(interScatterTrans.rgb), interScatterTrans.a);
                //     alpha = 1 - exp(-totalDensity * _Absorption);
                // }
                // return lerp(mainCol, cubeCol, alpha);
                return float4(0,0,0,0);

            }

            
            // float4 getRayColor(v2f i){
            //     return cubeLight(i);
            // }

            fixed4 frag (v2f i) : SV_Target
            {
                // setPixelID(i.uv);
                // float4 color = 0;
                // [unroll(4)]
                //  for(int j = 0; j < _RayPerPixel; j++){
                //     color += getRayColor(i);
                // }

                // return color / _RayPerPixel;

                return float4(0,0,0,0);
            }
            ENDCG
        }
    }
}
