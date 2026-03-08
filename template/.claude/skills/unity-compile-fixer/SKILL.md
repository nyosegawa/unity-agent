---
name: unity-compile-fixer
description: Diagnose and fix Unity C# compilation errors. Use when compilation fails or CS error codes appear.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
context: fork
---

# Unity Compile Error Fixer

## Workflow
1. MCP (mcp-unity) の `get_console_logs` でエラーを取得
2. エラーコードを分析して修正

## Common Unity-Specific Errors

| Error Code | Cause | Fix |
|:--|:--|:--|
| CS0246 | Type not found | Add using directive or assembly reference |
| CS1061 | Member not found | Check Unity version API changes |
| CS0103 | Name not in scope | Check namespace, add using |
| CS0234 | Namespace member missing | Update package or add assembly reference |
| CS0029 | Cannot convert type | Check Unity type casting (Vector3 vs Vector2, etc.) |
| CS0117 | No member in type | API may have changed in Unity version |
| CS0619 | Member is obsolete | Use recommended replacement |
| CS0428 | Cannot convert method group | Add () for method call or delegate creation |

## Fix Steps
1. Add missing `using` directives
2. Fix Assembly Definition references (.asmdef)
3. Update deprecated API calls
4. Resolve type mismatches
5. `recompile_scripts` で再コンパイル
6. `get_console_logs` で結果確認

## Important
- ProjectSettings/ProjectVersion.txt で Unity バージョンを確認
- Unity 2022 LTS / Unity 6 で API が異なる場合がある
- Packages/manifest.json で利用可能パッケージを確認
