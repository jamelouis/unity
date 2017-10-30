using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class fdog : PostEffectsBase {

	public Shader fdogShader;
	private Material fdogMaterial;

	[Range(0, 8)]
	public int nType = 8;

	public Material material
	{
		get
		{
			fdogMaterial = CheckShaderAndCreateMaterial(fdogShader, fdogMaterial);
			return fdogMaterial;
		}
	} 

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		if(null!=material)
		{
			int rtW                         = source.width;
			int rtH                         = source.height;

			RenderTexture structure_tensor	= RenderTexture.GetTemporary(rtW, rtH, 0, RenderTextureFormat.DefaultHDR);
			RenderTexture smooth_horizontal = RenderTexture.GetTemporary(rtW, rtH, 0, RenderTextureFormat.DefaultHDR);
			RenderTexture tfm				= RenderTexture.GetTemporary(rtW, rtH, 0, RenderTextureFormat.DefaultHDR);
			RenderTexture rgb2ycbcr         = RenderTexture.GetTemporary(rtW, rtH, 0, RenderTextureFormat.DefaultHDR);
			RenderTexture oabf1             = RenderTexture.GetTemporary(rtW, rtH, 0, RenderTextureFormat.DefaultHDR);
			RenderTexture oabf2             = RenderTexture.GetTemporary(rtW, rtH, 0, RenderTextureFormat.DefaultHDR);
			RenderTexture fbdf              = RenderTexture.GetTemporary(rtW, rtH, 0, RenderTextureFormat.DefaultHDR);
			RenderTexture fbdf2             = RenderTexture.GetTemporary(rtW, rtH, 0, RenderTextureFormat.DefaultHDR);
			RenderTexture composition       = RenderTexture.GetTemporary(rtW, rtH, 0, RenderTextureFormat.DefaultHDR);

			// contruct tfm
			Graphics.Blit(source, structure_tensor, material, 0);
			Graphics.Blit(structure_tensor, smooth_horizontal, material, 1);
			Graphics.Blit(smooth_horizontal, tfm, material, 2);
			
			// constructe fbdf
			Graphics.Blit(source, rgb2ycbcr, material, 3);
			
			material.SetTexture("_tfm", tfm);
			material.SetInt("nPass", 0);
			material.SetFloat("sigma_d", 3.0f);
			material.SetFloat("sigma_r", 0.045f);
			Graphics.Blit(rgb2ycbcr, oabf1, material, 5);

			
			material.SetTexture("_tfm", tfm);
			material.SetInt("nPass", 1);
			material.SetFloat("sigma_d", 3.0f);
			material.SetFloat("sigma_r", 0.045f);
			Graphics.Blit(oabf1, oabf2, material, 5);

			
			material.SetTexture("_tfm", tfm);
			material.SetFloat("tau", 0.99f);
			material.SetFloat("sigma_e", 1.0f);
			material.SetFloat("sigma_r", 1.6f);
			Graphics.Blit(oabf2, fbdf, material, 6);

			
			material.SetTexture("_tfm", tfm);
			material.SetFloat("phi", 2.0f);
			material.SetFloat("sigma_m", 3.0f);
			Graphics.Blit(fbdf, fbdf2, material, 7);

			// composition
			material.SetTexture("edge", fbdf2);
			material.SetInt("nbins", 8);
			material.SetFloat("phi_q", 3.4f);
			Graphics.Blit(oabf2, composition, material, 8);

			switch(nType)
			{
				case 0:
					Graphics.Blit(structure_tensor, destination);
					break;
				case 1:
					Graphics.Blit(smooth_horizontal, destination);
					break;
				case 2:
					Graphics.Blit(tfm, destination);
					break;

				case 3:
					Graphics.Blit(rgb2ycbcr, destination);
					break;
				case 4:
					Graphics.Blit(oabf1, destination);
					break;
				case 5:
					Graphics.Blit(oabf2, destination);
					break;
				case 6:
					Graphics.Blit(fbdf, destination);
					break;
				case 7:
					Graphics.Blit(fbdf2, destination);
					break;
				case 8:
					Graphics.Blit(composition, destination);
					break;
			}

			RenderTexture.ReleaseTemporary(composition);
			RenderTexture.ReleaseTemporary(fbdf2);
			RenderTexture.ReleaseTemporary(fbdf);
			RenderTexture.ReleaseTemporary(oabf2);
			RenderTexture.ReleaseTemporary(oabf1);
			RenderTexture.ReleaseTemporary(rgb2ycbcr);
			RenderTexture.ReleaseTemporary(tfm);
			RenderTexture.ReleaseTemporary(smooth_horizontal);
			RenderTexture.ReleaseTemporary(structure_tensor);

		}
		else
		{
			Graphics.Blit(source, destination);
		}
	}
}
