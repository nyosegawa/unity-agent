---
name: unity-project-init
description: Initialize Unity project structure with best practices. Creates standard folder structure, Assembly Definitions, and configuration files.
disable-model-invocation: true
---

# Unity Project Initialization

Set up a production-ready Unity project structure:

## Folder Structure
```
Assets/
├── Scripts/
│   ├── Runtime/
│   │   ├── Core/           # Game managers, service locators
│   │   ├── Gameplay/       # Game mechanics
│   │   ├── UI/             # UI controllers
│   │   ├── Data/           # ScriptableObjects, data models
│   │   ├── Utils/          # Utility classes
│   │   └── Runtime.asmdef
│   └── Editor/
│       ├── Tools/          # Custom editor tools
│       ├── Inspectors/     # Custom inspectors
│       └── Editor.asmdef
├── Prefabs/
│   ├── Characters/
│   ├── UI/
│   └── Environment/
├── Scenes/
│   ├── Main.unity
│   └── Loading.unity
├── Art/
│   ├── Materials/
│   ├── Textures/
│   ├── Models/
│   └── Animations/
├── Audio/
│   ├── Music/
│   └── SFX/
├── Resources/              # Only for dynamically loaded assets
└── StreamingAssets/        # Only for raw files needed at runtime
Tests/
├── Editor/
│   └── Tests.Editor.asmdef
└── Runtime/
    └── Tests.Runtime.asmdef
```

## Assembly Definitions
Create `.asmdef` files with appropriate references to enforce module boundaries.

## .gitignore
Unity 用の .gitignore を設定（Library/, Temp/, Logs/, UserSettings/ 等）

$ARGUMENTS
