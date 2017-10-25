using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectsBase : MonoBehaviour {

	// Use this for initialization
	void Start () {
		CheckResources();
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	// called when start
	protected void CheckResources() {
		bool isSupported = CheckSupport();

		if(isSupported == false)
		{
			NotSupported();
		}
	}

	// called in CheckResources to check support on this platform
	protected bool CheckSupport()
	{
		if(SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false)
		{
			Debug.LogWarning("This platform does not support image effects or render textures.");
			return false;
		}
		return true;
	}

	// called when the platform doesn't support thi effect
	protected void NotSupported()
	{
		enabled = false;
	}

	// called when need to create the material used by this effect
	protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
	{
		if (null == shader)
		{
			return null;
		}
			
		if(shader.isSupported && material && material.shader == shader)
		{
			return material;
		}

		if(!shader.isSupported)
		{
			return null;
		}
		else
		{
			material = new Material(shader);
			material.hideFlags = HideFlags.DontSave;
			if (material)
			{
				return material;
			}
			else
			{
				return null;
			}
		}



	}
}
