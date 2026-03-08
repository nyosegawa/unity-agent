---
name: unity-test-runner
description: Run and analyze Unity tests via mcp-unity MCP. Executes EditMode and PlayMode tests, captures results, and provides detailed failure analysis.
disable-model-invocation: true
allowed-tools: Read, Grep
---

# Unity Test Runner (via mcp-unity MCP)

## Running Tests

### MCP (mcp-unity) の `run_tests` ツール

パラメータ:
- `testMode`: `"EditMode"` or `"PlayMode"` (default: EditMode)
- `testFilter`: テスト名フィルタ（namespace 含む）
- `returnOnlyFailures`: `true` で失敗テストのみ返す (default: true)
- `returnWithLogs`: `true` で詳細ログ付き (default: false)

### PlayMode テストの注意事項
- Domain Reload が無効である必要がある（WebSocket 接続が切れるため）
- Project Settings → Editor → Enter Play Mode Settings → Reload Domain: OFF

### Unity CLI (MCP が使えない場合のフォールバック)
```bash
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
