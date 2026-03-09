#!/bin/bash
# Unity × Claude Code 開発環境セットアップスクリプト
#
# Usage:
#   ./setup.sh /full/path/to/UnityProject                  # 既存プロジェクトにセットアップ
#   ./setup.sh /full/path/to/NewProject --create            # プロジェクト新規作成 + セットアップ
#   ./setup.sh /full/path/to/NewProject --create --template com.unity.template.universal
#
# WSL の場合は必ず /mnt/c/... のフルパスを指定:
#   ./setup.sh /mnt/c/Users/username/Projects/MyGame --create
#
# Options:
#   --create          Unity プロジェクトを新規作成
#   --template ID     テンプレート指定 (default: com.unity.template.universal)
#   --skip-mcp-add    claude mcp add を実行しない
#
# 自動で行うこと:
#   1. [--create] Unity プロジェクト新規作成 (Unity CLI batchmode)
#   2. com.unity.ai.assistant を Packages/manifest.json に追加
#   3. .claude/ ディレクトリ一式をコピー（hooks, skills, settings.json）
#   4. CLAUDE.md / AGENTS.md をコピー
#   5. Hook スクリプトに実行権限を付与
#   6. claude mcp add で MCP 接続を自動設定
#
# 手動が必要なこと:
#   - Unity Editor の起動
#   - MCP 接続の承認（Unity Editor 側: Edit > Project Settings > AI > Unity MCP > Accept）

set -euo pipefail

# ===== WSL 判定 =====
is_wsl() {
  [[ -d "/mnt/c/Windows" ]] || grep -qi microsoft /proc/version 2>/dev/null
}

# WSL パス → Windows パスに変換
to_win_path() {
  if command -v wslpath &>/dev/null; then
    wslpath -w "$1"
  else
    # フォールバック: /mnt/c/foo → C:\foo
    echo "$1" | sed 's|^/mnt/\([a-z]\)/|\U\1:\\|; s|/|\\|g'
  fi
}

# ===== 引数パース =====
CREATE_PROJECT=false
TEMPLATE_ID="com.unity.template.universal"
SKIP_MCP_ADD=false
UNITY_PROJECT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --create)
      CREATE_PROJECT=true
      shift
      ;;
    --template)
      TEMPLATE_ID="$2"
      shift 2
      ;;
    --skip-mcp-add)
      SKIP_MCP_ADD=true
      shift
      ;;
    -h|--help)
      head -25 "$0" | grep '^#' | sed 's/^# \?//'
      exit 0
      ;;
    *)
      if [ -z "$UNITY_PROJECT" ]; then
        UNITY_PROJECT="$1"
      else
        echo "ERROR: 不明な引数: $1"
        exit 1
      fi
      shift
      ;;
  esac
done

if [ -z "$UNITY_PROJECT" ]; then
  echo "Usage: $0 /full/path/to/UnityProject [--create] [--template ID]"
  echo ""
  echo "  --create          新規プロジェクト作成"
  echo "  --template ID     テンプレート (default: com.unity.template.universal)"
  echo "  --skip-mcp-add    claude mcp add をスキップ"
  echo ""
  echo "Examples (macOS):"
  echo "  $0 /Users/you/Projects/MyGame --create"
  echo ""
  echo "Examples (WSL → Windows Unity):"
  echo "  $0 /mnt/c/Users/you/Projects/MyGame --create"
  echo "  $0 /mnt/c/Users/you/Projects/ExistingGame"
  exit 1
fi

# ===== フルパス検証 =====
if [[ "$UNITY_PROJECT" != /* ]]; then
  echo "ERROR: フルパスを指定してください（~ や相対パスは不可）"
  echo "  例: $0 /mnt/c/Users/you/Projects/MyGame --create"
  exit 1
fi

# ===== WSL パス検証 =====
if is_wsl; then
  if [[ "$UNITY_PROJECT" != /mnt/* ]]; then
    echo "ERROR: WSL 環境では /mnt/c/... のパスを指定してください"
    echo "  Windows Unity は Linux ファイルシステム上のプロジェクトにアクセスできません"
    echo ""
    echo "  例: $0 /mnt/c/Users/$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')/Projects/MyGame --create"
    exit 1
  fi
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ===== Unity Editor パス検出 =====
find_unity_editor() {
  local unity_path=""

  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    unity_path=$(find /Applications/Unity/Hub/Editor -name Unity -path "*/MacOS/Unity" 2>/dev/null | sort -rV | head -1)
  elif is_wsl; then
    # WSL → Windows Unity
    unity_path=$(find "/mnt/c/Program Files/Unity/Hub/Editor" -name Unity.exe -path "*/Editor/Unity.exe" 2>/dev/null | sort -rV | head -1)
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    unity_path=$(find ~/Unity/Hub/Editor -name Unity -path "*/Editor/Unity" 2>/dev/null | sort -rV | head -1)
  fi

  echo "$unity_path"
}

echo "=== Unity × Claude Code セットアップ ==="
echo "Target: $UNITY_PROJECT"
if is_wsl; then
  echo "Environment: WSL → Windows"
fi
echo ""

# ===== Step 0: プロジェクト新規作成 (--create) =====
if [ "$CREATE_PROJECT" = true ]; then
  if [ -d "$UNITY_PROJECT/Assets" ]; then
    echo "WARNING: $UNITY_PROJECT は既に Unity プロジェクトです。作成をスキップ。"
  else
    echo "[0] Unity プロジェクトを新規作成..."
    echo "  Template: $TEMPLATE_ID"

    UNITY_EDITOR=$(find_unity_editor)

    if [ -z "$UNITY_EDITOR" ]; then
      echo "ERROR: Unity Editor が見つかりません"
      echo "  Unity Hub からエディタをインストールしてください"
      exit 1
    fi

    echo "  Unity Editor: $UNITY_EDITOR"
    echo "  作成中（数分かかります）..."

    # WSL の場合は Windows パスに変換して渡す
    if is_wsl; then
      WIN_PROJECT_PATH=$(to_win_path "$UNITY_PROJECT")
      echo "  Windows path: $WIN_PROJECT_PATH"
      "$UNITY_EDITOR" -createProject "$WIN_PROJECT_PATH" -quit -batchmode 2>&1 | tail -5 || true
    else
      "$UNITY_EDITOR" -createProject "$UNITY_PROJECT" -quit -batchmode 2>&1 | tail -5 || true
    fi

    # 作成確認
    if [ ! -d "$UNITY_PROJECT/Assets" ]; then
      echo "ERROR: プロジェクト作成に失敗しました"
      exit 1
    fi

    echo "  Done"
    echo ""
  fi
fi

# Unity プロジェクト確認
if [ ! -d "$UNITY_PROJECT/Assets" ] || [ ! -d "$UNITY_PROJECT/ProjectSettings" ]; then
  echo "ERROR: $UNITY_PROJECT は Unity プロジェクトではありません"
  echo "  Assets/ と ProjectSettings/ が存在するディレクトリを指定してください"
  echo "  新規作成する場合: $0 $UNITY_PROJECT --create"
  exit 1
fi

# ===== Step 1: com.unity.ai.assistant を manifest.json に追加 =====
echo "[1/6] com.unity.ai.assistant パッケージを追加..."
MANIFEST="$UNITY_PROJECT/Packages/manifest.json"

if [ ! -f "$MANIFEST" ]; then
  echo "  ERROR: $MANIFEST が見つかりません"
  exit 1
fi

if grep -q "com.unity.ai.assistant" "$MANIFEST"; then
  echo "  既にインストール済み。スキップ。"
else
  # jq があれば使う、なければ sed で追加
  if command -v jq &>/dev/null; then
    tmp=$(mktemp)
    jq '.dependencies["com.unity.ai.assistant"] = "2.0.0-pre.1"' "$MANIFEST" > "$tmp"
    # mv は Windows FS で権限エラーが出るため cp + rm を使う
    cp "$tmp" "$MANIFEST"
    rm -f "$tmp"
    echo "  Done (jq)"
  else
    # sed: "dependencies": { の次の行に追加
    sed -i.bak '/"dependencies"[[:space:]]*:[[:space:]]*{/a\
    "com.unity.ai.assistant": "2.0.0-pre.1",
' "$MANIFEST"
    rm -f "$MANIFEST.bak"
    echo "  Done (sed)"
  fi
fi

# ===== Step 2: .claude/ ディレクトリをコピー =====
echo "[2/6] .claude/ ディレクトリをコピー..."

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

# ===== Step 3: CLAUDE.md をコピー =====
echo "[3/6] CLAUDE.md をコピー..."
if [ -f "$UNITY_PROJECT/CLAUDE.md" ]; then
  echo "  WARNING: CLAUDE.md が既に存在します。スキップ。"
  echo "  手動でマージしてください: $SCRIPT_DIR/template/CLAUDE.md"
else
  cp "$SCRIPT_DIR/template/CLAUDE.md" "$UNITY_PROJECT/CLAUDE.md"
  echo "  Done"
fi

# ===== Step 4: AGENTS.md をコピー（Codex CLI 用） =====
echo "[4/6] AGENTS.md をコピー (Codex CLI 用)..."
if [ -f "$UNITY_PROJECT/AGENTS.md" ]; then
  echo "  WARNING: AGENTS.md が既に存在します。スキップ。"
else
  cp "$SCRIPT_DIR/template/AGENTS.md" "$UNITY_PROJECT/AGENTS.md"
  echo "  Done"
fi

# ===== Step 5: 実行権限を付与 + CRLF 修正 =====
echo "[5/6] Hook スクリプトに実行権限を付与..."
if ls "$UNITY_PROJECT/.claude/hooks/"*.sh &>/dev/null; then
  chmod +x "$UNITY_PROJECT/.claude/hooks/"*.sh 2>/dev/null || true

  # Windows FS (WSL /mnt/) の場合、CRLF を LF に変換
  if [[ "$UNITY_PROJECT" == /mnt/* ]]; then
    echo "  Windows FS 検出: CRLF → LF 変換..."
    for f in "$UNITY_PROJECT/.claude/hooks/"*.sh; do
      sed -i 's/\r$//' "$f" 2>/dev/null || true
    done
  fi

  echo "  Done"
else
  echo "  Hook スクリプトなし。スキップ。"
fi

# ===== Step 6: claude mcp add で MCP 接続を自動設定 =====
echo "[6/6] MCP 接続を設定..."

if [ "$SKIP_MCP_ADD" = true ]; then
  echo "  --skip-mcp-add: スキップ。"
elif ! command -v claude &>/dev/null; then
  echo "  WARNING: claude コマンドが見つかりません。手動で MCP 接続を設定してください。"
else
  # プロジェクトディレクトリで実行（-s project はカレントディレクトリ基準のため）
  (
    cd "$UNITY_PROJECT"

    # 既存の unity-mcp 設定を確認
    if claude mcp list 2>/dev/null | grep -q "unity-mcp"; then
      echo "  unity-mcp は既に設定済み。スキップ。"
    else
      if is_wsl; then
        # WSL → Windows relay
        RELAY_WIN=""
        if [[ "$UNITY_PROJECT" =~ ^/mnt/[a-z]/[Uu]sers/([^/]+)/ ]]; then
          WIN_USER="${BASH_REMATCH[1]}"
          DRIVE="${UNITY_PROJECT:5:1}"
          candidate="/mnt/$DRIVE/Users/$WIN_USER/.unity/relay/relay_win.exe"
          if [ -f "$candidate" ]; then
            RELAY_WIN="$candidate"
          fi
        fi
        # フォールバック: glob 検索
        if [ -z "$RELAY_WIN" ]; then
          RELAY_WIN=$(ls /mnt/c/Users/*/.unity/relay/relay_win.exe 2>/dev/null | head -1 || echo "")
        fi

        if [ -n "$RELAY_WIN" ]; then
          echo "  relay: $RELAY_WIN"
          claude mcp add-json unity-mcp "{\"command\":\"$RELAY_WIN\",\"args\":[\"--mcp\"]}" -s project 2>/dev/null && \
            echo "  Done (WSL → Windows relay)" || \
            echo "  WARNING: claude mcp add に失敗。手動で設定してください。"
        else
          echo "  WARNING: relay_win.exe が見つかりません。"
          echo "  Unity Editor で com.unity.ai.assistant をインストール後、再実行してください。"
        fi
      elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        RELAY_PATH="$HOME/.unity/relay/relay"
        if [ -f "$RELAY_PATH" ]; then
          claude mcp add-json unity-mcp "{\"command\":\"$RELAY_PATH\",\"args\":[\"--mcp\"]}" -s project 2>/dev/null && \
            echo "  Done (macOS relay)" || \
            echo "  WARNING: claude mcp add に失敗。手動で設定してください。"
        else
          echo "  WARNING: relay バイナリが見つかりません ($RELAY_PATH)"
          echo "  Unity Editor で com.unity.ai.assistant をインストール後、再実行してください。"
        fi
      else
        # Linux
        RELAY_PATH="$HOME/.unity/relay/relay"
        if [ -f "$RELAY_PATH" ]; then
          claude mcp add-json unity-mcp "{\"command\":\"$RELAY_PATH\",\"args\":[\"--mcp\"]}" -s project 2>/dev/null && \
            echo "  Done (Linux relay)" || \
            echo "  WARNING: claude mcp add に失敗。手動で設定してください。"
        else
          echo "  WARNING: relay バイナリが見つかりません ($RELAY_PATH)"
          echo "  Unity Editor で com.unity.ai.assistant をインストール後、再実行してください。"
        fi
      fi
    fi
  )
fi

echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "次のステップ:"
echo "  1. Unity Hub でプロジェクトを開く: $UNITY_PROJECT"
echo "  2. Edit > Project Settings > AI > Unity MCP → Accept で接続を許可"
echo "  3. cd $UNITY_PROJECT && claude"
echo "  4. テスト: 「シーンのヒエラルキー情報を取得して」"
echo ""
echo "Optional MCP サーバー:"
echo "  nanobanana (画像生成):"
echo "    claude mcp add-json nanobanana '{\"command\":\"uvx\",\"args\":[\"nanobanana-mcp-server@latest\"],\"env\":{\"GEMINI_API_KEY\":\"YOUR_KEY\"}}'"
echo ""
echo "  blender-mcp (3Dモデル生成):"
echo "    claude mcp add-json blender '{\"command\":\"uvx\",\"args\":[\"blender-mcp\"]}'"
echo ""
