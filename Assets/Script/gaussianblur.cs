using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class gaussianblur : PostEffectsBase
{
	public Shader gaussianBlurShader;
	private Material gaussianBlurMaterial = null;

	public Material material
	{
		get
		{
			gaussianBlurMaterial = CheckShaderAndCreateMaterial(gaussianBlurShader, gaussianBlurMaterial);
			return gaussianBlurMaterial;
		}
	}

	// Blur iterations - larger number means more blur.
	[Range(0, 4)]
	public int iterations = 3;

	// Blur spread for each iteration - larger value means more blur
	[Range(0.2f, 3.0f)]
	public float blurSpread = 0.6f;

	[Range(1, 8)]
	public int downSample = 2;

	/// 1st edition: just apply blur
	/// 
	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (null != material)
		{
			int rtW = src.width;
			int rtH = src.height;
			RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);

			// Render the vertical pass
			Graphics.Blit(src, buffer, material, 0);
			// Rnder the horizontal pass
			Graphics.Blit(buffer, dest, material, 1);

			RenderTexture.ReleaseTemporary(buffer);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}



	
}
