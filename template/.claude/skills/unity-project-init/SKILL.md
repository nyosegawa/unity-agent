---
name: unity-project-init
description: Initialize Unity project and configure URP/Post Processing. Use when starting a new project, setting up URP pipeline, configuring post processing, or creating folder structure.
disable-model-invocation: true
---

# Unity Project Initialization

## URP Pipeline Setup
プロジェクト開始時に URP パイプラインが GraphicsSettings にセットされているか確認し、されていなければ設定する。

```csharp
internal class CommandScript : IRunCommand
{
    public void Execute(ExecutionResult result)
    {
        // 既存の URP パイプラインアセットを検索
        var guids = AssetDatabase.FindAssets("t:UniversalRenderPipelineAsset");
        if (guids.Length == 0)
        {
            result.LogError("URP Pipeline Asset not found. URP package is installed?");
            return;
        }

        var path = AssetDatabase.GUIDToAssetPath(guids[0]);
        var pipelineAsset = AssetDatabase.LoadAssetAtPath<UniversalRenderPipelineAsset>(path);

        // GraphicsSettings にセット
        GraphicsSettings.defaultRenderPipeline = pipelineAsset;
        QualitySettings.renderPipeline = pipelineAsset;

        result.Log("URP Pipeline set: " + pipelineAsset.name + " from " + path);
    }
}
```
必要な using: `UnityEngine`, `UnityEditor`, `UnityEngine.Rendering`, `UnityEngine.Rendering.Universal`

**重要**: `UniversalRenderPipelineAsset.Create()` で新規作成しない。レンダラーのリンクが壊れやすい。既存アセットを検索して使う。

## URP Post Processing Setup
Bloom, Vignette 等を有効にするには Volume + Profile を作成し、カメラで Post Processing を有効にする。

```csharp
// Volume 作成
var volumeGO = new GameObject("PostProcessVolume");
var volume = volumeGO.AddComponent<Volume>();
volume.isGlobal = true;
var profile = ScriptableObject.CreateInstance<VolumeProfile>();
AssetDatabase.CreateAsset(profile, "Assets/Settings/PostProcessProfile.asset");
volume.profile = profile;

// Bloom
var bloom = profile.Add<Bloom>();
bloom.threshold.overrideState = true; bloom.threshold.value = 1.0f;
bloom.intensity.overrideState = true; bloom.intensity.value = 0.8f;

// Vignette
var vignette = profile.Add<Vignette>();
vignette.intensity.overrideState = true; vignette.intensity.value = 0.25f;

// カメラで Post Processing を有効化
var cam = Camera.main;
var camData = cam.GetComponent<UniversalAdditionalCameraData>();
if (camData == null) camData = cam.gameObject.AddComponent<UniversalAdditionalCameraData>();
camData.renderPostProcessing = true;
```
必要な using: `UnityEngine.Rendering`, `UnityEngine.Rendering.Universal`

## Folder Structure
```
Assets/
├── Scripts/
│   ├── Runtime/
│   │   ├── Core/           # GameManager, ServiceLocator
│   │   ├── Gameplay/       # Game mechanics
│   │   ├── UI/             # UI controllers
│   │   └── Data/           # ScriptableObjects
│   └── Editor/
│       └── Tools/          # Custom editor tools
├── Prefabs/
├── Scenes/
├── Materials/
├── Art/
│   ├── Textures/
│   ├── Sprites/
│   └── Models/
├── Audio/
├── Settings/               # URP Asset, Post Process Profile
└── Resources/              # Only for dynamically loaded assets
```

## Examples

### Example 1: 新規3Dプロジェクトの初期化
1. フォルダ構造を `Unity_RunCommand` で作成
2. URP パイプラインアセットを検索して GraphicsSettings にセット
3. Post Processing Volume を作成して Bloom, Vignette を設定
4. `Unity_Camera_Capture` で Bloom が効いていることを確認

### Example 2: 既存プロジェクトの URP 有効化確認
1. `AssetDatabase.FindAssets("t:UniversalRenderPipelineAsset")` でアセット検索
2. `GraphicsSettings.defaultRenderPipeline` が null なら設定
3. Camera に `UniversalAdditionalCameraData` があるか確認

## Troubleshooting
- **Bloom が効かない**: Camera の `renderPostProcessing` が `true` か確認。Volume の `isGlobal` が `true` か確認
- **画面が真っ黒/ピンク**: URP Pipeline Asset が GraphicsSettings にセットされていない。上記の検索コードで設定する
- **URP Asset が見つからない**: URP パッケージがインストールされていない可能性。`Unity_PackageManager_GetData` で確認

$ARGUMENTS
