# Unity Project

## Environment
- Unity 6.x LTS / URP
- Target: PC (初期)
- Language: C#

## MCP Tools Available
Unity Editor 起動中に以下の MCP ツールが利用可能:

### mcp-unity (Editor 操作)
- Scene: create / load / save / delete / unload / get_scene_info
- GameObject: select / get / update / duplicate / delete / reparent
- Transform: move / rotate / scale / set_transform
- Material: create / assign / modify / get_material_info
- Component: update_component
- Asset: add_asset_to_scene, create_prefab
- Package: add_package
- Test: run_tests (EditMode / PlayMode)
- Editor: execute_menu_item, recompile_scripts
- Console: send_console_log, get_console_logs
- Batch: batch_execute (アトミック操作、最大100操作)
- **注意: mcp-unity にスクリーンショット機能はない**
  - Editor: execute_menu_item で "Tools/MCP/Capture Game View Screenshot" → Read で画像確認
  - Runtime: gameplay-mcp の take_screenshot を使用

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
- Packages/manifest.json を直接編集しない → MCP の add_package を使う

## Testing
- EditMode: MCP run_tests (testMode: "EditMode") で実行
- PlayMode: MCP run_tests (testMode: "PlayMode") で実行
  - PlayMode テストには Domain Reload 無効が必要
- C# 変更後は recompile_scripts → get_console_logs でコンパイルチェック

## Git Workflow
- .meta ファイルは必ずコミットに含める
- Library/, Temp/, Logs/, UserSettings/ はコミット不可
- .asmdef ファイルは新規作成時にコミット
