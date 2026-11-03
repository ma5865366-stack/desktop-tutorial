import SwiftUI
import UIKit
import GameController

/// Compile into MacNativeGames games/totk/ios/Sources/.
/// The existing native iOS front-end must explicitly present this panel.
/// This file does not implement, replace or start the game runtime.
@objc(M4SettingsBridge)
public final class M4SettingsBridge: NSObject {
    @objc(showFrom:)
    public static func show(from controller: UIViewController) {
        let view = M4ControlPanel()
        let host = UIHostingController(rootView: view)
        host.modalPresentationStyle = .formSheet
        controller.present(host, animated: true)
    }
}

private struct M4ControlPanel: View {
    @Environment(\.dismiss) private var dismiss
    // Actual preference keys from upstream Settings.bundle/Root.plist
    @AppStorage("TOTK_CUSTOM_PICTURE") private var customPicture = false
    @AppStorage("TOTK_DOCKED") private var docked = true
    @AppStorage("TOTK_PHONE_FPS") private var fps = "60"
    @AppStorage("TOTK_ASPECT") private var aspect = ""
    @AppStorage("TOTK_LANG") private var language = "zh-Hans"
    @AppStorage("TOTK_PHONE_GYRO") private var touchGyro = true
    @AppStorage("TOTK_GYRO") private var controllerGyro = true
    @AppStorage("TOTK_RUMBLE") private var rumble = true
    @AppStorage("TOTK_DEBUG_LOG") private var debugLog = false
    @AppStorage("M4_EXPERIMENTAL_120HZ") private var experimental120 = false
    @State private var info = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("iPad Pro M4 · 性能预设") {
                    HStack {
                        ForEach(M4Preset.allCases) { preset in
                            Button(preset.rawValue) {
                                preset.apply()
                                customPicture = false
                                docked = (preset == .quality)
                                fps = (preset == .battery) ? "30" : "60"
                                info = "已选择「\(preset.rawValue)」，请从游戏启动界面开始游戏以应用画面设置。"
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    Text("这只是现有设置的快捷组合，不是自动调频；设置通常在重启游戏后生效。")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Section("画质与帧率") {
                    if customPicture {
                        Text("当前启用官方自定义画面模式；普通底座和帧率预设可能不生效。")
                            .font(.footnote).foregroundStyle(.orange)
                        Button("切换回预设画面") { customPicture = false }
                    }
                    Toggle("底座 Full HD 模式", isOn: $docked)
                    Picker("帧率目标", selection: $fps) {
                        Text("锁定 30 FPS").tag("30")
                        Text("最高 60 FPS").tag("60")
                    }
                    Picker("画面比例", selection: $aspect) {
                        Text("填满 iPad 屏幕").tag("")
                        Text("16:9 黑边").tag("0")
                    }
                    Picker("游戏语言", selection: $language) {
                        Text("简体中文").tag("zh-Hans")
                        Text("繁体中文").tag("zh-Hant")
                        Text("日语").tag("ja")
                        Text("英语").tag("en-US")
                        Text("系统自动").tag("")
                    }
                }
                Section("120Hz 实验 · 默认关闭") {
                    let panelRate = UIScreen.main.maximumFramesPerSecond
                    Text("设备屏幕最高刷新率：\(panelRate)Hz。当前官方 iOS 引擎仅固定使用 60Hz 同步；必须另外集成 v0.3 实验补丁才可能启用。")
                        .font(.footnote).foregroundStyle(.secondary)
                    Toggle("实验：请求 120Hz 显示同步", isOn: $experimental120)
                        .disabled(panelRate < 120 || UIDevice.current.userInterfaceIdiom != .pad)
                    Text("这不是 120 FPS 解锁保证。可能引起镜头速度、物理时序、掉帧和发热异常。必须重启游戏生效；遇到问题立即关闭并重启。")
                        .font(.footnote).foregroundStyle(.orange)
                    if experimental120 {
                        Text("已请求实验功能（仅保存配置；有无生效需查看运行日志及真实帧率）。")
                            .font(.footnote).foregroundStyle(.red)
                    }
                }
                Section("操控") {
                    Toggle("iPad 体感辅助", isOn: $touchGyro)
                    Toggle("手柄体感", isOn: $controllerGyro)
                    Toggle("手柄震动", isOn: $rumble)
                    Text("已检测到 \(GCController.controllers().count) 个连接手柄")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Section("本地诊断") {
                    Toggle("写入调试日志（需要重启）", isOn: $debugLog)
                    Button("生成设备与资源诊断") { info = M4DeviceDiagnostics.report() }
                    if !info.isEmpty {
                        Text(info).font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                        Button("复制诊断信息") { UIPasteboard.general.string = info }
                    }
                }
                Section {
                    Text("本面板与官方运行核心共用偏好设置。它不解锁任何第三方授权、不会导入未授权资源，也不保证帧率。")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("M4 控制中心")
            .toolbar { ToolbarItem(placement: .confirmationAction) {
                Button("完成") { dismiss() }
            }}
        }
    }
}

private enum M4DeviceDiagnostics {
    static func report() -> String {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first
        let free = (try? docs?.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]))?
            .volumeAvailableCapacityForImportantUsage
        let size: String = free.map { ByteCountFormatter.string(fromByteCount: $0, countStyle: .file) } ?? "未知"
        let files = (docs.flatMap { try? fm.contentsOfDirectory(at: $0, includingPropertiesForKeys: [.fileSizeKey]) }) ?? []
        let summary = files.sorted { $0.lastPathComponent < $1.lastPathComponent }.prefix(30).map { url in
            let bytes = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize
            return "- \(url.lastPathComponent) · \(bytes.map(String.init) ?? "directory/unknown") bytes"
        }.joined(separator: "\n")
        let thermal: String
        switch ProcessInfo.processInfo.thermalState {
        case .nominal: thermal = "nominal"
        case .fair: thermal = "fair"
        case .serious: thermal = "serious"
        case .critical: thermal = "critical"
        @unknown default: thermal = "unknown"
        }
        return """
        Thermal state: \(thermal)
        Device: \(UIDevice.current.model)
        OS: \(UIDevice.current.systemVersion)
        Memory: \(ByteCountFormatter.string(fromByteCount: Int64(ProcessInfo.processInfo.physicalMemory), countStyle: .memory))
        Free disk (approx): \(size)
        Screen maximum refresh (hardware): \(UIScreen.main.maximumFramesPerSecond) Hz
        Experimental high refresh preference: \(UserDefaults.standard.bool(forKey: "M4_EXPERIMENTAL_120HZ") ? "requested" : "off")
        WARNING: Screen Hz is not measured game FPS; 120 requires v0.3 runtime patch.
        Connected controllers: \(GCController.controllers().count)
        Game files in Documents (metadata only):
        \(summary)
        No files uploaded or opened by this diagnostic.
        """
    }
}
