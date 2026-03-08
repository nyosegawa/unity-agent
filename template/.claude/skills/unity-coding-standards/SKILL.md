---
name: unity-coding-standards
description: Unity C# coding standards and best practices. Auto-loads when writing or reviewing C# code in Unity projects.
---

# Unity C# Coding Standards

## Naming Conventions
- Classes/Structs: PascalCase (`PlayerController`)
- Public methods/properties: PascalCase (`TakeDamage()`)
- Private fields: _camelCase (`_currentHealth`)
- [SerializeField] private fields: _camelCase (`_moveSpeed`)
- Local variables/parameters: camelCase (`hitPoint`)
- Constants: UPPER_CASE (`MAX_HEALTH`)
- Interfaces: I-prefix PascalCase (`IDamageable`)
- Enums: PascalCase, singular (`DamageType`)

## MonoBehaviour Patterns
```csharp
public class ExampleComponent : MonoBehaviour
{
    [Header("Configuration")]
    [SerializeField] private float _moveSpeed = 5f;
    [SerializeField] private LayerMask _groundLayer;

    [Header("References")]
    [SerializeField] private Transform _groundCheck;

    private Rigidbody _rb;
    private PlayerInput _input;

    private void Awake()
    {
        _rb = GetComponent<Rigidbody>();
        _input = GetComponent<PlayerInput>();
    }

    private void OnEnable() { /* Subscribe to events */ }
    private void OnDisable() { /* Unsubscribe from events */ }
}
```

## Anti-Patterns to Avoid
- `GameObject.Find()` in Update — cache the reference
- `GetComponent<T>()` in Update — cache in Awake
- `Camera.main` in Update — cache the reference
- String comparison for tags — use `CompareTag()`
- `new` allocations in Update — use object pooling
- LINQ in hot paths — generates garbage

## Assembly Definition Guidelines
- Separate runtime and editor code
- Define explicit references between assemblies
- Use `Tests/Editor/*.asmdef` and `Tests/Runtime/*.asmdef`
