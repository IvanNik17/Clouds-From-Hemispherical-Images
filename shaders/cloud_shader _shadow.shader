Shader "Cg per-vertex diffuse lighting" {
   Properties {
      _Color ("Diffuse Material Color", Color) = (1,1,1,1) 
      _ColorAmbient ("Ambient Light Color", Color) = (1,1,1,1)
      _Intensity ("Ambient Light Intensity", Range (0,1)) = 0.2
      _MainTex ("Tranparency Map", 2D) = "white" {}
      _ShadowColor ("Shadow's Color", Color) = (0,0,0,1)
   }
   SubShader {
      Pass {    
         Tags { "Queue" = "Transparent" } 
         Tags { "LightMode" = "ForwardBase" } 
           // pass for first light source
 
 		 ZWrite Off
         Blend SrcAlpha OneMinusSrcAlpha
      	 Cull Off
 
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         #include "UnityCG.cginc"
 
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         uniform float4 _Color; // define shader property for shaders
         uniform sampler2D _MainTex;
         
         uniform float4 _ColorAmbient;
         uniform float _Intensity;
 
         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 texcoord : TEXCOORD0;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 tex : TEXCOORD0;
            float4 col : COLOR;
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            float4x4 modelMatrix = _Object2World;
            float4x4 modelMatrixInverse = _World2Object; 
               // multiplication with unity_Scale.w is unnecessary 
               // because we normalize transformed vectors
 
            float3 normalDirection = normalize(float3(
               mul(float4(input.normal, 0.0), modelMatrixInverse)));
            float3 lightDirection;
            float attenuation;
 
            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
            {
               attenuation = 1.0; // no attenuation
               lightDirection = 
                  normalize(float3(_WorldSpaceLightPos0));
            } 
            else // point or spot light
            {
               float3 vertexToLightSource = float3(_WorldSpaceLightPos0 
                  - mul(modelMatrix, input.vertex));
               float distance = length(vertexToLightSource)/5000;
               attenuation = 1.0 / distance; // linear attenuation 
               lightDirection = normalize(vertexToLightSource);
            }
 
            float3 diffuseReflection = 
               attenuation * float3(_LightColor0) * float3(_Color)
               * max(0.0, dot(normalDirection, lightDirection));
 
            output.col = float4(diffuseReflection + float3(_ColorAmbient) * _Intensity, 1.0);
            output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
            output.tex = input.texcoord;
            return output;
         }
 
         float4 frag(vertexOutput input) : COLOR
         {        
         	float4 textureColor = tex2D(_MainTex, float2(input.tex.y, 1-input.tex.x));  
     		float i = (textureColor.r + textureColor.g + textureColor.b)/3;
            return float4(input.col.rgb, i);
         }
 
         ENDCG
      }
 
      Pass {    
         Tags { "LightMode" = "ForwardAdd" } 
            // pass for additional light sources
         Blend SrcAlpha OneMinusSrcAlpha
 
  		 ZWrite Off
      	 Cull Off
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         #include "UnityCG.cginc"
 
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         uniform float4 _Color; // define shader property for shaders
         uniform sampler2D _MainTex;
         
         uniform float4 _ColorAmbient;
         uniform float _Intensity;
 
         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 texcoord : TEXCOORD0;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 tex : TEXCOORD0;
            float4 col : COLOR;
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            float4x4 modelMatrix = _Object2World;
            float4x4 modelMatrixInverse = _World2Object; 
               // multiplication with unity_Scale.w is unnecessary 
               // because we normalize transformed vectors
 
            float3 normalDirection = normalize(float3(
               mul(float4(input.normal, 0.0), modelMatrixInverse)));
            float3 lightDirection;
            float attenuation;
 
            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
            {
               attenuation = 1.0; // no attenuation
               lightDirection = 
                  normalize(float3(_WorldSpaceLightPos0));
            } 
            else // point or spot light
            {
               float3 vertexToLightSource = float3(_WorldSpaceLightPos0 
                  - mul(modelMatrix, input.vertex));
               float distance = length(vertexToLightSource) / 5000;
               attenuation = 1.0 / distance; // linear attenuation 
               lightDirection = normalize(vertexToLightSource);
            }
 
            float3 diffuseReflection = 
               attenuation * float3(_LightColor0) * float3(_Color)
               * max(0.0, dot(normalDirection, lightDirection));
 
            output.col = float4(diffuseReflection + float3(_ColorAmbient) * _Intensity, 1.0);
            output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
            output.tex = input.texcoord;
            return output;
         }
 
         float4 frag(vertexOutput input) : COLOR
         {        
         	float4 textureColor = tex2D(_MainTex, float2(input.tex.y, 1-input.tex.x));  
     		float i = (textureColor.r + textureColor.g + textureColor.b)/3;
            return float4(input.col.rgb, i);
         }
 
         ENDCG
      }
      Pass {   
         Tags { "LightMode" = "ForwardBase" } 
         Blend SrcAlpha OneMinusSrcAlpha
            // rendering of projected shadow
         Offset -1.0, -2.0 
            // make sure shadow polygons are on top of shadow receiver
 		 ZWrite Off
      	 Cull Off
         CGPROGRAM
 
         #pragma vertex vert 
         #pragma fragment frag
 
         #include "UnityCG.cginc"
 
         // User-specified uniforms
         uniform float4 _ShadowColor;
         uniform sampler2D _MainTex;
         uniform float4x4 _World2Receiver; // transformation from 
         uniform float4 _ColorAmbient;
         uniform float _Intensity;
            // world coordinates to the coordinate system of the plane
 		 struct vertexInput {
            float4 texcoord : TEXCOORD0;
            float4 vertex : POSITION;
            
         };
         struct vertexOutput {
            float4 tex : TEXCOORD0;
            float4 pos : SV_POSITION;
            float4 col : COLOR;
         };
 		
         vertexOutput vert(vertexInput input)
         {
         	vertexOutput output;
            float4x4 modelMatrix = _Object2World;
            float4x4 modelMatrixInverse = 
               _World2Object * unity_Scale.w;
            modelMatrixInverse[3][3] = 1.0; 
            float4x4 viewMatrix = 
               mul(UNITY_MATRIX_MV, modelMatrixInverse);
 
            float4 lightDirection;
            if (0.0 != _WorldSpaceLightPos0.w) 
            {
               // point or spot light
               lightDirection = normalize(
                  mul(modelMatrix, input.vertex - _WorldSpaceLightPos0));
            } 
            else 
            {
               // directional light
               lightDirection = -normalize(_WorldSpaceLightPos0); 
            }
 
            float4 vertexInWorldSpace = mul(modelMatrix, input.vertex);
            float4 world2ReceiverRow1 = 
               float4(_World2Receiver[0][1], _World2Receiver[1][1], 
               _World2Receiver[2][1], _World2Receiver[3][1]);
            float distanceOfVertex = 
               dot(world2ReceiverRow1, vertexInWorldSpace); 
               // = (_World2Receiver * vertexInWorldSpace).y 
               // = height over plane 
            float lengthOfLightDirectionInY = 
               dot(world2ReceiverRow1, lightDirection); 
               // = (_World2Receiver * lightDirection).y 
               // = length in y direction
 
            if (distanceOfVertex > 0.0 && lengthOfLightDirectionInY < 0.0)
            {
               lightDirection = lightDirection 
                  * (distanceOfVertex / (-lengthOfLightDirectionInY));
            }
            else
            {
               lightDirection = float4(0.0, 0.0, 0.0, 0.0); 
                  // don't move vertex
            }
 			output.pos = mul(UNITY_MATRIX_P, mul(viewMatrix, 
               vertexInWorldSpace + lightDirection));
 			output.tex = input.texcoord;
 			output.col = float4(_ShadowColor + _ColorAmbient * _Intensity/15);
            return output;
         }
 
         float4 frag(vertexOutput input) : COLOR
         {
            float4 textureColor = tex2D(_MainTex, float2(input.tex.y, 1-input.tex.x));  
     		float i = (textureColor.r + textureColor.g + textureColor.b)/3;
            return float4(input.col.rgb, input.col.a *i);
         }
 
         ENDCG 
      }
   }
   // The definition of a fallback shader should be commented out 
   // during development:
   // Fallback "Diffuse"
}