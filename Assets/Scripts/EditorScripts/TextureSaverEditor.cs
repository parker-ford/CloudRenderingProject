using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(TextureSaver))]
public class TextureSaverEditor : Editor
{
    public override void OnInspectorGUI(){
        DrawDefaultInspector();
        
        TextureSaver cloudCoverageController = (TextureSaver) target;
        if(GUILayout.Button("Save Texture")){
            cloudCoverageController.SaveCurrentTexture();
        }
    }
}
