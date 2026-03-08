---
name: unity-compile-fixer
description: Diagnose and fix Unity C# compilation errors. Use when compilation fails, CS error codes appear, Unity_GetConsoleLogs shows errors, or user asks to fix compile errors.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
context: fork
---

# Unity Compile Error Fixer

## Workflow
1. `Unity_GetConsoleLogs` (logTypes: "error") でエラーを取得
2. エラーコードとメッセージを分析
3. 該当ファイルを Read で確認
4. Edit で修正
5. `Unity_GetConsoleLogs` で修正確認
6. エラーが残っていれば 2 に戻る

## Common Unity-Specific Errors

| Error Code | Cause | Fix |
|:--|:--|:--|
| CS0246 | Type not found | Add `using` directive or assembly reference |
| CS1061 | Member not found | Check Unity version API changes |
| CS0103 | Name not in scope | Check namespace, add `using` |
| CS0234 | Namespace member missing | Update package or add assembly reference |
| CS0029 | Cannot convert type | Check Unity type casting (Vector3 vs Vector2) |
| CS0117 | No member in type | API may have changed in Unity version |
| CS0619 | Member is obsolete | Use recommended replacement |
| CS0428 | Cannot convert method group | Add () for method call |

## Examples

### Example 1: Missing namespace
```
error CS0246: The type or namespace name 'InputAction' could not be found
```
Fix: Add `using UnityEngine.InputSystem;`

### Example 2: Old Input API
```
error CS0117: 'Input' does not contain a definition for 'GetKey'
```
Fix: Replace `Input.GetKey(KeyCode.Space)` with `Keyboard.current.spaceKey.isPressed`

### Example 3: Deprecated API
```
warning CS0618: 'FindObjectOfType<T>()' is obsolete
```
Fix: Replace with `FindFirstObjectByType<T>()`

## Troubleshooting
- **エラーが消えない**: .asmdef の参照が欠けている可能性。Assembly Definition を確認
- **パッケージ関連エラー**: Packages/manifest.json でパッケージバージョンを確認
- **Unity バージョン差異**: ProjectSettings/ProjectVersion.txt でバージョン確認
