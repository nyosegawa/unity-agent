---
name: unity-test-runner
description: Run and analyze Unity tests via Unity MCP. Executes EditMode and PlayMode tests, captures results, and provides detailed failure analysis.
disable-model-invocation: true
allowed-tools: Read, Grep
---

# Unity Test Runner (via Unity MCP)

## Running Tests

### Unity MCP の `Unity_RunCommand` ツール
テスト実行には `Unity_RunCommand` を使用。

### PlayMode テストの注意事項
- Domain Reload が無効である必要がある場合がある
- Project Settings → Editor → Enter Play Mode Settings → Reload Domain: OFF

### Unity CLI (MCP が使えない場合のフォールバック)
```bash
# Windows
"C:\Program Files\Unity\Hub\Editor\*\Editor\Unity.exe" ^
  -batchmode -quit -projectPath . -runTests -testPlatform EditMode -testResults TestResults\results.xml

# macOS
/Applications/Unity/Hub/Editor/*/Unity.app/Contents/MacOS/Unity \
  -batchmode -quit \
  -projectPath "$CLAUDE_PROJECT_DIR" \
  -runTests \
  -testPlatform EditMode \
  -testResults "$CLAUDE_PROJECT_DIR/TestResults/results.xml"
```

## Analyzing Results
1. total / passed / failed / skipped を報告
2. 失敗テスト: テスト名、エラーメッセージ、スタックトレース
3. 各失敗の原因と修正提案

$ARGUMENTS
