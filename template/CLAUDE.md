# Unity Project

## Environment
- Unity 6.x LTS / URP
- Target: PC (初期)
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
- `Unity_RunCommand` — コマンド実行（コンパイル、テスト等）
- `Unity_FindInFile` — ファイル内検索
- `Unity_ReadResource` / `Unity_ListResources` — リソース読み取り
- `Unity_FindProjectAssets` — アセット検索

### Debug & Diagnostics
- `Unity_GetConsoleLogs` — コンソールログ取得
- `Unity_ReadConsole` — コンソール読み取り
- `Unity_Profiler_*` — プロファイラー情報取得

### Editor & Screenshots
- `Unity_Camera_Capture` — カメラキャプチャ
- `Unity_EditorWindow_CaptureScreenshot` — エディタウィンドウのスクリーンショット
- `Unity_SceneView_CaptureMultiAngleSceneView` — 複数アングルからのシーンビュー撮影
- `Unity_GetProjectData` — プロジェクト情報取得
- `Unity_PackageManager_GetData` / `Unity_PackageManager_ExecuteAction` — パッケージ管理

### Assets
- `Unity_AssetGeneration_GenerateAsset` — アセット生成
- `Unity_AssetGeneration_GetModels` — モデル取得
- `Unity_ImportExternalModel` — 外部モデルインポート
- `Unity_ManageShader` — シェーダー管理

## Coding Rules
- [SerializeField] は private フィールドに使用
- GetComponent() は Awake() でキャッシュ
- Update() 内で Find/GetComponent 禁止
- CompareTag() を使用（== "tag" 禁止）
- Camera.main はキャッシュ
- LINQ を Update/FixedUpdate 内で使用禁止

## Do NOT
- .unity / .meta / .prefab / .asset ファイルを直接編集しない → MCP を使う
- Library/ フォルダに触れない
- ProjectSettings/*.asset を直接編集しない → Unity Editor から設定
- Packages/manifest.json を直接編集しない → MCP の Unity_PackageManager_ExecuteAction を使う

## Testing
- EditMode / PlayMode テスト: MCP `Unity_RunCommand` で実行
- C# 変更後は `Unity_GetConsoleLogs` でコンパイルエラーを確認

## Git Workflow
- .meta ファイルは必ずコミットに含める
- Library/, Temp/, Logs/, UserSettings/ はコミット不可
- .asmdef ファイルは新規作成時にコミット
