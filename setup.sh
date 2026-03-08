#!/bin/bash
# Unity × Claude Code 開発環境セットアップスクリプト
# Usage: ./setup.sh /path/to/UnityProject
#
# このスクリプトが行うこと:
#   1. .claude/ ディレクトリ一式をコピー（hooks, agents, skills, settings.json）
#   2. CLAUDE.md をコピー
#   3. AGENTS.md をコピー（Codex CLI 用、オプション）
#   4. Hook スクリプトに実行権限を付与
#   5. MCP サーバーの接続案内
#
# このスクリプトが行わないこと（手動が必要）:
#   - Unity パッケージのインストール（com.unity.ai.assistant）
#   - Unity Editor の起動
#   - MCP 接続の承認（Unity Editor 側）
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
echo "[1/5] .claude/ ディレクトリをコピー..."

# 既存の .claude/ があれば確認
if [ -d "$UNITY_PROJECT/.claude" ]; then
  echo "  WARNING: $UNITY_PROJECT/.claude/ が既に存在します"
  read -p "  上書きしますか？ (y/N): " confirm
  if [[ "$confirm" != [yY] ]]; then
    echo "  スキップしました"
  else
    cp -r "$SCRIPT_DIR/template/.claude/"* "$UNITY_PROJECT/.claude/"
    echo "  Done (上書き)"
  fi
else
  cp -r "$SCRIPT_DIR/template/.claude" "$UNITY_PROJECT/.claude"
  echo "  Done"
fi

# ===== 2. CLAUDE.md をコピー =====
echo "[2/5] CLAUDE.md をコピー..."
if [ -f "$UNITY_PROJECT/CLAUDE.md" ]; then
  echo "  WARNING: CLAUDE.md が既に存在します。スキップ。"
  echo "  手動でマージしてください: $SCRIPT_DIR/template/CLAUDE.md"
else
  cp "$SCRIPT_DIR/template/CLAUDE.md" "$UNITY_PROJECT/CLAUDE.md"
  echo "  Done"
fi

# ===== 3. AGENTS.md をコピー（Codex CLI 用） =====
echo "[3/5] AGENTS.md をコピー (Codex CLI 用)..."
if [ -f "$UNITY_PROJECT/AGENTS.md" ]; then
  echo "  WARNING: AGENTS.md が既に存在します。スキップ。"
else
  cp "$SCRIPT_DIR/template/AGENTS.md" "$UNITY_PROJECT/AGENTS.md"
  echo "  Done"
fi

# ===== 4. 実行権限を付与 =====
echo "[4/5] Hook スクリプトに実行権限を付与..."
chmod +x "$UNITY_PROJECT/.claude/hooks/"*.sh
echo "  Done"

# ===== 5. MCP サーバー設定案内 =====
echo "[5/5] MCP サーバー設定..."
echo ""

# Unity MCP (com.unity.ai.assistant)
echo "  === Unity MCP (com.unity.ai.assistant) ==="
echo ""
echo "  Step 1: Unity Editor でパッケージをインストール"
echo "    Window > Package Manager > + > Add package by name"
echo "    Name: com.unity.ai.assistant"
echo ""
echo "  Step 2: Claude Code に MCP 接続を追加"
echo ""

# OS 判定
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "${WINDIR:-}" ]]; then
  # Windows
  echo "  Windows:"
  echo "  .claude.json の mcpServers に以下を追加:"
  echo '  "unity-mcp": {'
  echo '    "command": "cmd",'
  echo '    "args": ["/c", "%USERPROFILE%\\.unity\\relay\\relay_win.exe", "--mcp"]'
  echo '  }'
  echo ""
  echo "  または PowerShell で:"
  echo '  claude mcp add unity-mcp cmd -- /c %USERPROFILE%\.unity\relay\relay_win.exe --mcp'
elif [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  RELAY_PATH="$HOME/.unity/relay/relay"
  echo "  macOS:"
  echo "  claude mcp add-json unity-mcp '{\"command\":\"$RELAY_PATH\",\"args\":[\"--mcp\"]}'"
else
  # Linux
  RELAY_PATH="$HOME/.unity/relay/relay"
  echo "  Linux:"
  echo "  claude mcp add-json unity-mcp '{\"command\":\"$RELAY_PATH\",\"args\":[\"--mcp\"]}'"
fi
echo ""

echo "  Step 3: Unity Editor で接続を承認"
echo "    Edit > Project Settings > AI > Unity MCP"
echo "    → Accept で接続を許可"
echo ""

# Optional MCP servers
echo "  === Optional MCP サーバー ==="
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
echo "  2. com.unity.ai.assistant パッケージをインストール（まだの場合）"
echo "  3. Edit > Project Settings > AI > Unity MCP で接続確認"
echo "  4. 上記の MCP 接続コマンドを実行"
echo "  5. cd $UNITY_PROJECT && claude"
echo "  6. テスト: 「シーンのヒエラルキー情報を取得して」"
