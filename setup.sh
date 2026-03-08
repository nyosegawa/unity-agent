#!/bin/bash
# Unity × Claude Code 開発環境セットアップスクリプト
# Usage: ./setup.sh /path/to/UnityProject
#
# このスクリプトが行うこと:
#   1. .claude/ ディレクトリ一式をコピー（hooks, agents, skills, settings.json）
#   2. CLAUDE.md をコピー
#   3. AGENTS.md をコピー（Codex CLI 用、オプション）
#   4. Editor/McpScreenshotHelper.cs をコピー
#   5. Hook スクリプトに実行権限を付与
#   6. MCP サーバーの設定（claude mcp add-json）
#
# このスクリプトが行わないこと（手動が必要）:
#   - Unity パッケージのインストール（mcp-unity, gameplay-mcp）
#   - Unity Editor の起動
#   - Blender アドオンのインストール
#   - API キーの取得

set -euo pipefail

# ===== 引数チェック =====
if [ $# -lt 1 ]; then
  echo "Usage: $0 /path/to/UnityProject"
  echo ""
  echo "Example: $0 ~/Projects/MyUnityGame"
  exit 1
fi

UNITY_PROJECT="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/template"

# テンプレートディレクトリ確認
if [ ! -d "$TEMPLATE_DIR/.claude" ]; then
  echo "ERROR: template/ ディレクトリが見つかりません"
  echo "  このスクリプトはリポジトリルートから実行してください"
  exit 1
fi

# Unity プロジェクト確認
if [ ! -d "$UNITY_PROJECT/Assets" ] || [ ! -d "$UNITY_PROJECT/ProjectSettings" ]; then
  echo "ERROR: $UNITY_PROJECT は Unity プロジェクトではありません"
  echo "  Assets/ と ProjectSettings/ が存在するディレクトリを指定してください"
  exit 1
fi

echo "=== Unity × Claude Code セットアップ ==="
echo "Target: $UNITY_PROJECT"
echo ""

# ===== 1. .claude/ ディレクトリをコピー =====
echo "[1/6] .claude/ ディレクトリをコピー..."

# 既存の .claude/ があれば確認
if [ -d "$UNITY_PROJECT/.claude" ]; then
  echo "  WARNING: $UNITY_PROJECT/.claude/ が既に存在します"
  read -p "  上書きしますか？ (y/N): " confirm
  if [[ "$confirm" != [yY] ]]; then
    echo "  スキップしました"
  else
    cp -r "$TEMPLATE_DIR/.claude/"* "$UNITY_PROJECT/.claude/"
    echo "  Done (上書き)"
  fi
else
  cp -r "$TEMPLATE_DIR/.claude" "$UNITY_PROJECT/.claude"
  echo "  Done"
fi

# ===== 2. CLAUDE.md をコピー =====
echo "[2/6] CLAUDE.md をコピー..."
if [ -f "$UNITY_PROJECT/CLAUDE.md" ]; then
  echo "  WARNING: CLAUDE.md が既に存在します。スキップ。"
  echo "  手動でマージしてください: $TEMPLATE_DIR/CLAUDE.md"
else
  cp "$TEMPLATE_DIR/CLAUDE.md" "$UNITY_PROJECT/CLAUDE.md"
  echo "  Done"
fi

# ===== 3. AGENTS.md をコピー（Codex CLI 用） =====
echo "[3/6] AGENTS.md をコピー (Codex CLI 用)..."
if [ -f "$UNITY_PROJECT/AGENTS.md" ]; then
  echo "  WARNING: AGENTS.md が既に存在します。スキップ。"
else
  cp "$TEMPLATE_DIR/AGENTS.md" "$UNITY_PROJECT/AGENTS.md"
  echo "  Done"
fi

# ===== 4. Editor/McpScreenshotHelper.cs をコピー =====
echo "[4/6] McpScreenshotHelper.cs をコピー..."
mkdir -p "$UNITY_PROJECT/Assets/Editor"
if [ -f "$UNITY_PROJECT/Assets/Editor/McpScreenshotHelper.cs" ]; then
  echo "  WARNING: McpScreenshotHelper.cs が既に存在します。スキップ。"
else
  cp "$TEMPLATE_DIR/Editor/McpScreenshotHelper.cs" "$UNITY_PROJECT/Assets/Editor/McpScreenshotHelper.cs"
  echo "  Done"
fi

# ===== 5. 実行権限を付与 =====
echo "[5/6] Hook スクリプトに実行権限を付与..."
chmod +x "$UNITY_PROJECT/.claude/hooks/"*.sh
echo "  Done"

# ===== 6. MCP サーバー設定 =====
echo "[6/6] MCP サーバー設定..."
echo ""

# mcp-unity
MCP_UNITY_SERVER="$UNITY_PROJECT/Packages/com.gamelovers.mcp-unity/Server~/build/index.js"
if [ -f "$MCP_UNITY_SERVER" ]; then
  echo "  mcp-unity サーバーファイルを検出: $MCP_UNITY_SERVER"
  echo "  以下のコマンドで Claude Code に追加:"
  echo ""
  echo "  claude mcp add-json mcp-unity '{\"command\":\"node\",\"args\":[\"$MCP_UNITY_SERVER\"]}'"
  echo ""
else
  echo "  mcp-unity パッケージが未インストールです。"
  echo "  Unity Editor で以下を実行:"
  echo "    Window > Package Manager > + > Add package from git URL"
  echo "    URL: https://github.com/CoderGamester/mcp-unity.git"
  echo ""
  echo "  インストール後、以下のコマンドで Claude Code に追加:"
  echo "  claude mcp add-json mcp-unity '{\"command\":\"node\",\"args\":[\"$UNITY_PROJECT/Packages/com.gamelovers.mcp-unity/Server~/build/index.js\"]}'"
  echo ""
fi

# gameplay-mcp
echo "  [Optional] gameplay-mcp (ランタイムテスト / スクリーンショット):"
echo "  claude mcp add-json gameplay-mcp '{\"type\":\"http\",\"url\":\"http://localhost:8010/mcp\"}'"
echo ""

# nanobanana
echo "  [Optional] nanobanana (画像生成 — Gemini API Key 必要):"
echo "  claude mcp add-json nanobanana '{\"command\":\"uvx\",\"args\":[\"nanobanana-mcp-server@latest\"],\"env\":{\"GEMINI_API_KEY\":\"YOUR_KEY\"}}'"
echo ""

# blender-mcp
echo "  [Optional] blender-mcp (3Dモデル生成 — Blender 3.0+ 必要):"
echo "  claude mcp add-json blender '{\"command\":\"uvx\",\"args\":[\"blender-mcp\"]}'"
echo "  ※ Blender 側で addon.py をインストール: Edit > Preferences > Add-ons > Install"
echo ""

# audiogen-mcp
echo "  [Optional] audiogen-mcp (効果音生成 — Python 3.11 専用 venv 必要):"
echo "  # 先に venv 作成:"
echo "  # uv venv ~/.audiogen-env --python 3.11"
echo "  # uv pip install audiocraft --no-deps"
echo "  # uv pip install torch torchaudio transformers huggingface_hub encodec einops flashy num2words sentencepiece librosa av julius spacy torchmetrics hydra-core hydra-colorlog demucs lameenc"
echo "  # uv pip install audiogen-mcp"
echo "  claude mcp add audiogen ~/.audiogen-env/bin/python -- -m audiogen_mcp.server"
echo ""

echo "=== セットアップ完了 ==="
echo ""
echo "次のステップ:"
echo "  1. Unity Editor でプロジェクトを開く"
echo "  2. mcp-unity パッケージをインストール（まだの場合）"
echo "  3. Tools > MCP Unity > Server Window でサーバー起動を確認"
echo "  4. 上記の claude mcp add-json コマンドを実行"
echo "  5. cd $UNITY_PROJECT && claude"
echo "  6. テスト: 「シーンのヒエラルキー情報を取得して」"
