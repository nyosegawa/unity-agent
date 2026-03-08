# Unity × Claude Code 完全自動開発環境

Coding Agent（Claude Code / Codex CLI）による Unity 完全自動開発のための設定ファイル一式。

## 何が入っているか

```
template/                              # setup.sh で Unity プロジェクトにコピーされる
├── .claude/
│   ├── settings.json                  # Hooks 設定
│   ├── hooks/
│   │   ├── unity-protect-assets.sh    # .unity/.meta/.prefab 直接編集ブロック
│   │   ├── unity-compile-check.sh     # C# 変更後のコンパイルチェック促進
│   │   └── unity-session-init.sh      # セッション開始時にプロジェクト情報注入
│   ├── agents/
│   │   ├── unity-coder.md             # C# コーディング専門
│   │   ├── unity-tester.md            # テスト生成・実行専門
│   │   ├── unity-reviewer.md          # コードレビュー専門
│   │   ├── unity-visual-checker.md    # スクリーンショット評価専門
│   │   └── unity-explorer.md          # コードベース調査専門 (Haiku)
│   └── skills/
│       ├── unity-coding-standards/    # C# コーディング規約 (自動読み込み)
│       ├── unity-compile-fixer/       # コンパイルエラー修正
│       ├── unity-scene-ops/           # MCP シーン操作リファレンス
│       ├── unity-test-runner/         # テスト実行リファレンス
│       └── unity-project-init/        # プロジェクト構造初期化
├── Editor/
│   └── McpScreenshotHelper.cs         # Editor スクリーンショット補助 (→ Assets/Editor/)
├── CLAUDE.md                          # Claude Code プロジェクト設定
└── AGENTS.md                          # Codex CLI プロジェクト設定
setup.sh                               # 自動セットアップスクリプト
```

## 採用 MCP サーバー

| 役割 | MCP | 必須/任意 |
|:---|:---|:---|
| Editor 操作 | [CoderGamester/mcp-unity](https://github.com/CoderGamester/mcp-unity) v1.2.0 | **必須** |
| ランタイムテスト・スクリーンショット | [nowsprinting/gameplay-mcp](https://github.com/nowsprinting/gameplay-mcp) v0.3.0 | 推奨 |
| 画像/テクスチャ生成 | [nanobanana-mcp-server](https://github.com/zhongweili/nanobanana-mcp-server) v0.4.2 | 任意 |
| 3D モデル生成 | [blender-mcp](https://github.com/ahujasid/blender-mcp) v1.5.5 | 任意 |
| 効果音生成 | [audiogen-mcp](https://github.com/peerjakobsen/audiogen-mcp) | 任意 |

### 重要な注意点

- **mcp-unity にスクリーンショット機能はない。** Editor スクリーンショットは `McpScreenshotHelper.cs` + `execute_menu_item` で対応。ランタイムスクリーンショットは gameplay-mcp の `take_screenshot` を使用。
- **blender-mcp の 3D 生成モデル（Hyper3D / Hunyuan3D）はオプション**で、別途 API Key が必要。Poly Haven（無料 CC0 アセット）は API Key 不要で使用可能。
- **audiogen-mcp は Python 3.11 専用 venv + audiocraft 依存**。インストールが複雑。初回起動で ~2GB のモデルをダウンロード。

---

## セットアップ手順

### 前提条件
- [x] Node.js 18+ (`brew install node`)
- [x] Unity 6.0+ (Unity Hub からインストール)
- [x] Claude Code (`npm install -g @anthropic-ai/claude-code`)
- [ ] Python 3.10+ / uv (`brew install uv`) — nanobanana 使用時
- [ ] Blender 3.0+ (`brew install --cask blender`) — blender-mcp 使用時
- [ ] Gemini API Key — nanobanana 使用時

### Step 1: Unity プロジェクト作成（手動）
Unity Hub で新規プロジェクト作成（3D URP 推奨）

### Step 2: mcp-unity パッケージインストール（手動）
```
Unity Editor:
  Window > Package Manager > + > Add package from git URL
  URL: https://github.com/CoderGamester/mcp-unity.git
```
インストール後:
```
  Tools > MCP Unity > Server Window
  → Status: Running, Port: 8090 を確認
```

### Step 3: 設定ファイルをコピー（自動）
```bash
# このリポジトリをクローン
ghq get git@github.com:nyosegawa/unity-agent.git

# セットアップスクリプトを実行
cd $(ghq root)/github.com/nyosegawa/unity-agent
chmod +x setup.sh
./setup.sh /path/to/UnityProject
```

### Step 4: MCP 接続設定
```bash
cd /path/to/UnityProject

# mcp-unity（必須）
claude mcp add-json mcp-unity '{"command":"node","args":["./Packages/com.gamelovers.mcp-unity/Server~/build/index.js"]}'

# gameplay-mcp（推奨 — ランタイムテスト・スクリーンショット）
claude mcp add-json gameplay-mcp '{"type":"http","url":"http://localhost:8010/mcp"}'

# nanobanana（任意 — 画像生成）
claude mcp add-json nanobanana '{"command":"uvx","args":["nanobanana-mcp-server@latest"],"env":{"GEMINI_API_KEY":"YOUR_KEY"}}'

# blender-mcp（任意 — 3D モデル）
claude mcp add-json blender '{"command":"uvx","args":["blender-mcp"]}'

# audiogen-mcp（任意 — 効果音）
# ※ 先に venv 構築が必要（setup.sh の出力参照）
claude mcp add audiogen ~/.audiogen-env/bin/python -- -m audiogen_mcp.server
```

### Step 5: 動作確認
```bash
cd /path/to/UnityProject
claude

# テスト1: MCP 接続
> シーンのヒエラルキー情報を取得して

# テスト2: C# + コンパイルチェック
> 回転するキューブのスクリプトを書いて

# テスト3: テスト実行
> 上のスクリプトの EditMode テストを書いて実行して
```

---

## 開発ループ

```
1. Claude Code が C# スクリプトを Edit/Write
   ↓
2. [Hook: PostToolUse] コンパイルチェック促進
   → recompile_scripts → get_console_logs
   → エラーあり → 自動修正 → 1 に戻る
   → 成功 ↓

3. MCP (mcp-unity) 経由でシーン構築
   → batch_execute で複数操作をアトミック実行
   ↓

4. MCP (mcp-unity) 経由で run_tests
   → テスト失敗 → ログ分析 → 1 に戻る
   → 成功 ↓

5. スクリーンショットで視覚確認
   → Editor: execute_menu_item "Tools/MCP/Capture Game View Screenshot" → Read
   → Runtime: gameplay-mcp の take_screenshot (base64 → 自動マルチモーダル解釈)
   → 問題あり → 修正 → 1 に戻る
   → 問題なし → 完了
```

---

## gameplay-mcp 追加セットアップ（ランタイムテスト用）

### Unity パッケージ依存
`Packages/manifest.json` に追加:
```json
{
  "dependencies": {
    "com.nowsprinting.test-helper": "https://github.com/nowsprinting/test-helper.git",
    "com.nowsprinting.test-helper.ui": "https://github.com/nowsprinting/test-helper.uikit.git",
    "jp.nowsprinting.gameplay-mcp": "https://github.com/nowsprinting/gameplay-mcp.git"
  }
}
```
- MCP C# SDK v1.0.0+ は NuGet 経由で別途導入

### C# 初期化コード（プロジェクトに追加）
```csharp
using UnityEngine;

public class GameplayMcpInitializer
{
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    private static void Initialize()
    {
        // gameplay-mcp v0.3.0 の初期化
        // 詳細は gameplay-mcp の README 参照
        var config = new McpConfig
        {
            ToolsNamespace = "mygame"
        };
        var server = new McpServer(config);
        server.StartAsync();
    }
}
```

### gameplay-mcp ツール (v0.3.0)
| ツール | 説明 |
|:---|:---|
| `inspect_game_object` | GameObject を名前/パス/テキストで検索・情報取得 |
| `list_available_actions` | 操作可能なアクション一覧 |
| `invoke_action` | Click/Drag/Swipe/TextInput 等の操作実行 |
| `take_screenshot` | ゲーム画面キャプチャ (JPEG/PNG, base64) |
| `list_scenes` | ロード済みシーン一覧 |

---

## blender-mcp 追加セットアップ（3D モデル生成用）

### インストール
1. Blender 3.0+ をインストール
2. blender-mcp の `addon.py` をダウンロード（[GitHub](https://github.com/ahujasid/blender-mcp)）
3. Blender: Edit > Preferences > Add-ons > Install... → `addon.py` を選択 → 有効化
4. Blender 3D Viewport サイドバー（N キー）→ BlenderMCP タブ → "Connect to Claude"
5. `claude mcp add-json blender '{"command":"uvx","args":["blender-mcp"]}'`

### 3D 生成モデル（オプション）
| 機能 | コスト | API Key |
|:---|:---|:---|
| Poly Haven (HDRI/テクスチャ/3Dモデル) | 無料 (CC0) | 不要 |
| Hyper3D Rodin (テキスト→3D) | $0.4/生成 or 月額$15~ | 必要 |
| Hunyuan3D (テキスト→3D) | $0.13-0.3/生成 or 自ホスト無料 | 必要(公式) / 不要(自ホスト) |
| Sketchfab (3Dモデル検索・DL) | 無料 | 必要 |

### Unity へのエクスポート
blender-mcp に直接の FBX/GLB エクスポートツールはない。`execute_blender_code` で:
```python
bpy.ops.export_scene.fbx(filepath="/path/to/model.fbx", apply_scale_options='FBX_SCALE_ALL')
```

### 注意事項
- テレメトリがデフォルト ON（Blender のアドオン設定で無効化可能）
- API Key は Blender 再起動で消える場合がある（既知バグ）
- MCP サーバーは 1 インスタンスのみ（複数エディタで同時使用不可）

---

## nanobanana 追加情報

### ツール
| ツール | 説明 |
|:---|:---|
| `generate_image` | テキストから画像生成（テクスチャ/スプライト/アイコン） |
| `edit_image` | 既存画像の編集 |
| `upload_file` | Gemini Files API 経由でファイル管理 |

### モデル選択
環境変数 `NANOBANANA_MODEL` で指定:
- `nb2` — Nano Banana 2 (default)
- `pro` — Gemini 3 Pro
- `flash` — Legacy Flash
- `auto` — 自動選択

### 出力先
環境変数 `IMAGE_OUTPUT_DIR` で指定（default: `~/nanobanana-images`）

---

## mcp-unity ツール一覧 (v1.2.0)

| カテゴリ | ツール名 | 説明 |
|:---|:---|:---|
| Scene | `create_scene` | シーン作成 |
| Scene | `load_scene` | シーンロード |
| Scene | `save_scene` | シーン保存 |
| Scene | `delete_scene` | シーン削除 |
| Scene | `unload_scene` | シーンアンロード |
| Scene | `get_scene_info` | シーン情報取得 |
| GameObject | `select_gameobject` | 選択 |
| GameObject | `get_gameobject` | 情報取得 |
| GameObject | `update_gameobject` | 更新 |
| GameObject | `duplicate_gameobject` | 複製 |
| GameObject | `delete_gameobject` | 削除 |
| GameObject | `reparent_gameobject` | 親子関係変更 |
| Transform | `move_gameobject` | 移動 |
| Transform | `rotate_gameobject` | 回転 |
| Transform | `scale_gameobject` | スケール変更 |
| Transform | `set_transform` | Transform 一括設定 |
| Material | `create_material` | マテリアル作成 |
| Material | `assign_material` | マテリアル割り当て |
| Material | `modify_material` | マテリアル変更 |
| Material | `get_material_info` | マテリアル情報取得 |
| Component | `update_component` | コンポーネント更新 |
| Asset | `add_asset_to_scene` | アセット追加 |
| Asset | `create_prefab` | プレハブ作成 |
| Package | `add_package` | パッケージ追加 |
| Test | `run_tests` | テスト実行 |
| Editor | `execute_menu_item` | メニューアイテム実行 |
| Editor | `recompile_scripts` | スクリプト再コンパイル |
| Console | `send_console_log` | コンソールログ送信 |
| Console | `get_console_logs` | コンソールログ取得 |
| Batch | `batch_execute` | 複数操作のアトミック実行 |
