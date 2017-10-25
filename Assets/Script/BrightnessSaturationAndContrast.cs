using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessSaturationAndContrast : PostEffectsBase {

	public Shader BriSatConShader;
	private Material briSatConMaterial;

	public Material material
	{
		get
		{
			briSatConMaterial = CheckShaderAndCreateMaterial(BriSatConShader, briSatConMaterial);
			return briSatConMaterial;
		}
	}

	[Range(0.0f, 3.0f)]
	public float brightness = 1.0f;

	[Range(0.0f, 3.0f)]
	public float saturation = 1.0f;

	[Range(0.0f, 3.0f)]
	public float contrast = 1.0f;

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if(null != material )
		{
			material.SetFloat("_Brightness", brightness);
			material.SetFloat("_Saturation", saturation);
			material.SetFloat("_Contrast", contrast);

			Graphics.Blit(src, dest, material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}
