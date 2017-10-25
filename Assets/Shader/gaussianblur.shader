// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/gaussianblur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurSize("Blur Size", Float) = 1.0
	}
	SubShader
	{
		CGINCLUDE
		#include "UnityCG.cginc"
		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		float _BlurSize;

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv[5] : TEXCOORD0;
		};

		v2f vertBlurVertical(appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);

			half2 uv = v.uv;

			o.uv[0] = uv;
			o.uv[1] = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
			o.uv[2] = uv - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
			o.uv[3] = uv + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
			o.uv[4] = uv - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;

			return o;
		}

		v2f vertBlurHorizontal(appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);

			half2 uv = v.uv;

			o.uv[0] = uv;
			o.uv[1] = uv + float2(_MainTex_TexelSize.y * 1.0, 0.0) * _BlurSize;
			o.uv[2] = uv - float2(_MainTex_TexelSize.y * 1.0, 0.0) * _BlurSize;
			o.uv[3] = uv + float2(_MainTex_TexelSize.y * 2.0, 0.0) * _BlurSize;
			o.uv[4] = uv - float2(_MainTex_TexelSize.y * 2.0, 0.0) * _BlurSize;

			return o;
		}

		fixed4 fragBlur(v2f i) : SV_Target
		{
			float weight[3] = {0.4026, 0.2442, 0.0545};

			fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];

			for (int it = 1; it < 3; it++)
			{
				sum += tex2D(_MainTex, i.uv[it]).rgb * weight[it];
				sum += tex2D(_MainTex, i.uv[2 * it]).rgb * weight[it];
			}

			return fixed4(sum, 1.0);
		}

		ENDCG
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			NAME "GAUSSIAN_BLUR_VERTICAL"

			CGPROGRAM

			#pragma vertex vertBlurVertical
			#pragma fragment fragBlur

			ENDCG
		}

		pass
		{
			NAME "GAUSSIAN_BLUR_VERTICAL"

			CGPROGRAM

			#pragma vertex vertBlurHorizontal
			#pragma fragment fragBlur

			ENDCG
		}
	}
}
