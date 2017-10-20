Shader "Hidden/visualhdr"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MiniFontTex("Texture", 2D) = "white" {}
		HistogramTexture("Texture", 2D) = "white" {}
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
			Texture2D _MiniFontTex;
			Texture2D HistogramTexture;
			float4	  MainTex_TexelSize;
			

			// useful with PrintCharacter
			#define _0_ 0
			#define _1_ 1
			#define _2_ 2
			#define _3_ 3
			#define _4_ 4
			#define _5_ 5
			#define _6_ 6
			#define _7_ 7
			#define _8_ 8
			#define _9_ 9
			#define _A_ 10
			#define _B_ 11
			#define _C_ 12
			#define _D_ 13
			#define _E_ 14
			#define _F_ 15
			#define _G_ 16
			#define _H_ 17
			#define _I_ 18
			#define _J_ 19
			#define _K_ 20
			#define _L_ 21
			#define _M_ 22
			#define _N_ 23
			#define _O_ 24
			#define _P_ 25
			#define _Q_ 26
			#define _R_ 27
			#define _S_ 28
			#define _T_ 29
			#define _U_ 30
			#define _V_ 31
			#define _W_ 32
			#define _X_ 33
			#define _Y_ 34
			#define _Z_ 35
			#define _Period_ 512 / 8 - 4
			#define _Minus_ _Period_ - 2
			#define _Div_ _Minus_ - 1

			void PrintCharacter(
				int2 PixelPos,
				inout float3 OutColor,
				float3 FontColor,
				inout int2 LeftTop,
				int CharacterID)
			{
				uint2 Rel = (uint2)(PixelPos - LeftTop);
				if (Rel.x < 8 && Rel.y < 8)
				{
					OutColor = lerp(OutColor, FontColor, _MiniFontTex.Load(int3(CharacterID * 8 + Rel.x, 8-Rel.y, 0)).r);
				}
				LeftTop.x += 8;
			}

			uint ExtractDigitFromFloat(float Number, float DigitValue);

			void PrintFloat(
				int2 PixelPos,
				inout float3 OutColor,
				float3 FontColor,
				int2 LeftTop,
				float Number
			)
			{
				int2 Cursor = LeftTop;

				// before period
				PrintCharacter(PixelPos, OutColor, FontColor, Cursor, ExtractDigitFromFloat(Number, 100));
				PrintCharacter(PixelPos, OutColor, FontColor, Cursor, ExtractDigitFromFloat(Number, 10));
				PrintCharacter(PixelPos, OutColor, FontColor, Cursor, ExtractDigitFromFloat(Number, 1));
				// period
				PrintCharacter(PixelPos, OutColor, FontColor, Cursor, _Period_);
				// after period
				PrintCharacter(PixelPos, OutColor, FontColor, Cursor, ExtractDigitFromFloat(Number, 0.1));
				PrintCharacter(PixelPos, OutColor, FontColor, Cursor, ExtractDigitFromFloat(Number, 0.01));
				PrintCharacter(PixelPos, OutColor, FontColor, Cursor, ExtractDigitFromFloat(Number, 0.001));

			}

			// only for positive numbers
			// @param DigitValue - e.g. 1 for frist digit before period, 10 for second, 0.1 for first digit behind period
			uint ExtractDigitFromFloat(float Number, float DigitValue)
			{
				uint Temp = (uint)(Number / DigitValue);
				return Temp % 10;
			}

			half ComputeHistogramPositionFromLuminance(float lum)
			{
				// 1.0/256 ~ 16
				// -8 ~ 4  4-(-8)=12.0
				// 1.0/256 = 2^(-8)
				return (log2(lum) + 8.0) / 12.0;
			}

			half3 Colorize(float x)
			{
				half3 Heat = half3(1.0f, 0.0f, 0.0f);
				half3 Middle = half3(0.0f, 1.0f, 0.0f);
				half3 Cold = half3(0.0f, 0.0f, 1.0f);

				half3 ColdHeat = lerp(Cold, Heat, x);

				return lerp(Middle, ColdHeat, abs(0.5f - x) * 2);
			}

			void PrintCrossHair(
				int2 PixelPos,
				inout float3 OutColor,
				float3 CrossHairColor,
				int2 CrossHairPos)
			{
				float  CrossHairMask = PixelPos.x == CrossHairPos.x || PixelPos.y == CrossHairPos.y;
				float2 DistAbs = abs(PixelPos - CrossHairPos);
				float Dist = max(DistAbs.x, DistAbs.y);
				float DistMask = Dist >= 2 && Dist < 7;

				OutColor = lerp(OutColor.rgb, CrossHairColor, CrossHairMask * DistMask);
			}

			void ShowCenterPixelInfo(
				int2               ViewportCenter,
				int2               PixelPos,
				float3             vCenterColor,
				inout float3       vOutColor
			)
			{
				float  fLum = Luminance(vCenterColor.rgb);

				/// crosshair
				PrintCrossHair(PixelPos, vOutColor.rgb, float3(1, 1, 1), ViewportCenter);

				int2 Cursor;

				Cursor = ViewportCenter + int2(-35, 7 + 0 * 8);
				PrintCharacter(PixelPos, vOutColor.xyz, float3(1, 1, 1), Cursor, _L_);
				PrintFloat(PixelPos, vOutColor.xyz, float3(1, 1, 1), Cursor, fLum);

				Cursor = ViewportCenter + int2(-35, 7 + 1 * 8);
				PrintCharacter(PixelPos, vOutColor.xyz, float3(1, 0, 0), Cursor, _R_);
				PrintFloat(PixelPos, vOutColor.xyz, float3(1, 1, 1), Cursor, vCenterColor.r);

				Cursor = ViewportCenter + int2(-35, 7 + 2 * 8);
				PrintCharacter(PixelPos, vOutColor.xyz, float3(0, 1, 0), Cursor, _G_);
				PrintFloat(PixelPos, vOutColor.xyz, float3(1, 1, 1), Cursor, vCenterColor.g);

				Cursor = ViewportCenter + int2(-35, 7 + 3 * 8);
				PrintCharacter(PixelPos, vOutColor.xyz, float3(0, 0, 1), Cursor, _B_);
				PrintFloat(PixelPos, vOutColor.xyz, float3(1, 1, 1), Cursor, vCenterColor.b);
			}

			// for rectangles with border
			// @return >=0, 0 if inside
			float ComputeDistanceToRect(int2 Pos, int2 LeftTop, int2 Extent, bool bRoundBorders = true)
			{
				int2 RightBottom = LeftTop + Extent - 1;

				// use int for more precision
				int2 Rel = max(int2(0, 0), Pos - RightBottom) + max(int2(0, 0), LeftTop - Pos);

				if (bRoundBorders)
				{
					// euclidian distance (round corners)
					return length((float2)Rel);
				}
				else
				{
					// manhatten distance (90 degree corners)
					return max(Rel.x, Rel.y);
				}
			}

			/// Histogram 
			static const uint uHistogramSize = 64;

			float GetHistogramBucket(Texture2D HistogramTexture, uint uBucketIndex)
			{
				uint uTexel = uBucketIndex / 4;
				uint uChannel = uBucketIndex % 4;

				float4 vf4Mask = float4(uChannel == 0, uChannel == 1, uChannel == 2, uChannel == 3);
				float4 vf4HistogramColor = HistogramTexture.Load(int3(uTexel, 0, 0));

				return dot(vf4Mask, vf4HistogramColor);
			}

			float ComputeHistogramMax(Texture2D HistogramTexture)
			{
				float fMax = 0.0f;

				for (uint i = 0; i < uHistogramSize; ++i)
				{
					fMax = max(fMax, GetHistogramBucket(HistogramTexture, i));
				}

				return fMax;
			}

			float3 tonemap(float3 vf3Color)
			{
				float3 vf3OutColor = vf3Color;
				//vf3OutColor = max(0, vf3OutColor - 0.004f);
				//vf3OutColor = (vf3OutColor*(6.2f*vf3OutColor + 0.5f))/(vf3OutColor*(6.2f*vf3OutColor+1.7)+0.06f);
				vf3OutColor = (vf3OutColor*(2.51f*vf3OutColor + 0.03f)) / (vf3OutColor*(2.43f*vf3OutColor + 0.59f) + 0.14f);
				return vf3OutColor;
			}

			void ShowHistogramInfo(
				int2 vi2PixelPos,
				int2 vi2ViewportSize,
				float fMinBrightness,
				float fMaxBrightness,
				inout float3 vf3OutColor
			)
			{
				const int2 vi2HistogramLeftTop = int2(64, vi2ViewportSize.y - 128 - 32);
				const int2 vi2HistogramSize = int2(vi2ViewportSize.x - 64 * 2, 128);
				const int  iHistogramOuterBorder = 4;

				// (0,0) .. (1, 1)
				float2 vf2InsetPx = vi2PixelPos - vi2HistogramLeftTop;
				float2 vf2InsetUV = vf2InsetPx / vi2HistogramSize;

				const float3 vf3BorderColor = Colorize(vf2InsetUV.x);

				float fBorderDistance = ComputeDistanceToRect(vi2PixelPos, vi2HistogramLeftTop, vi2HistogramSize);

				// thin black border around the histogram
				vf3OutColor = lerp(float3(0, 0, 0), vf3OutColor, saturate(fBorderDistance - (iHistogramOuterBorder + 2)));

				// big solid border around the histogram
				vf3OutColor = lerp(vf3BorderColor, vf3OutColor, saturate(fBorderDistance - (iHistogramOuterBorder + 1)));

				// thin black border around the histogram
				vf3OutColor = lerp(float3(0, 0, 0), vf3OutColor, saturate(fBorderDistance - 1));



				if (fBorderDistance > 0)
				{
					return;
				}

				if (vf2InsetUV.x < ComputeHistogramPositionFromLuminance(fMinBrightness))
				{
					// < min: grey
					vf3OutColor = lerp(vf3OutColor, float3(0.5, 0.5, 0.5), 0.5);
				}
				else if (vf2InsetUV.x < ComputeHistogramPositionFromLuminance(fMaxBrightness))
				{
					// >=min && < max: green
					vf3OutColor = lerp(vf3OutColor, float3(0.5f, 0.8f, 0.5f), 0.5);
				}
				else
				{
					// >= max: grey
					vf3OutColor = lerp(vf3OutColor, float3(0.5f, 0.5f, 0.5f), 0.5f);
				}

				uint uBucket = (uint)(vf2InsetUV.x * uHistogramSize);
				float fLocalHistogramValue = GetHistogramBucket(HistogramTexture, uBucket) / ComputeHistogramMax(HistogramTexture);
				if (fLocalHistogramValue >= 1 - vf2InsetUV.y)
				{
					// histogram bars
					vf3OutColor = lerp(vf3OutColor, Colorize(vf2InsetUV.x), 0.5f);
				}

				float fAvgLum = 0.18f;// EyeAdaptationTex.Load(int3(0, 0, 0)).r;
				/// tonemap curve
				{
					float fLum = ComputeHistogramPositionFromLuminance(vf2InsetUV.x * 16);
					float3 vf3Color = vf2InsetUV.x * 16;

					float3 vf3ToneMapLum = tonemap(vf3Color);
					float3 vf3DistMask = saturate(1.0 - 100.0 * abs(vf3ToneMapLum - (1.0 - vf2InsetUV.y)));

					vf3OutColor = lerp(vf3OutColor, float3(1, 1, 1), vf3DistMask);
				}

				// eye adaption
				{
					float fEyeAdaptionValue = ComputeHistogramPositionFromLuminance(fAvgLum);
					float fValuePx = fEyeAdaptionValue * vi2HistogramSize.x;

					PrintFloat(vi2PixelPos, vf3OutColor.xyz, float3(1, 1, 1), vi2HistogramLeftTop + int2(fValuePx - 3 * 8 - 3, 1), fAvgLum);
					if (abs(vf2InsetPx.x - fValuePx) < 2 && vi2PixelPos.y > vi2HistogramLeftTop.y + 9)
					{
						// white line to show the smoothed exposure
						vf3OutColor = lerp(vf3OutColor, float3(1.0, 1.0, 1.0), 1.0f);
					}
				}

				// rule
				{
					int2 vi2Origin = vi2HistogramLeftTop + int2(0, vi2HistogramSize.y - 2 * (8 + 2));
					int2 vi2Cursor;
					int iPosX;

					// 1.0 / 256.0
					iPosX = ComputeHistogramPositionFromLuminance(1.0 / 256.0) * vi2HistogramSize.x;
					vi2Cursor = vi2Origin + int2(iPosX, 0);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 1, 0), vi2Cursor, _Minus_);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 1, 0), vi2Cursor, _8_);

					vi2Cursor = vi2Origin + int2(iPosX, 10);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 0, 1), vi2Cursor, _1_);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 0, 1), vi2Cursor, _Div_);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 0, 1), vi2Cursor, _2_);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 0, 1), vi2Cursor, _5_);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 0, 1), vi2Cursor, _6_);

					// 1.0 / 32.0
					iPosX = ComputeHistogramPositionFromLuminance(1.0 / 32.0) * vi2HistogramSize.x;
					vi2Cursor = vi2Origin + int2(iPosX, 0);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 1, 0), vi2Cursor, _Minus_);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 1, 0), vi2Cursor, _5_);

					vi2Cursor = vi2Origin + int2(iPosX, 10);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 0, 1), vi2Cursor, _1_);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 0, 1), vi2Cursor, _Div_);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 0, 1), vi2Cursor, _3_);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 0, 1), vi2Cursor, _2_);

					// 1.0 / 4.0
					iPosX = ComputeHistogramPositionFromLuminance(1.0 / 4.0) * vi2HistogramSize.x;
					vi2Cursor = vi2Origin + int2(iPosX, 0);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 1, 0), vi2Cursor, _Minus_);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 1, 0), vi2Cursor, _2_);

					vi2Cursor = vi2Origin + int2(iPosX, 10);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 0, 1), vi2Cursor, _1_);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 0, 1), vi2Cursor, _Div_);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 0, 1), vi2Cursor, _4_);

					// 1.0
					iPosX = ComputeHistogramPositionFromLuminance(2.0) * vi2HistogramSize.x;
					vi2Cursor = vi2Origin + int2(iPosX, 0);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 1, 0), vi2Cursor, _1_);

					vi2Cursor = vi2Origin + int2(iPosX, 10);
					PrintCharacter( vi2PixelPos, vf3OutColor, float3(1, 0, 1), vi2Cursor, _2_);

					// 4.0
					iPosX = ComputeHistogramPositionFromLuminance(16.0) * vi2HistogramSize.x - 16;
					vi2Cursor = vi2Origin + int2(iPosX, 0);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 1, 0), vi2Cursor, _4_);

					vi2Cursor = vi2Origin + int2(iPosX, 10);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 0, 1), vi2Cursor, _1_);
					PrintCharacter(vi2PixelPos, vf3OutColor, float3(1, 0, 1), vi2Cursor, _6_);
				}
			}

			half4 frag(v2f i) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv);
				float lum = Luminance(col.rgb);
				float x = ComputeHistogramPositionFromLuminance(lum);

				half3 cOut = Colorize(x);

				int2 ViewportCenter = int2(MainTex_TexelSize.xy / 2.0);
				half4 vCenterColor = tex2D(_MainTex, float2(0.5, 0.5));

				int2 pos = i.vertex;
				ShowCenterPixelInfo(ViewportCenter, pos, vCenterColor.rgb, cOut.rgb);

				ShowHistogramInfo(pos, int2(MainTex_TexelSize.xy), 0.03, 2.0f, cOut.rgb);

				return half4(cOut.rgb, 1.0);
			}
			ENDCG
		}
	}
}
