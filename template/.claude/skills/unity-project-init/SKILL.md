---
name: unity-project-init
description: Initialize Unity project folder structure with best practices. Use when starting a new Unity project, setting up folder structure, creating Assembly Definitions, or when user asks to organize project layout.
disable-model-invocation: true
---

# Unity Project Initialization

## Folder Structure
`Unity_RunCommand` または `Unity_ManageAsset(Action: "CreateFolder")` で以下を作成:

```
Assets/
├── Scripts/
│   ├── Runtime/
│   │   ├── Core/           # GameManager, ServiceLocator
│   │   ├── Gameplay/       # Game mechanics
│   │   ├── UI/             # UI controllers
│   │   ├── Data/           # ScriptableObjects
│   │   └── Runtime.asmdef
│   └── Editor/
│       ├── Tools/          # Custom editor tools
│       └── Editor.asmdef
├── Prefabs/
├── Scenes/
├── Art/
│   ├── Materials/
│   ├── Textures/
│   ├── Sprites/
│   └── Models/
├── Audio/
│   ├── Music/
│   └── SFX/
└── Resources/              # Only for dynamically loaded assets
Tests/
├── Editor/
│   └── Tests.Editor.asmdef
└── Runtime/
    └── Tests.Runtime.asmdef
```

## Assembly Definitions
`.asmdef` で明確なモジュール境界を定義。Runtime と Editor を分離。

## Examples

### Example 1: 新規プロジェクトの初期化
```
Unity_RunCommand で以下を実行:
1. Assets/Scripts/Runtime/, Editor/ 等のフォルダ作成
2. .asmdef ファイル作成
3. .gitignore 確認
```

### Example 2: 既存プロジェクトの整理
1. `Unity_FindProjectAssets` で現在の構造確認
2. `Unity_ManageAsset(Action: "Move")` でファイル移動
3. .asmdef の参照を更新

## Troubleshooting
- **フォルダが Unity に認識されない**: `AssetDatabase.Refresh()` を実行
- **.asmdef 参照エラー**: Assembly Definition の References に必要なアセンブリを追加

$ARGUMENTS
