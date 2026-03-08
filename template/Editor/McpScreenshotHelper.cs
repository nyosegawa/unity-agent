// McpScreenshotHelper.cs
// mcp-unity にはスクリーンショット機能がないため、
// execute_menu_item 経由でスクリーンショットを撮るための補助スクリプト。
//
// 使い方:
//   1. このファイルを Assets/Editor/ にコピー
//   2. Claude Code から mcp-unity の execute_menu_item で
//      "Tools/MCP/Capture Game View Screenshot" を実行
//   3. Screenshots/ フォルダに画像が保存される
//   4. Claude Code の Read ツールで画像を読み取って分析

using UnityEditor;
using UnityEngine;
using System.IO;

public static class McpScreenshotHelper
{
    private const string ScreenshotDir = "Screenshots";

    [MenuItem("Tools/MCP/Capture Game View Screenshot")]
    public static void CaptureGameViewScreenshot()
    {
        Directory.CreateDirectory(ScreenshotDir);
        string filename = $"screenshot_{System.DateTime.Now:yyyyMMdd_HHmmss}.png";
        string path = Path.Combine(ScreenshotDir, filename);
        ScreenCapture.CaptureScreenshot(path);
        Debug.Log($"[MCP Screenshot] Saved to: {path}");
    }

    [MenuItem("Tools/MCP/Capture Game View Screenshot (SuperSize 2x)")]
    public static void CaptureGameViewScreenshotSuperSize()
    {
        Directory.CreateDirectory(ScreenshotDir);
        string filename = $"screenshot_{System.DateTime.Now:yyyyMMdd_HHmmss}_2x.png";
        string path = Path.Combine(ScreenshotDir, filename);
        ScreenCapture.CaptureScreenshot(path, 2);
        Debug.Log($"[MCP Screenshot] Saved to: {path} (2x supersize)");
    }
}
