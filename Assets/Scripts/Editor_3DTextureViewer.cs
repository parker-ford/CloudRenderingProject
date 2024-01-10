using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(TextureViewer3D))]
public class Editor_3DTextureViewer : Editor
{
    public override void OnInspectorGUI()
    {
        TextureViewer3D script = (TextureViewer3D)target;
        int maxSlice = script.texture != null ? script.texture.depth - 1 : 0;
        script.currentSlice = EditorGUILayout.IntSlider("Current Slice", script.currentSlice, 0, maxSlice);
        DrawDefaultInspector();
    }

    
}
