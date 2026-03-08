#!/bin/bash
# SessionStart Hook: セッション開始時に Unity プロジェクト情報をコンテキストに注入
# matcher: startup|resume

PROJECT_DIR="$CLAUDE_PROJECT_DIR"
echo "=== Unity Project Context ==="

# Unity バージョン検出
if [ -f "$PROJECT_DIR/ProjectSettings/ProjectVersion.txt" ]; then
  UNITY_VERSION=$(grep "m_EditorVersion:" "$PROJECT_DIR/ProjectSettings/ProjectVersion.txt" | awk '{print $2}')
  echo "Unity Version: $UNITY_VERSION"
fi

# Render Pipeline 検出
if [ -f "$PROJECT_DIR/Packages/manifest.json" ]; then
  if grep -q "com.unity.render-pipelines.universal" "$PROJECT_DIR/Packages/manifest.json" 2>/dev/null; then
    echo "Render Pipeline: URP"
  elif grep -q "com.unity.render-pipelines.high-definition" "$PROJECT_DIR/Packages/manifest.json" 2>/dev/null; then
    echo "Render Pipeline: HDRP"
  else
    echo "Render Pipeline: Built-in"
  fi

  # Input System 検出
  if grep -q "com.unity.inputsystem" "$PROJECT_DIR/Packages/manifest.json" 2>/dev/null; then
    echo "Input System: New Input System"
  else
    echo "Input System: Legacy"
  fi

  # Unity MCP (com.unity.ai.assistant) 導入確認
  if grep -q "com.unity.ai.assistant" "$PROJECT_DIR/Packages/manifest.json" 2>/dev/null; then
    echo "Unity MCP: Installed (com.unity.ai.assistant)"
  else
    echo "Unity MCP: NOT installed - Unity MCP tools unavailable"
  fi
fi

echo "==========================="
echo ""
echo "REMINDER: Unity Editor が起動中であることを確認。MCP 接続には Unity Editor が必要。"
echo "REMINDER: C# 変更後は Unity_GetConsoleLogs でコンパイルエラーを確認。"
echo "REMINDER: .unity / .meta / .prefab は直接編集不可 → MCP ツール使用。"
