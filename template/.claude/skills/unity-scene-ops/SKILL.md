---
name: unity-scene-ops
description: Manage Unity scenes, GameObjects, and components through Unity MCP. Use when building scenes, placing objects, setting up hierarchy, creating materials, or when user asks to construct or modify a scene.
disable-model-invocation: true
---

# Unity Scene Operations (via Unity MCP)

## Prerequisites
Unity Editor must be open with com.unity.ai.assistant package installed and MCP connection active.

## Quick Reference

### Single Object Operations
- `Unity_ManageScene` — シーン作成・ロード・保存・情報取得
- `Unity_ManageGameObject` — GameObject 作成・移動・回転・スケール・コンポーネント操作
- `Unity_ManageAsset` — アセット管理（マテリアル含む）
- `Unity_CreateScript` — C# スクリプト作成（Write ではなくこちらを使う）

### Batch Scene Building (Unity_RunCommand)
複数 GameObject を一括配置する場合:
```csharp
internal class CommandScript : IRunCommand
{
    public void Execute(ExecutionResult result)
    {
        // GameObject 作成
        var obj = new GameObject("MyObject");
        var sr = obj.AddComponent<SpriteRenderer>();
        sr.color = Color.red;
        result.RegisterObjectCreation(obj);

        // コンポーネント追加
        var rb = obj.AddComponent<Rigidbody2D>();
        rb.gravityScale = 0;

        // PhysicsMaterial2D (アセット保存)
        var mat = new PhysicsMaterial2D("BounceMat");
        mat.bounciness = 1f; mat.friction = 0f;
        AssetDatabase.CreateAsset(mat, "Assets/Materials/BounceMat.asset");

        // シーン保存
        EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
        EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene());
        result.Log("Done");
    }
}
```
必要な using: `UnityEngine`, `UnityEditor`, `UnityEditor.SceneManagement`

### Screenshots (確認用)
- `Unity_Camera_Capture` — ゲームカメラからの撮影
- `Unity_EditorWindow_CaptureScreenshot` — エディタウィンドウ
- `Unity_SceneView_CaptureMultiAngleSceneView` — 複数アングル

### Debug
- `Unity_GetConsoleLogs` — エラー確認
- `Unity_ReadConsole` — コンソール読み取り

## Examples

### Example 1: 新規シーン作成してオブジェクト配置
1. `Unity_ManageScene(Action: "Create", Name: "MyScene", Path: "Assets/Scenes")`
2. `Unity_ManageScene(Action: "Load", Name: "MyScene", Path: "Assets/Scenes")`
3. `Unity_RunCommand` でオブジェクト一括配置
4. `Unity_Camera_Capture` で確認
5. `Unity_ManageScene(Action: "Save")`

### Example 2: 既存オブジェクトの変更
1. `Unity_ManageScene(Action: "GetHierarchy")` で構造確認
2. `Unity_ManageGameObject(action: "modify", target: "Player", position: [0,1,0])`

## Troubleshooting
- **MCP 接続エラー**: Unity Editor が起動中か確認。Edit > Project Settings > AI > Unity MCP
- **オブジェクトが見つからない**: `Unity_ManageScene(Action: "GetHierarchy")` で名前を確認
- **スプライトが表示されない**: SpriteRenderer のスプライトが null の可能性。テクスチャの Import Settings で Sprite (2D and UI) に設定されているか確認
- **RunCommand 失敗**: `result.LogError()` のメッセージを確認。using の不足が多い

$ARGUMENTS
