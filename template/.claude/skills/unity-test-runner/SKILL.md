---
name: unity-test-runner
description: Run and analyze Unity tests via Unity MCP. Use when running EditMode or PlayMode tests, creating test scripts, analyzing test failures, or when user asks to test code.
disable-model-invocation: true
allowed-tools: Read, Grep
---

# Unity Test Runner (via Unity MCP)

## Running Tests

### Via MCP (推奨)
`Unity_RunCommand` でテスト実行コードを記述:
```csharp
internal class CommandScript : IRunCommand
{
    public void Execute(ExecutionResult result)
    {
        // テスト実行のトリガー
        var testRunner = UnityEditor.TestTools.TestRunner;
        result.Log("Tests triggered");
    }
}
```

### Via Unity CLI (フォールバック)
```bash
# Windows
"C:\Program Files\Unity\Hub\Editor\*\Editor\Unity.exe" ^
  -batchmode -quit -projectPath . -runTests -testPlatform EditMode -testResults TestResults\results.xml

# macOS
/Applications/Unity/Hub/Editor/*/Unity.app/Contents/MacOS/Unity \
  -batchmode -quit -projectPath . -runTests -testPlatform EditMode \
  -testResults TestResults/results.xml
```

## Test File Structure
```csharp
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;

[TestFixture]
public class PlayerTests
{
    [Test]
    public void Health_TakeDamage_ReducesHealth()
    {
        // Arrange
        var go = new GameObject();
        var player = go.AddComponent<Player>();
        // Act
        player.TakeDamage(10);
        // Assert
        Assert.AreEqual(90, player.Health);
        Object.DestroyImmediate(go);
    }
}
```

## Examples

### Example 1: EditMode テスト作成と実行
1. `Unity_CreateScript` で Tests/Editor/ にテストスクリプト作成
2. `Unity_GetConsoleLogs` でコンパイル確認
3. テスト実行

### Example 2: テスト失敗の分析
1. テスト結果の total / passed / failed / skipped を報告
2. 失敗テスト: テスト名、エラーメッセージ、スタックトレース
3. 原因分析と修正提案

## Troubleshooting
- **テストが見つからない**: .asmdef の `includePlatforms` と参照を確認
- **PlayMode テスト接続切れ**: Project Settings > Editor > Enter Play Mode Settings > Reload Domain: OFF
- **テストアセンブリエラー**: Tests/ フォルダの .asmdef が Runtime の .asmdef を参照しているか確認

$ARGUMENTS
