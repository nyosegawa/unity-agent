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
├── CLAUDE.md                          # Claude Code プロジェクト設定
└── AGENTS.md                          # Codex CLI プロジェクト設定
setup.sh                               # 自動セットアップスクリプト
```

## 採用 MCP サーバー

| 役割 | MCP | 必須/任意 |
|:---|:---|:---|
| Editor 操作 | [Unity MCP](https://docs.unity3d.com/Packages/com.unity.ai.assistant@latest) (com.unity.ai.assistant) | **必須** |
| 画像/テクスチャ生成 | [nanobanana-mcp-server](https://github.com/zhongweili/nanobanana-mcp-server) v0.4.2 | 任意 |
| 3D モデル生成 | [blender-mcp](https://github.com/ahujasid/blender-mcp) v1.5.5 | 任意 |
| 効果音生成 | [audiogen-mcp](https://github.com/peerjakobsen/audiogen-mcp) | 任意 |

### 重要な注意点

- **Unity MCP (com.unity.ai.assistant) は Unity 公式のプレリリースパッケージ**。スクリーンショット機能が組み込み（`Unity_Camera_Capture`, `Unity_EditorWindow_CaptureScreenshot`, `Unity_SceneView_CaptureMultiAngleSceneView`）。
- **blender-mcp の 3D 生成モデル（Hyper3D / Hunyuan3D）はオプション**で、別途 API Key が必要。Poly Haven（無料 CC0 アセット）は API Key 不要で使用可能。
- **audiogen-mcp は Python 3.11 専用 venv + audiocraft 依存**。インストールが複雑。初回起動で ~2GB のモデルをダウンロード。

---

## セットアップ手順

### 前提条件
- [x] Node.js 22+ (`brew install node` or `fnm install 22`)
- [x] Unity 6.0+ (Unity Hub からインストール)
- [x] Claude Code (`npm install -g @anthropic-ai/claude-code`)
- [ ] Python 3.10+ / uv (`brew install uv`) — nanobanana 使用時
- [ ] Blender 3.0+ (`brew install --cask blender`) — blender-mcp 使用時
- [ ] Gemini API Key — nanobanana 使用時

### Step 1: Unity プロジェクト作成（手動）
Unity Hub で新規プロジェクト作成（3D URP 推奨）

### Step 2: Unity MCP パッケージインストール（手動）
```
Unity Editor:
  Window > Package Manager > + > Add package by name
  Name: com.unity.ai.assistant
```
インストール後:
```
  Edit > Project Settings > AI > Unity MCP
  → ステータスが Online であることを確認
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

#### Windows
`.claude.json` の該当プロジェクトの `mcpServers` に追加:
```json
{
  "unity-mcp": {
    "command": "cmd",
    "args": ["/c", "C:\\Users\\<USERNAME>\\.unity\\relay\\relay_win.exe", "--mcp"]
  }
}
```

#### macOS / Linux
```bash
cd /path/to/UnityProject
claude mcp add-json unity-mcp '{"command":"'$HOME'/.unity/relay/relay","args":["--mcp"]}'
```

#### 接続承認
Unity Editor: Edit > Project Settings > AI > Unity MCP → Accept

#### Optional MCP サーバー
```bash
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

# テスト3: スクリーンショット
> Scene View のスクリーンショットを撮って
```

---

## 開発ループ

```
1. Claude Code が C# スクリプトを Edit/Write
   ↓
2. [Hook: PostToolUse] コンパイルチェック促進
   → Unity_GetConsoleLogs でエラー確認
   → エラーあり → 自動修正 → 1 に戻る
   → 成功 ↓

3. Unity MCP 経由でシーン構築
   → Unity_ManageScene / Unity_ManageGameObject で操作
   ↓

4. Unity MCP 経由でテスト
   → Unity_RunCommand でテスト実行
   → テスト失敗 → ログ分析 → 1 に戻る
   → 成功 ↓

5. スクリーンショットで視覚確認
   → Unity_Camera_Capture / Unity_EditorWindow_CaptureScreenshot
   → Unity_SceneView_CaptureMultiAngleSceneView
   → 問題あり → 修正 → 1 に戻る
   → 問題なし → 完了
```

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

## Unity MCP ツール一覧 (com.unity.ai.assistant)

| カテゴリ | ツール名 | 説明 |
|:---|:---|:---|
| Core | `Unity_RunCommand` | コマンド実行 |
| Core | `Unity_ApplyTextEdits` | テキスト編集適用 |
| Core | `Unity_CreateScript` | スクリプト作成 |
| Core | `Unity_DeleteScript` | スクリプト削除 |
| Core | `Unity_FindInFile` | ファイル内検索 |
| Core | `Unity_GetSha` | SHA 取得 |
| Core | `Unity_ImportExternalModel` | 外部モデルインポート |
| Core | `Unity_ListResources` | リソース一覧 |
| Core | `Unity_ManageAsset` | アセット管理 |
| Core | `Unity_ManageEditor` | エディタ操作 |
| Core | `Unity_ManageGameObject` | GameObject 操作 |
| Core | `Unity_ManageMenuItem` | メニューアイテム実行 |
| Core | `Unity_ManageScene` | シーン管理 |
| Core | `Unity_ManageScript` | スクリプト管理 |
| Core | `Unity_ManageScript_capabilities` | スクリプト機能情報 |
| Core | `Unity_ReadResource` | リソース読み取り |
| Core | `Unity_ScriptApplyEdits` | スクリプト編集適用 |
| Core | `Unity_ValidateScript` | スクリプト検証 |
| Assets | `Unity_AssetGeneration_GenerateAsset` | アセット生成 |
| Assets | `Unity_AssetGeneration_GetModels` | 生成モデル取得 |
| Assets | `Unity_AssetGeneration_ConvertSpriteSheetToAnimationClip` | スプライトシート→アニメーション |
| Assets | `Unity_AssetGeneration_ConvertToMaterial` | マテリアル変換 |
| Assets | `Unity_AssetGeneration_ConvertToTerrainLayer` | テレインレイヤー変換 |
| Assets | `Unity_AssetGeneration_CreateAnimatorControllerFromClip` | アニメーターコントローラー作成 |
| Assets | `Unity_AssetGeneration_EditAnimationClipTool` | アニメーションクリップ編集 |
| Assets | `Unity_AssetGeneration_GetCompositionPatterns` | コンポジションパターン取得 |
| Assets | `Unity_FindProjectAssets` | アセット検索 |
| Assets | `Unity_ManageShader` | シェーダー管理 |
| Debug | `Unity_GetConsoleLogs` | コンソールログ取得 |
| Debug | `Unity_ReadConsole` | コンソール読み取り |
| Debug | `Unity_Profiler_*` | プロファイラー各種 (12 ツール) |
| Editor | `Unity_Camera_Capture` | カメラキャプチャ |
| Editor | `Unity_EditorWindow_CaptureScreenshot` | エディタウィンドウスクリーンショット |
| Editor | `Unity_SceneView_CaptureMultiAngleSceneView` | 複数アングルシーンビュー |
| Editor | `Unity_GetProjectData` | プロジェクト情報取得 |
| Editor | `Unity_GetUserGuidelines` | ユーザーガイドライン取得 |
| Editor | `Unity_PackageManager_ExecuteAction` | パッケージ操作 |
| Editor | `Unity_PackageManager_GetData` | パッケージ情報 |
