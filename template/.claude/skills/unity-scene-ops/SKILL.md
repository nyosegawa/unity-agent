---
name: unity-scene-ops
description: Manage Unity scenes, GameObjects, and components through mcp-unity MCP. Use for scene hierarchy manipulation, component setup, and prefab operations.
disable-model-invocation: true
---

# Unity Scene Operations (via mcp-unity MCP)

## Prerequisites
Unity Editor must be open with mcp-unity package active.

## Available MCP Tools (mcp-unity v1.2.0)

### Scene Management
- `create_scene` — 新規シーン作成
- `load_scene` — シーンロード
- `save_scene` — シーン保存
- `delete_scene` — シーン削除
- `unload_scene` — シーンアンロード
- `get_scene_info` — シーン情報取得

### GameObject Operations
- `select_gameobject` — 選択
- `get_gameobject` — 情報取得
- `update_gameobject` — 更新（名前、アクティブ状態等）
- `duplicate_gameobject` — 複製
- `delete_gameobject` — 削除
- `reparent_gameobject` — 親子関係変更

### Transform Operations
- `move_gameobject` — 移動
- `rotate_gameobject` — 回転
- `scale_gameobject` — スケール
- `set_transform` — Transform 一括設定

### Material Operations
- `create_material` — マテリアル作成
- `assign_material` — マテリアル割り当て
- `modify_material` — マテリアル変更
- `get_material_info` — マテリアル情報取得

### Component & Asset
- `update_component` — コンポーネント更新
- `add_asset_to_scene` — アセットをシーンに追加
- `create_prefab` — プレハブ作成

### Package & Testing
- `add_package` — パッケージ追加
- `run_tests` — テスト実行 (EditMode/PlayMode)

### Editor & Scripting
- `execute_menu_item` — メニューアイテム実行
- `recompile_scripts` — スクリプト再コンパイル
- `send_console_log` — コンソールログ送信
- `get_console_logs` — コンソールログ取得

### Batch Operations
- `batch_execute` — 複数操作のアトミック実行（最大100操作、ロールバック対応）

## Important Notes
- シーン変更後は `save_scene` で保存
- `batch_execute` で `atomic: true` を指定するとエラー時に全操作ロールバック
- `batch_execute` で `stopOnError: true` を指定すると最初のエラーで停止

$ARGUMENTS
