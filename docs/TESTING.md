# 测试与运行说明

## 验证环境

- Flutter：3.41.6（stable）
- Dart：3.11.4
- Xcode：26.0.1
- 模拟器：iPhone 17 Pro，iOS 26.0
- 截图：原生模拟器 PNG，1206 × 2622

## 已通过的检查

| 检查 | 内容 | 结果 |
| --- | --- | --- |
| iOS 构建 | `flutter build ios --simulator --debug`，安装并启动正常入口 | 通过 |
| 静态检查 | `flutter analyze` | 无问题 |
| 数据测试 1 | 卡片更新、议程、参与者、个人设置重新加载 | 通过 |
| 数据测试 2 | 连续快速勾选按顺序持久化 | 通过 |
| 数据测试 3 | 无效 JSON 回退到默认演示数据 | 通过 |
| 组件测试 1 | Teams / Personal 筛选及搜索空结果 | 通过 |
| 组件测试 2–4 | 5 个主页面在 390 × 844、414 × 896、360 × 800 下无布局异常 | 通过 |
| 模拟器集成测试 | 创建、编辑、日期选择、成员选择、日程切换、清单、个人资料及页面截图 | 通过 |

单元 / 组件测试合计 7 项，模拟器端到端场景 1 项。

## 端到端测试流程

1. 在测试模拟器清空本 App 的本地演示数据并启动首页。
2. 打开菜单和新建页面；验证空标题不能保存。
3. 填写标题、确认开始日期、选择分类、增加成员并创建任务。
4. 搜索新任务，进入编辑，修改标题并确认重新加载后数据正确。
5. 打开日程，切换日期，再进入 Meeting 的进度页。
6. 勾选议程，编辑议程文本并验证本地保存。
7. 打开个人页、消息入口、联系人、关于自己和设置。
8. 修改姓名并验证保存；检查通知页。
9. 结束时清理测试数据，保留干净的初始演示工作区供正常运行。

## 命令

```sh
flutter pub get
flutter analyze
flutter test

flutter emulators
flutter emulators --launch apple_ios_simulator
flutter devices

flutter drive --driver test_driver/integration_test.dart \
  --target integration_test/app_test.dart -d <ios-simulator-id>
```

集成测试是 iOS 模拟器专用截图流程：主机 Driver 在 `127.0.0.1:52837` 接收测试端截图请求，调用 `xcrun simctl io … screenshot` 输出完整图像。生产 App 不包含这段通信和截图代码。若同时启动多个 iOS 模拟器，请明确传入设备 ID：

```sh
IOS_SIMULATOR_UDID=<ios-simulator-id> flutter drive \
  --driver test_driver/integration_test.dart \
  --target integration_test/app_test.dart -d <ios-simulator-id>
```

截图前会收起键盘、关闭保存提示并等待页面渲染稳定。图片写入 `docs/screenshots/`，共 14 张；原稿另外保留在 `docs/design_reference/`。

## 平台范围

iOS 已完成实际构建及模拟器交互验证。Android 宿主工程已生成，尚未进行 Android 构建和设备测试；本机 `flutter doctor` 提示仍有 Android SDK 许可未接受。真机 iOS 签名需在 Xcode 里选择自己的开发团队。

最终版本另在模拟器中手动复核看板、新建、日程、进度、个人页及返回操作；清单控件可访问状态正常。
