# 实现计划：新首页（报告展示页）

## 概述

基于需求文档和设计文档，将实现分为：项目配置 → 数据模型 → 解析服务 → UI 组件 → 页面集成。每一步都在前一步基础上递增构建，确保无孤立代码。

## 任务

- [ ] 1. 项目配置与基础数据模型
  - [x] 1.1 更新 pubspec.yaml
    - 添加 `flutter_markdown: ^0.7.6` 和 `url_launcher: ^6.3.1` 依赖
    - 在 `flutter.assets` 中注册 `lib/models/data.json`
    - _需求: 2.1, 2.4, 4.4_

  - [x] 1.2 创建 Result sealed class
    - 在 `lib/models/result.dart` 中实现 `Result<T>`、`Success<T>`、`Failure<T>`
    - _需求: 1.4_

  - [x] 1.3 创建 ContentSection 数据模型
    - 在 `lib/models/report_model.dart` 中实现 `ContentSection`，包含 `contentType`、`summary` 字段
    - 实现 `toJson()` 和 `fromJson()` 方法
    - _需求: 1.3, 1.5_

  - [x] 1.4 创建 ReportModel 数据模型
    - 在 `lib/models/report_model.dart` 中实现 `ReportModel`，包含 `title`、`shareUrl`、`sections` 字段
    - 实现 `toJson()` 和 `fromJson()` 方法
    - _需求: 1.5, 1.6_

  - [ ]* 1.5 编写 ReportModel 序列化往返属性测试
    - **属性 3：ReportModel 序列化往返**
    - 生成随机 ReportModel → toJson → fromJson → 验证等价
    - 在 `test/models/report_model_test.dart` 中实现，循环 100 次
    - **验证需求: 1.6**

  - [x] 1.6 创建 ProductTableItem 数据模型
    - 在 `lib/models/product_table_item.dart` 中实现，包含 `title`、`titleUrl`、`imageUrl`、`price`、`salesVolume`、`source` 字段
    - 实现 `toJson()` 和 `fromJson()` 方法
    - _需求: 3.1, 3.2_


- [x] 2. 实现 JSON 解析服务
  - [x] 2.1 实现 ReportParser
    - 在 `lib/services/report_parser.dart` 中实现 `parseReport(String jsonString)` 和 `parseReportFromMap(Map<String, dynamic> json)`
    - 从 `data.data.shareDTO.extra.title` 提取标题
    - 从 `data.data.shareDTO.shareUrl` 提取分享 URL
    - 从 `data.data.msgHistoryRoundVersionDTO.rounds[0].messages[0].content[0].data` 提取内容段落数组
    - 过滤 `contentType` 为 `"summary"` 的元素，解析为 ContentSection
    - 对无效 JSON 结构返回 `Failure` 结果，包含具体错误描述
    - _需求: 1.1, 1.2, 1.3, 1.4_

  - [ ]* 2.2 编写 JSON 解析正确性属性测试
    - **属性 1：JSON 解析正确性**
    - 生成随机有效 JSON 结构 → 解析 → 验证标题一致、段落数量和顺序一致
    - 在 `test/services/report_parser_test.dart` 中实现，循环 100 次
    - **验证需求: 1.1, 1.2, 1.3, 5.2**

  - [ ]* 2.3 编写无效 JSON 返回失败结果属性测试
    - **属性 2：无效 JSON 返回失败结果**
    - 生成随机无效 JSON（缺少键路径、类型错误、非法 JSON）→ 解析 → 验证返回 Failure 且错误描述非空
    - 在 `test/services/report_parser_test.dart` 中实现，循环 100 次
    - **验证需求: 1.4**

  - [x] 2.4 实现 ContentSectionParser
    - 在 `lib/services/content_section_parser.dart` 中实现
    - 实现 `parse(String markdown)` 方法，将 Markdown 文本拆分为 `MarkdownSegment` 和 `ProductTableSegment`
    - 实现 `parseProductTable(String tableMarkdown)` 方法，解析 Markdown 表格为 `ProductTableItem` 列表
    - 在 `lib/models/product_table_item.dart` 或 `content_section_parser.dart` 中定义 `RenderSegment` sealed class
    - _需求: 3.1_

  - [ ]* 2.5 编写产品表格解析属性测试
    - **属性 5：产品表格解析**
    - 生成随机产品数据 → 格式化为 Markdown 表格 → 解析 → 验证列表长度和字段一致
    - 在 `test/services/content_section_parser_test.dart` 中实现，循环 100 次
    - **验证需求: 3.1**

- [ ] 3. 检查点 - 确保数据层测试通过
  - 确保所有测试通过，如有问题请询问用户。

- [x] 4. 实现 UI 组件
  - [x] 4.1 实现 CitationTag Widget
    - 在 `lib/widgets/citation_tag.dart` 中实现
    - 展示来源名称，点击后通过 `url_launcher` 打开链接
    - 使用 `Theme.of(context).colorScheme` 中的颜色
    - _需求: 2.4_

  - [ ]* 4.2 编写 Cite 标签提取属性测试
    - **属性 4：Cite 标签提取**
    - 生成随机 Markdown 文本 + `<cite>` 标签 → 提取 → 验证数量和内容一致
    - 在 `test/widgets/citation_tag_test.dart` 中实现，循环 100 次
    - **验证需求: 2.4**

  - [x] 4.3 实现 ProductTable Widget
    - 在 `lib/widgets/product_table.dart` 中实现
    - 以卡片形式展示产品图片、标题、价格、销量
    - 图片加载失败时展示 `Icons.image_not_supported` 占位图标
    - 使用 `Theme.of(context).colorScheme` 中的颜色，不硬编码
    - _需求: 3.1, 3.2, 3.3, 3.4, 3.5_

  - [ ]* 4.4 编写 ProductTable Widget 测试
    - 验证产品信息正确展示
    - 验证图片加载失败时显示占位图标
    - 在 `test/widgets/product_table_test.dart` 中实现
    - _需求: 3.2, 3.4_

  - [x] 4.5 实现 MarkdownContentRenderer Widget
    - 在 `lib/widgets/markdown_content_renderer.dart` 中实现
    - 预处理 `<cite>` 标签，转换为 CitationTag Widget
    - 检测 Markdown 中的产品表格，拦截并交给 ProductTable 渲染
    - 使用 `flutter_markdown` 渲染剩余 Markdown 内容
    - 使用 `Theme.of(context).textTheme` 中的样式，不硬编码
    - _需求: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [ ]* 4.6 编写 MarkdownContentRenderer Widget 测试
    - 验证基本 Markdown 元素（标题、段落、列表）渲染
    - 在 `test/widgets/markdown_content_renderer_test.dart` 中实现
    - _需求: 2.1, 2.2, 2.3_

- [ ] 5. 检查点 - 确保 UI 组件测试通过
  - 确保所有测试通过，如有问题请询问用户。

- [x] 6. 页面集成与导航接入
  - [x] 6.1 实现 NewHomepage 屏幕
    - 在 `lib/screens/new_homepage.dart` 中实现
    - 使用 `rootBundle.loadString()` 从本地 asset 读取 `data.json`
    - 通过 ReportParser 解析数据
    - 管理加载中、成功、失败三种状态
    - 加载中展示居中的 `CircularProgressIndicator`
    - 失败时展示错误信息和重试按钮
    - 成功时在页面顶部展示报告标题（`headlineMedium` 样式）
    - 按原始顺序渲染每个 ContentSection，使用 MarkdownContentRenderer
    - 使用可滚动布局（`SingleChildScrollView` 或 `ListView`）
    - 内容段落间距 16 像素，水平内边距 16 像素
    - _需求: 4.1, 4.4, 4.5, 4.6, 5.1, 5.2, 5.3, 5.4, 5.5_

  - [ ]* 6.2 编写 NewHomepage Widget 测试
    - 验证加载状态显示 CircularProgressIndicator
    - 验证错误状态显示错误信息和重试按钮
    - 验证成功状态显示报告标题
    - 在 `test/screens/new_homepage_test.dart` 中实现
    - _需求: 4.5, 4.6, 5.1_

  - [x] 6.3 修改 AppShell 导航接入
    - 修改 `lib/screens/app_shell.dart`，将 Home tab 从 `HomeScreen` 改为 `NewHomepage`
    - 保留 `home_screen.dart` 文件不做任何修改
    - _需求: 4.2, 4.3_

- [ ] 7. 最终检查点 - 确保所有测试通过
  - 确保所有测试通过，如有问题请询问用户。

## 备注

- 标记 `*` 的任务为可选任务，可跳过以加快 MVP 进度
- 每个任务引用了具体的需求编号，确保可追溯性
- 检查点确保增量验证
- 属性测试验证通用正确性属性，单元测试验证具体示例和边界情况
