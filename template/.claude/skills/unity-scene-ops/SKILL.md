---
name: unity-scene-ops
description: Manage Unity scenes, GameObjects, and components through Unity MCP. Use for scene hierarchy manipulation, component setup, and prefab operations.
disable-model-invocation: true
---

# Unity Scene Operations (via Unity MCP — com.unity.ai.assistant)

## Prerequisites
Unity Editor must be open with com.unity.ai.assistant package installed and MCP connection active.

## Available MCP Tools

### Scene Management
- `Unity_ManageScene` — シーン作成・ロード・保存・削除・アンロード・情報取得

### GameObject Operations
- `Unity_ManageGameObject` — 作成・選択・情報取得・更新・複製・削除・移動・回転・スケール・親子関係変更・コンポーネント操作

### Asset & Material
- `Unity_ManageAsset` — アセット管理（マテリアル作成・割り当て・変更含む）
- `Unity_FindProjectAssets` — アセット検索
- `Unity_ImportExternalModel` — 外部モデルインポート
- `Unity_ManageShader` — シェーダー管理

### Script Operations
- `Unity_CreateScript` — C# スクリプト作成
- `Unity_ManageScript` — スクリプト管理
- `Unity_ApplyTextEdits` / `Unity_ScriptApplyEdits` — スクリプト編集
- `Unity_ValidateScript` — スクリプト検証

### Editor & Menu
- `Unity_ManageMenuItem` — メニューアイテム実行
- `Unity_ManageEditor` — エディタ操作
- `Unity_RunCommand` — コマンド実行（コンパイル、テスト等）

### Debug
- `Unity_GetConsoleLogs` — コンソールログ取得
- `Unity_ReadConsole` — コンソール読み取り

### Screenshots
- `Unity_Camera_Capture` — カメラキャプチャ
- `Unity_EditorWindow_CaptureScreenshot` — エディタウィンドウスクリーンショット
- `Unity_SceneView_CaptureMultiAngleSceneView` — 複数アングルのシーンビュー

### Package Management
- `Unity_PackageManager_ExecuteAction` — パッケージ操作
- `Unity_PackageManager_GetData` — パッケージ情報取得

### Asset Generation
- `Unity_AssetGeneration_GenerateAsset` — アセット生成
- `Unity_AssetGeneration_GetModels` — 生成モデル取得

## Batch Scene Building with Unity_RunCommand
複数の GameObject を一括配置するには `Unity_RunCommand` に Editor C# コードを渡す:
```csharp
internal class CommandScript : IRunCommand
{
    public void Execute(ExecutionResult result)
    {
        // GameObject 作成
        var obj = new GameObject("MyObject");
        obj.AddComponent<SpriteRenderer>();
        result.RegisterObjectCreation(obj);

        // PhysicsMaterial2D 作成 (Assets に保存)
        var mat = new PhysicsMaterial2D("BounceMat");
        mat.bounciness = 1f; mat.friction = 0f;
        AssetDatabase.CreateAsset(mat, "Assets/Materials/BounceMat.asset");

        // シーン保存
        EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
        EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene());

        result.Log("Scene built successfully");
    }
}
```
- `using UnityEngine; using UnityEditor; using UnityEditor.SceneManagement;` を含める
- `result.RegisterObjectCreation(obj)` で作成オブジェクトを登録
- `result.RegisterObjectModification(obj)` で変更オブジェクトを登録
- アセット作成は `AssetDatabase.CreateAsset()` で保存先を指定

## Important Notes
- シーン変更後は `Unity_ManageScene(Action: "Save")` で保存
- Unity MCP は Unity Editor が起動中でないと接続不可
- スクリプト作成は Write ではなく `Unity_CreateScript` を使用（.meta 自動生成）

$ARGUMENTS
