#!/bin/bash
# PostToolUse Hook: C# ファイル変更後にコンパイルチェックを促す
# 対象: Edit, Write, MultiEdit
# Unity MCP の Unity_GetConsoleLogs でエラーを確認

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# C# ファイル以外は無視
[[ "$FILE_PATH" != *.cs ]] && exit 0

echo "C# file modified: $FILE_PATH"
echo "ACTION REQUIRED: Unity MCP の Unity_GetConsoleLogs でコンパイルエラーを確認してください。"
exit 0
