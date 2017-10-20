using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class visualhdr : MonoBehaviour {

	// Use this for initialization
	void Start () {
		Debug.Log("start");
	}
	
	// Update is called once per frame
	void Update () {
		Debug.Log("update");
	}

	public Material mat;
	public Texture MiniFontTex;
	public Texture HistogramTex;


	private void Awake()
	{
		mat = new Material(Shader.Find("Hidden/visualhdr"));
		mat.SetTexture("_MiniFontTex", MiniFontTex);
		mat.SetTexture("HistogramTexture", HistogramTex);
	}

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		Vector4 v2 = new Vector4(source.width, source.height);
		mat.SetVector("MainTex_TexelSize", v2);
		Graphics.Blit(source, destination, mat);
	}

}
