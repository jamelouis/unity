﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class fdog : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	private Material fDOG;

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		Graphics.Blit(source, destination);
	}
}
