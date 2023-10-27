using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(CloudCoverageController))]
public class SaveTexture : Editor
{
    public override void OnInspectorGUI(){
        DrawDefaultInspector();
        
        CloudCoverageController cloudCoverageController = (CloudCoverageController) target;
        if(GUILayout.Button("Save Texture")){
            cloudCoverageController.SaveCurrentTexture();
        }
    }
}
