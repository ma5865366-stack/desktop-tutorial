import SwiftUI
import UIKit

@main
struct M4DemoApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 20) {
                Text("M4-TOTK 设置界面测试").font(.title2).bold()
                Text("这只是无游戏数据的原生编译测试程序，不能运行《王国之泪》。")
                    .multilineTextAlignment(.center)
                Button("打开中文设置") {
                    if let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
                       let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                        M4SettingsBridge.show(from: root)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}
