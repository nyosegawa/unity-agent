# Unity Project

## Environment
- Unity 6.x LTS / URP
- Input: New Input System (`UnityEngine.InputSystem`) — `Input.GetKey` 等の旧 API は使用不可
- Target: WebGL
- Language: C#

## MCP Tools Available
Unity Editor 起動中に以下の MCP ツールが利用可能 (Unity MCP — com.unity.ai.assistant):

### Core
- `Unity_ManageScene` — シーン作成・ロード・保存・削除・情報取得
- `Unity_ManageGameObject` — GameObject 作成・選択・更新・複製・削除・移動・回転・スケール・親子関係変更
- `Unity_ManageAsset` — アセット管理（マテリアル作成・割り当て含む）
- `Unity_CreateScript` — C# スクリプト作成
- `Unity_ManageScript` — スクリプト管理
- `Unity_ApplyTextEdits` / `Unity_ScriptApplyEdits` — スクリプト編集
- `Unity_ValidateScript` — スクリプト検証
- `Unity_ManageMenuItem` — メニューアイテム実行
- `Unity_RunCommand` — エディタ C# コード実行（シーン構築、アセット操作、テスト等）
- `Unity_FindInFile` — ファイル内検索
- `Unity_ReadResource` / `Unity_ListResources` — リソース読み取り
- `Unity_FindProjectAssets` — アセット検索

### Debug & Diagnostics
- `Unity_GetConsoleLogs` — コンソールログ取得
- `Unity_ReadConsole` — コンソール読み取り
- `Unity_Profiler_*` — プロファイラー情報取得

### Editor & Screenshots
- `Unity_Camera_Capture` — カメラキャプチャ（ゲームビュー確認に使用）
- `Unity_EditorWindow_CaptureScreenshot` — エディタウィンドウのスクリーンショット
- `Unity_SceneView_CaptureMultiAngleSceneView` — 複数アングルからのシーンビュー撮影
- `Unity_GetProjectData` — プロジェクト情報取得
- `Unity_PackageManager_GetData` / `Unity_PackageManager_ExecuteAction` — パッケージ管理

### Assets
- `Unity_AssetGeneration_GenerateAsset` — アセット生成
- `Unity_AssetGeneration_GetModels` — モデル取得
- `Unity_ImportExternalModel` — 外部モデルインポート
- `Unity_ManageShader` — シェーダー管理

## Script Creation Rules
- **新規スクリプトは `Unity_CreateScript` MCP ツールで作成**（Write ツールではなく）。.meta ファイルが自動生成され、AssetDatabase に正しく登録される
- 既存スクリプトの編集は `Edit` ツールまたは `Unity_ScriptApplyEdits` を使用
- スクリプト作成・編集後は `Unity_GetConsoleLogs` でコンパイルエラーを確認

## Scene Building Pattern
複数の GameObject を一括配置する場合は `Unity_RunCommand` に Editor C# コードを渡す:
```
Unity_RunCommand(Code: "using UnityEngine; using UnityEditor; ...", Title: "Build Scene")
```
- `IRunCommand` インターフェースを実装する `CommandScript` クラスを記述
- `result.RegisterObjectCreation(obj)` で作成したオブジェクトを登録
- `EditorSceneManager.SaveScene()` でシーン保存を忘れない

### Unity_RunCommand 既知の落とし穴
1. **`Image` 名前空間の衝突 (CS0118)**: `UnityEngine.UI.Image` は `Image` が namespace と型名で競合する。必ず `using UIImage = UnityEngine.UI.Image;` でエイリアスを使う
2. **TextMeshPro フォント**: `TMP_Settings.defaultFontAsset` は null を返すことがある。代わりに `AssetDatabase.FindAssets("t:TMP_FontAsset")` でフォントを検索する
3. **TMP Essential Resources**: TextMeshPro を使う前に Essential Resources がインポート済みか確認。未インポートなら `TMP_PackageResourceImporter` または手動インポートが必要
4. **大量のオブジェクト作成**: 1回の RunCommand で作るオブジェクト数が多い場合、機能ごとに分割して段階的に構築する（例: 地形→UI→ゲームロジック）

## Physics / Collision

### 3D
- `Rigidbody` + `Collider`（BoxCollider, SphereCollider, CapsuleCollider, MeshCollider）
- キャラクター移動: `CharacterController` または `Rigidbody` + `MovePosition`
- 高速移動オブジェクト: `CollisionDetectionMode.Continuous` を設定
- トリガー判定: `isTrigger = true` + `OnTriggerEnter(Collider other)`
- レイキャスト: `Physics.Raycast`, `Physics.SphereCast` でヒット判定

### 2D
- `Rigidbody2D` + `Collider2D` を使用（3D コンポーネントと混ぜない）
- 反射するオブジェクト（ボール等）: `PhysicsMaterial2D` (bounciness=1, friction=0) を設定
- 高速移動オブジェクト: `CollisionDetectionMode2D.Continuous` を設定（すり抜け防止）
- トリガー判定: `isTrigger = true` + `OnTriggerEnter2D` を使用

## 3D Game Visual Style (プリミティブベース)
外部3Dモデルなしで見栄えを良くする手法:
- **Low-poly スタイル**: Cube, Sphere, Capsule, Cylinder の組み合わせ
- **マテリアル**: URP Lit マテリアルで Metallic / Smoothness を調整、Emission で発光
- **ライティング**: Directional Light + Point Light で雰囲気を作る
- **パーティクル**: `ParticleSystem` でエフェクト（爆発、トレイル、環境演出）
- **Post Processing**: URP Volume で Bloom, Vignette, Color Grading
- **ProBuilder**: 簡易的な3Dメッシュ作成（com.unity.probuilder パッケージ）

## Coding Rules
- [SerializeField] は private フィールドに使用
- GetComponent() は Awake() でキャッシュ
- Update() 内で Find/GetComponent 禁止
- CompareTag() を使用（== "tag" 禁止）
- Camera.main はキャッシュ
- LINQ を Update/FixedUpdate 内で使用禁止
- Input は `UnityEngine.InputSystem` を使用: `Mouse.current`, `Keyboard.current` 等

## Do NOT
- .unity / .meta / .prefab / .asset ファイルを直接編集しない → MCP を使う
- Library/ フォルダに触れない
- ProjectSettings/*.asset を直接編集しない → Unity Editor から設定
- Packages/manifest.json を直接編集しない → MCP の Unity_PackageManager_ExecuteAction を使う
- **大型パッケージ（URP, Input System 等）を MCP 経由でインストールしない** → ドメインリロードで MCP 切断が起きる。manifest.json に事前追加しておくこと
- 旧 Input API (`Input.GetKey`, `Input.mousePosition` 等) を使わない → New Input System を使う
- 「File > Build Settings」を案内しない → Unity 6 では「Build Profiles」に変更済み。ビルドは `Unity_RunCommand` + `BuildPipeline` で実行

## PLANS.md 駆動開発
大規模なゲーム開発では PLANS.md でフェーズ管理する:
1. PLANS.md を作成し、フェーズごとのタスクを定義
2. 各フェーズの完了条件を明記（「Camera Capture で確認して動作すること」等）
3. 1フェーズ完了 → Camera Capture で確認 → PLANS.md のステータスを更新 → 次フェーズへ
4. フェーズ間でビルドが壊れていないか `Unity_GetConsoleLogs` で確認

## Development Loop (必ずこの順序で作業する)
1. **スクリプト作成/編集** → `Unity_CreateScript` or `Edit`
2. **コンパイル確認** → `Unity_GetConsoleLogs` でエラー確認。エラーがあれば修正して再確認
3. **シーン構築/変更** → `Unity_RunCommand` or `Unity_ManageGameObject` 等
4. **視覚確認** → `Unity_Camera_Capture` でスクリーンショット撮影。配置・見た目を確認
5. **問題があれば修正** → 1 に戻る
6. **次の機能へ進む**

各ステップで確認してから次に進むこと。まとめて作って最後に確認しない。

## WebGL Build
ビルドは `Unity_RunCommand` で実行する。**Unity 6 には「Build Settings」は存在しない（「Build Profiles」に変更済み）。旧来の「File > Build Settings」を案内してはいけない。**
**ビルド前に必ず `Unity_GetConsoleLogs` でコンパイル完了・エラーなしを確認してからビルドを実行すること。**

```csharp
internal class CommandScript : IRunCommand
{
    public void Execute(ExecutionResult result)
    {
        // コンパイル中・インポート中はビルド不可
        if (EditorApplication.isCompiling || EditorApplication.isUpdating)
        {
            result.LogError("Editor is still compiling or importing assets. Wait for completion and retry.");
            return;
        }

        // ビルドターゲットを WebGL に切り替え
        EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.WebGL, BuildTarget.WebGL);

        // ビルド対象シーンを設定
        var scenes = new[] { "Assets/Scenes/GameScene.unity" };

        // ビルド実行
        var buildResult = BuildPipeline.BuildPlayer(
            scenes,
            "Build/WebGL",
            BuildTarget.WebGL,
            BuildOptions.None
        );

        if (buildResult.summary.result == UnityEditor.Build.Reporting.BuildResult.Succeeded)
            result.Log($"WebGL build succeeded: {buildResult.summary.totalSize} bytes");
        else
            result.LogError($"Build failed: {buildResult.summary.result}");
    }
}
```
必要な using: `UnityEditor`, `UnityEditor.Build.Reporting`

### WebGL 注意事項
- `System.IO.File` 等のファイルシステム API は WebGL では使用不可
- `Thread` / `Task.Run` 等のマルチスレッドは WebGL では使用不可
- `PlayerPrefs` は使用可（WebGL では IndexedDB にマッピング）
- ビルド出力先は `Build/WebGL/` — .gitignore に追加すること

## Testing
- EditMode / PlayMode テスト: MCP `Unity_RunCommand` で実行
- C# 変更後は必ず `Unity_GetConsoleLogs` でコンパイルエラーを確認

## Git Workflow
- .meta ファイルは必ずコミットに含める
- Library/, Temp/, Logs/, UserSettings/ はコミット不可
- .asmdef ファイルは新規作成時にコミット
