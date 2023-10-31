using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(TextureSaver))]
public class EditorTextuerSaver : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        TextureSaver saver = (TextureSaver) target;
        if(GUILayout.Button("Save Texture")){
            saver.SaveCurrentTexture();
        }
    }
}
