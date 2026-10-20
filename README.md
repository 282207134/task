# Taskflow · Flutter

根据 Pixso `Design` 页的 5 个画板实现的任务管理 App，包含可操作的页面和本地持久化。保留参考中的英文文案、紫黄配色、灰色头像占位与演示日期。

## 启动

本次开发环境：Flutter 3.41.6 / Dart 3.11.4。

```sh
flutter pub get
flutter devices
flutter run -d <device-id>
```

支持 iOS / Android 项目结构。iOS 在模拟器中验证；Android 工程已生成，运行前需准备对应 SDK 并接受本机 SDK 许可。

## 功能

- Boards：搜索、All Boards / Teams / Personal 筛选、项目入口、侧边菜单。
- Create New Card：标题校验、描述编辑、起止日期、分类、成员选择、保存与更新。
- Task Detail：周日历选择、日程时间线、已创建任务入口。
- Progress：参与者选择、议程勾选、议程文本编辑。
- Profil：项目任务、Contacts / About you、资料设置和通知开关。
- Notifications：本地工作区活动列表。

这是可离线运行的本地演示 App。资料、任务、参与者和议程变更保存在设备；多人同步、真实聊天和系统推送尚未接入服务。

## 文档和截图

- [项目结构与架构](docs/ARCHITECTURE.md)
- [页面截图目录](docs/SCREENSHOTS.md)
- [测试说明](docs/TESTING.md)
- `docs/design_reference/`：Pixso 原稿导出，414 × 896。
- `docs/screenshots/`：iPhone 模拟器运行截图。

## 检查

```sh
flutter analyze
flutter test
flutter drive --driver test_driver/integration_test.dart \
  --target integration_test/app_test.dart -d <ios-simulator-id>
```

集成测试会清空 **当前模拟器中本 App 的演示数据**，覆盖完整交互流程并重新生成页面截图；请使用测试模拟器执行。
