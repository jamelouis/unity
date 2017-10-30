Shader "Hidden/fdog"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_tfm("texture", 2D) = "white" {}
		nPass("Pass", Int) = 0
		sigma_d("sigma_d", Float) = 3.0
		sigma_r("sigma_r", Float) = 0.0425
		sigma_e("sigma_e", Float) = 1.0
		tau("tau", Float) = 0.99
		sigma_m("simga_m", Float) = 2.0
		phi("phi", Float) = 3.0
		edge("texture",2D) = "white" {}
		nbins("nbins",Int) = 8
		phi_p("phi_p",Float) = 3.4
	}
	SubShader
	{
		CGINCLUDE
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

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;
			return o;
		}

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;

		fixed4 structure_tensor(v2f i) : SV_Target
		{
			half2 uv = i.uv;

			half4 u = (
				-1.0 * tex2D(_MainTex, uv + float2(-1.0,-1.0) * _MainTex_TexelSize.xy) +
				-2.0 * tex2D(_MainTex, uv + float2(-1.0, 0.0) * _MainTex_TexelSize.xy) +
				-1.0 * tex2D(_MainTex, uv + float2(-1.0, 1.0) * _MainTex_TexelSize.xy) +
				 1.0 * tex2D(_MainTex, uv + float2( 1.0,-1.0) * _MainTex_TexelSize.xy) +
				 2.0 * tex2D(_MainTex, uv + float2( 1.0, 0.0) * _MainTex_TexelSize.xy) +
				 1.0 * tex2D(_MainTex, uv + float2( 1.0, 1.0) * _MainTex_TexelSize.xy)
				)/4.0;
			
			half4 v = (
				-1.0 * tex2D(_MainTex, uv + float2(-1.0, -1.0) * _MainTex_TexelSize.xy) +
				-2.0 * tex2D(_MainTex, uv + float2( 0.0, -1.0) * _MainTex_TexelSize.xy) +
				-1.0 * tex2D(_MainTex, uv + float2( 1.0, -1.0) * _MainTex_TexelSize.xy) +
				 1.0 * tex2D(_MainTex, uv + float2(-1.0,  1.0) * _MainTex_TexelSize.xy) +
				 2.0 * tex2D(_MainTex, uv + float2( 0.0,  1.0) * _MainTex_TexelSize.xy) +
				 1.0 * tex2D(_MainTex, uv + float2( 1.0,  1.0) * _MainTex_TexelSize.xy)
				) / 4.0;

			return fixed4(dot(u.xyz, u.xyz), dot(v.xyz, v.xyz), dot(u.xyz, v.xyz), 1.0);
		}

		fixed4 smooth_horizontal(v2f i) : SV_Target
		{
			half2 uv = i.uv;
			return fixed4(
				1.0 / 16.0 * tex2D(_MainTex, uv + float2(0.0, -2.0) * _MainTex_TexelSize.xy).rgb + 
				4.0 / 16.0 * tex2D(_MainTex, uv + float2(0.0, -1.0) * _MainTex_TexelSize.xy).rgb +
				6.0 / 16.0 * tex2D(_MainTex, uv + float2(0.0,  0.0) * _MainTex_TexelSize.xy).rgb +
				4.0 / 16.0 * tex2D(_MainTex, uv + float2(0.0,  1.0) * _MainTex_TexelSize.xy).rgb +
				1.0 / 16.0 * tex2D(_MainTex, uv + float2(0.0,  2.0) * _MainTex_TexelSize.xy).rgb,
				1.0
			);
		}
        
		fixed4 smooth_vertical(v2f i) : SV_Target
		{
			half2 uv = i.uv;
			half4 g =  half4(
				1.0 / 16.0 * tex2D(_MainTex, uv + float2(-2.0, 0.0) * _MainTex_TexelSize.xy).rgb +
				4.0 / 16.0 * tex2D(_MainTex, uv + float2(-1.0, 0.0) * _MainTex_TexelSize.xy).rgb +
				6.0 / 16.0 * tex2D(_MainTex, uv + float2( 0.0, 0.0) * _MainTex_TexelSize.xy).rgb +
				4.0 / 16.0 * tex2D(_MainTex, uv + float2( 1.0, 0.0) * _MainTex_TexelSize.xy).rgb +
				1.0 / 16.0 * tex2D(_MainTex, uv + float2( 2.0, 0.0) * _MainTex_TexelSize.xy).rgb,
				1.0
			);

			half lambda1 = 0.5 * (g.y + g.x + sqrt(g.y * g.y - 2.0 * g.x * g.y + g.x * g.x + 4.0 * g.z * g.z));
			half2 d = half2(g.x - lambda1, g.z);

			return (length(d) > 0.0) ? fixed4(normalize(d), sqrt(lambda1), 1.0) : fixed4(0.0, 1.0, 0.0, 1.0);
		}

		half4 rgb2ycbcr(v2f i) : SV_Target
		{
			half3 color =  tex2D(_MainTex, i.uv).rgb;
			
			return half4(
				dot(half3(0.299, 0.587, 0.114), color),
				dot(half3(-0.169, -0.331, 0.500), color),
				dot(half3(0.500, -0.419, -0.081), color),
				1.0
			);
		}

	    half4 ycbcr2rgb(v2f i) : SV_Target
		{
			half3 color = tex2D(_MainTex, i.uv).rgb;

			return half4(
				dot(half3(1.0,0.0,1.4), color),
				dot(half3(1.0,-0.343,-0.711),color),
				dot(half3(1.0, 1.765, 0.0),color),
				1.0
			);
		}

		int nPass;
		half sigma_d;
		half sigma_r;
		sampler2D _tfm;  

		half4 orientation_aligned_bilateral_filter(v2f i) : SV_Target
		{
			half twoSigmaD2 = 2.0 * sigma_d * sigma_d;
			half twoSigmaR2 = 2.0 * sigma_r * sigma_r;

			half2 uv = i.uv;
			half2 t = tex2D(_tfm, uv).xy;

			
			half2 dir =  (nPass == 0) ? half2(t.y, -t.x) : t;

			half2 dabs =  abs(dir); 

			half ds = 1.0 / ((dabs.x > dabs.y) ? dabs.x :dabs.y);

			dir =  dir * _MainTex_TexelSize.xy;

			half3 center = tex2D(_MainTex, uv).rgb;
			half3 sum = center;
			half norm = 1.0;

			half halfWidth = 2.0 * sigma_d;
			[loop] for (half d = ds; d <= halfWidth; d += ds)
			{
				half3 c0 = tex2D(_MainTex, uv + d * dir).rgb;
				half3 c1 = tex2D(_MainTex, uv - d * dir).rgb;
				half e0 = length(c0 - center);
				half e1 = length(c1 - center);

				half kerneld = exp(-d * d / twoSigmaD2);
				half kernele0 = exp(-e0 * e0 / twoSigmaR2);
				half kernele1 = exp(-e1 * e1 / twoSigmaR2);

				norm += kerneld * kernele0;
				norm += kerneld * kernele1;

				sum += kerneld * kernele0 * c0;
				sum += kerneld * kernele1 * c1;
			}
		
			sum /= norm;

			return half4(sum, 0.0);
		}
		
		half sigma_e;
		//half sigma_r;
		half tau;

		half4 flow_based_dog_filter(v2f i) : SV_Target
		{
			half twoSigmaE2 = 2.0 * sigma_e * sigma_e;
			half twoSigmaR2 = 2.0 * sigma_r * sigma_r;
			half2 uv = i.uv;

			half2 t = tex2D(_tfm, uv).xy;
			
			half2 n = half2(t.y, -t.x);
			half2 nabs = abs(n);

			half ds = 1.0 / ((nabs.x > nabs.y) ? nabs.x : nabs.y);
			n *= _MainTex_TexelSize.xy;

			half2 sum = tex2D(_MainTex, uv).xx;
			
			half2 norm = half2(1.0, 1.0);

			half halfWidth = 2.0 * sigma_r;
			[loop]for (half d = ds; d <= halfWidth; d += ds) 
			{
				half2 kernel = half2(exp(-d * d / twoSigmaE2), exp(-d*d / twoSigmaR2));

				norm += 2.0 * kernel;

				half2 L0 = tex2D(_MainTex, uv - d * n).xx;
				half2 L1 = tex2D(_MainTex, uv + d * n).xx;
				
				sum += kernel * (L0 + L1);
				
			}
			
			sum /= norm;

			half diff = 100.0 * (sum.x - tau * sum.y);
			return half4(diff.xxx, 1.0);
		}

		half sigma_m;
		half phi;

		struct lic_t {
			half2 p;
			half2 t;
			half w;
			half dw;
		};

		void step(inout lic_t s)
		{
			half2 t = tex2D(_tfm, s.p).xy;
			if (dot(t, s.t) < 0.0) t = -t;
			s.t = t;

			s.dw = (abs(t.x) > abs(t.y)) ?
				abs((frac(s.p.x) - 0.5 - sign(t.x)) / t.x) :
				abs((frac(s.p.y) - 0.5 - sign(t.y)) / t.y);

			s.p += t * s.dw * _MainTex_TexelSize;
			s.w += s.dw;
		}

		half4 flow_based_dog_filter2(v2f i) : SV_Target
		{
			half twoSigmaM2 = 2.0 * sigma_m * sigma_m;
			half halfWidth = 2.0 * sigma_m;

			half2 uv = i.uv;

			half H = tex2D(_MainTex, uv).x;
			half w = 1.0;

			lic_t a, b;
			a.p = b.p = uv;
			a.t = tex2D(_tfm, uv).xy * _MainTex_TexelSize;
			b.t = -a.t;
			a.w = b.w = 0.0;

			[loop]
			while (a.w < halfWidth)
			{
				step(a);
				half k = a.dw * exp(-a.w * a.w / twoSigmaM2);
				H += k * tex2D(_MainTex, a.p).x;
				w += k;
			}

			[loop]
			while (b.w < halfWidth)
			{
				step(b);
				half k = b.dw * exp(-b.w * b.w / twoSigmaM2);
				H += k * tex2D(_MainTex, b.p).x;
				w += k;
			}

			H /= w;

			half edge = (H > 0.0) ? 1.0 : 2.0 * smoothstep(-2.0, 2.0, phi * H);

			return half4(edge.xxx, 1.0);

		}

		int nbins; // 8
		half phi_q; // 3.4
		sampler2D edge;

		half4 composition(v2f i) : SV_Target
		{
			half3 color = tex2D(_MainTex, i.uv).rgb;

			float qn = floor(color.x * float(nbins) + 0.5) / float(nbins);
			float qs = smoothstep(-2.0, 2.0, phi_q * (color.x - qn) * 100.0) - 0.5;
			float qc = qn + qs / float(nbins);

			color.x = qc;

			half4 cOut = half4(
				dot(half3(1.0, 0.0, 1.4), color),
				dot(half3(1.0, -0.343, -0.711), color),
				dot(half3(1.0, 1.765, 0.0), color),
				1.0);

			cOut = cOut * tex2D(edge, i.uv);
			return cOut;
		}
		ENDCG



		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			NAME "Structure tensor"
				CGPROGRAM
#pragma vertex vert
#pragma fragment structure_tensor
				ENDCG
		}

		Pass
		{
			NAME "Smooth horizontal"
				CGPROGRAM
#pragma vertex vert
#pragma fragment smooth_horizontal
				ENDCG
		}

		Pass
		{
			NAME "smooth vertical"
				CGPROGRAM
#pragma vertex vert
#pragma fragment smooth_vertical
				ENDCG
		}

		Pass
		{
			NAME "rgb2ycbcr"
				CGPROGRAM
#pragma vertex vert
#pragma fragment rgb2ycbcr
				ENDCG
		}

		Pass
		{
			NAME "ycbcr2rgb"
				CGPROGRAM
#pragma vertex vert
#pragma fragment ycbcr2rgb
				ENDCG
		}

		Pass
		{
			NAME "oabf"
				CGPROGRAM
#pragma vertex vert
#pragma fragment orientation_aligned_bilateral_filter
				ENDCG
		}


		Pass // 6
		{
			NAME "fbdf"
				CGPROGRAM
#pragma vertex vert
#pragma fragment flow_based_dog_filter
				ENDCG
		}

		Pass // 7
		{
			NAME "fbdf2"
			CGPROGRAM
#pragma vertex vert 
#pragma fragment flow_based_dog_filter2
			ENDCG
		}

		Pass // 8
		{
			NAME "composition"
				CGPROGRAM
#pragma vertex vert 
#pragma fragment composition
				ENDCG
		}
	}
}
