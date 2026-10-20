# 项目结构与架构

## 1. 设计来源与实现范围

读取 Pixso 当前文件的 `Design` 页（`0:1`），实现以下画板：

| 画板 | 节点 | Flutter 页面 | 主要行为 |
| --- | --- | --- | --- |
| 01 | `0:2` | BoardsPage | 看板搜索、归属筛选、项目和菜单入口 |
| 02 | `0:93` | CardEditorPage | 创建 / 编辑卡片，日期、分类与成员选择 |
| 03 | `0:166` | SchedulePage | 周视图切换、日程时间线 |
| 04 | `0:274` | ProgressPage | 参与者、议程勾选和编辑 |
| 05 | `0:350` | ProfilePage | 项目任务、联系人、个人信息、设置 |

保留原稿的紫色 `#4404AC`、黄色 `#DDB90E`、粉红与红色项目卡片、圆角、原始矢量图标，以及灰色头像占位。原稿中的 `Profil`、`complated` 和示例日期也保持原样。新增行为使用 Flutter 原生对话框与底部面板，系统安全区域随设备适配，长内容可以滚动。

## 2. 目录

```text
task/
├── lib/
│   ├── main.dart                       # Flutter 初始化、系统栏、持久化加载
│   ├── app.dart                        # MaterialApp 和首页
│   ├── core/
│   │   └── theme.dart                  # 设计色板、文字样式、ThemeData
│   ├── data/
│   │   ├── models.dart                 # Project / TaskCard、演示数据、日期格式
│   │   └── app_store.dart              # ChangeNotifier 状态、本地 JSON 存储
│   ├── features/
│   │   ├── boards/boards_page.dart      # 看板与侧边菜单
│   │   ├── editor/card_editor_page.dart # 创建与编辑共用表单
│   │   ├── schedule/
│   │   │   ├── schedule_page.dart      # 日程
│   │   │   └── progress_page.dart      # 进度与议程
│   │   └── profile/profile_page.dart   # 个人页、联系人、设置
│   └── shared/
│       └── widgets.dart                # 顶栏、按钮、头像、成员选择、底栏、通知页
├── assets/images/                      # 使用到的 Pixso SVG
├── test/
│   ├── app_store_test.dart             # 数据恢复、顺序写入、异常数据回退
│   └── widget_test.dart                # 搜索筛选、多尺寸布局
├── integration_test/app_test.dart      # 模拟器完整交互与截图
├── test_driver/integration_test.dart   # 原生 simctl 截图，写入 docs/screenshots
├── docs/
│   ├── ARCHITECTURE.md
│   ├── SCREENSHOTS.md
│   ├── TESTING.md
│   ├── design_reference/               # 5 张 Pixso 原稿
│   └── screenshots/                    # App 实际运行截图
├── android/                            # Android 原生宿主
├── ios/                                # iOS 原生宿主
├── pubspec.yaml
└── pubspec.lock                         # 可复现依赖版本
```

## 3. 架构与数据流

采用按功能组织的轻量分层结构。页面通过构造函数共享一个 `AppStore`；无需为五个页面引入额外状态管理框架、依赖注入容器或代码生成。

```text
Widget 页面
    │ 用户操作：保存、选择成员、勾选议程
    ▼
AppStore（ChangeNotifier）
    ├── 更新内存模型并通知 ListenableBuilder
    └── 顺序写入 JSON 快照
            ▼
      SharedPreferences
            │ AppStore.load()
            ▼
      下次启动恢复工作区
```

- **视图层**：`features/` 负责布局、导航和表单交互。搜索文本、当前标签、表单输入等临时状态放在页面 `State` 中，输入控制器在销毁时释放。
- **状态层**：`AppStore` 集中管理用户卡片、议程、勾选状态、参与者、姓名、职位与通知偏好。集合通过只读视图暴露。
- **模型层**：`TaskCard` 封装数据和 JSON 转换。四张示例项目卡片与初始日程为本地演示数据。
- **存储层**：使用版本化键 `taskflow.state.v1` 保存 JSON。保存队列串行执行，避免连续点击导致旧状态覆盖新状态。写入失败会显示错误，读取损坏数据时回退到默认演示数据。

当前数据量很小，状态与持久化封装在同一个文件中。后续接入 API 时，可以在 `AppStore` 后增加 Repository，保留页面调用接口；若引入大量任务、离线同步或附件，再迁移至数据库。

## 4. 页面与导航

```text
Boards
├── + → Create New Card → 保存 → Boards
├── 自建任务 → Edit Card → 更新 → Boards
├── 日历 / To Do / Done → Task Detail
│   └── 时间线卡片 → Progress
├── In Progress / 项目卡片 → Progress
└── 菜单 → Task Detail / Progress / Profile / Notifications

Task Detail / Progress 底栏 → 日程 / 通知 / 个人资料
Profile → Project Tasks / Contacts / About you
Profile 设置 → 姓名、职位、通知偏好
```

使用 Flutter `Navigator` 与 `MaterialPageRoute`，系统返回行为和页面返回按钮都可用。创建和编辑复用同一个页面，编辑按任务 ID 更新，不会生成重复记录。

## 5. 核心行为

- **搜索筛选**：项目标题、自建任务标题和分类匹配搜索文字，支持无结果状态。Teams 显示团队示例项目；Personal 显示个人示例项目与自建任务。
- **表单**：空标题无法提交；日期选择器限制结束日期不早于开始日期，开始时间后移时自动同步结束时间；成员可选择和取消。
- **进度**：清单支持多项勾选、划线、编辑，编辑时保留未改名条目的完成状态。
- **资料**：设置可编辑姓名和职位；通知开关控制本地通知列表展示。
- **持久化**：自建卡片及修改内容、议程和完成状态、参与者、个人信息与通知偏好均在重新加载后恢复。

## 6. 代码精简

Pixso 自动导出用于读取尺寸、颜色和素材。最终工程移除了导出的数字命名组件、逐层绝对定位包装、变量管理模板和屏幕缩放工具，改为可读的业务页面与 Flutter 布局。

重复的颜色与文字样式集中到 `theme.dart`；顶栏、按钮、SVG 图标、头像、成员选择、底栏集中到 `shared/widgets.dart`。创建 / 编辑共用一套表单。只保留实际用到的 SVG，删除未用素材、默认计数器示例和无用依赖；未引入网络、路由、状态管理或代码生成包。

## 7. 当前边界

- 提供本地可操作演示，未接入账号、后端、多人同步、真实聊天、系统推送与附件上传。
- Profile 的 Message 入口展示清楚的未接入状态；通知列表是本地工作区活动，不会向其他人发送消息。
- 四张项目卡片的百分比、初始任务统计、时间线与个人页的示例项目为原稿数据；新增卡片与清单数据可修改并保存。
- 原稿灰色头像本身就是占位图，本次保留；未替换为虚构人物照片。
- 本次在 iOS 模拟器实测，Android 工程保留，尚未进行 Android 真机或模拟器验证。
