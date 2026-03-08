#!/bin/bash
# PreToolUse Hook: Unity アセットファイルの直接編集をブロック
# 対象: Edit, Write, MultiEdit, Bash
# Exit 0 = 許可, Exit 2 = ブロック（stderrがClaudeへフィードバック）

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# ファイル編集系ツール: .unity/.meta/.asset の直接編集をブロック
if [[ "$TOOL_NAME" =~ ^(Edit|Write|MultiEdit)$ ]] && [ -n "$FILE_PATH" ]; then
  if [[ "$FILE_PATH" == *.unity ]]; then
    echo "BLOCKED: .unity ファイルの直接編集禁止。Unity MCP の Unity_ManageScene を使用してください。" >&2
    exit 2
  fi
  if [[ "$FILE_PATH" == *.meta ]]; then
    echo "BLOCKED: .meta ファイルは Unity が自動管理。手動編集禁止。" >&2
    exit 2
  fi
  if [[ "$FILE_PATH" == *.prefab ]]; then
    echo "BLOCKED: .prefab ファイルの直接編集禁止。Unity MCP の Unity_ManageGameObject / Unity_ManageAsset を使用してください。" >&2
    exit 2
  fi
  if [[ "$FILE_PATH" == */Library/* ]]; then
    echo "BLOCKED: Library/ は Unity の自動生成キャッシュ。編集禁止。" >&2
    exit 2
  fi
  if [[ "$FILE_PATH" == */ProjectSettings/*.asset ]]; then
    echo "BLOCKED: ProjectSettings/*.asset の直接編集禁止。Unity Editor から設定してください。" >&2
    exit 2
  fi
fi

# Bash: 危険な削除操作をブロック
if [[ "$TOOL_NAME" == "Bash" ]] && [ -n "$COMMAND" ]; then
  if echo "$COMMAND" | grep -qE "(rm|del).*\.(unity|prefab|asset)"; then
    echo "BLOCKED: Unity scene/prefab/asset ファイルの削除禁止。" >&2
    exit 2
  fi
  if echo "$COMMAND" | grep -qE "(rm -rf|rmdir).*Library/"; then
    echo "BLOCKED: Library/ 削除はフルリインポートを強制します。" >&2
    exit 2
  fi
fi

exit 0
