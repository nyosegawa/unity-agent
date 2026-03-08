# Unity Project

## Environment
- Unity 6.x LTS
- Render Pipeline: URP (Universal Render Pipeline)
- Input: New Input System (com.unity.inputsystem)
- Platforms: PC (initial target)

## C# Coding Standards
- Use `[SerializeField]` for private Inspector fields, never public fields
- Cache `GetComponent<T>()` results in `Awake()`
- Use `CompareTag()` instead of string comparison
- Use `TryGetComponent<T>()` when the component might not exist
- Prefix private fields with underscore: `_fieldName`
- PascalCase for public members, camelCase for locals
- Always add `[Header("Section")]` to group serialized fields

## Forbidden Patterns
- NO `GameObject.Find()` or `FindObjectOfType()` in Update/FixedUpdate
- NO `new` allocations in Update loops (use object pooling)
- NO LINQ in performance-critical paths
- NO direct scene file (.unity) editing
- NO manual .meta file editing
- NO Camera.main without caching

## Architecture
- ScriptableObjects for configuration and shared data
- Events (C# events or UnityEvent) for component communication
- Assembly Definitions (.asmdef) for all script folders
- Separate Editor/ and Runtime/ code strictly

## File Organization
- Scripts: `Assets/Scripts/Runtime/` and `Assets/Scripts/Editor/`
- Tests: `Tests/Editor/` (EditMode) and `Tests/Runtime/` (PlayMode)
- Prefabs: `Assets/Prefabs/`
- Scenes: `Assets/Scenes/`

## Commands
```bash
# Compile check (via Unity CLI)
/Applications/Unity/Hub/Editor/*/Unity.app/Contents/MacOS/Unity \
  -batchmode -quit -projectPath . -executeMethod CompilationPipeline.RequestScriptCompilation

# Run EditMode tests
/Applications/Unity/Hub/Editor/*/Unity.app/Contents/MacOS/Unity \
  -batchmode -quit -projectPath . -runTests -testPlatform EditMode -testResults TestResults/results.xml
```

## Safety
- NEVER delete .unity, .prefab, or .asset files
- NEVER modify files in ProjectSettings/ directly
- NEVER remove Library/ folder
- Always include matching .meta files when creating new assets
