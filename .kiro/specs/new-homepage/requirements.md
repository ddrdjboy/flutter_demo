# 需求文档：新首页（报告展示页）

## 简介

为 Flutter 电商 Demo 应用新增一个首页屏幕，用于解析 `data.json`（模拟后端 API 返回）并以完整的 UI 展示其内容。该页面主要展示一份包含 Markdown 富文本（标题、段落、列表、表格、图片、引用来源）的分析报告。原有的 `HomeScreen` 保持不变，新首页作为独立屏幕集成到应用导航中。

## 术语表

- **NewHomepage**：新建的首页屏幕组件，负责加载和展示报告内容
- **ReportParser**：JSON 数据解析服务，负责将 `data.json` 的嵌套结构转换为应用数据模型
- **ReportModel**：解析后的报告数据模型，包含标题、分享信息和内容段落列表
- **ContentSection**：报告中的单个内容段落，包含 contentType 和 markdown 文本
- **MarkdownRenderer**：Markdown 渲染组件，负责将 markdown 文本渲染为 Flutter Widget
- **ProductTable**：产品表格组件，负责展示包含图片、价格、销量等信息的产品数据
- **CitationTag**：引用来源标签，用于展示 `<cite>` 标签中的来源链接
- **AppShell**：底部导航栏容器，管理 Home、Chat、Cart、Profile 四个 tab

## 需求

### 需求 1：JSON 数据解析

**用户故事：** 作为开发者，我希望将 data.json 的嵌套 JSON 结构解析为类型安全的 Dart 数据模型，以便在 UI 层中方便地使用数据。

#### 验收标准

1. WHEN `data.json` 文件被加载时，THE ReportParser SHALL 从 `data.data.shareDTO.extra.title` 路径提取报告标题
2. WHEN `data.json` 文件被加载时，THE ReportParser SHALL 从 `data.data.msgHistoryRoundVersionDTO.rounds[0].messages[0].content[0].data` 路径提取内容段落数组
3. WHEN 内容段落数组被提取时，THE ReportParser SHALL 将每个 `contentType` 为 `summary` 的元素解析为 ContentSection 对象，包含其 `data.summary` 文本
4. IF JSON 结构不符合预期格式，THEN THE ReportParser SHALL 返回一个包含错误描述的解析失败结果
5. THE ReportModel SHALL 包含报告标题（String）、分享 URL（String）和内容段落列表（List<ContentSection>）
6. FOR ALL 有效的 ReportModel 对象，将其序列化为 JSON 再解析回 ReportModel SHALL 产生等价的对象（往返属性）

### 需求 2：Markdown 内容渲染

**用户故事：** 作为用户，我希望报告中的 Markdown 内容能以富文本格式展示，以便我能清晰地阅读标题、段落、列表和引用来源。

#### 验收标准

1. THE MarkdownRenderer SHALL 正确渲染 Markdown 标题（h1、h2、h3）为对应层级的文字样式
2. THE MarkdownRenderer SHALL 正确渲染 Markdown 段落文本、加粗文本和斜体文本
3. THE MarkdownRenderer SHALL 正确渲染 Markdown 无序列表和有序列表
4. WHEN Markdown 文本中包含 `<cite>[来源名称](URL)</cite>` 标签时，THE MarkdownRenderer SHALL 将其渲染为可识别的引用来源标签
5. THE MarkdownRenderer SHALL 使用 `Theme.of(context).textTheme` 中的样式，不硬编码文字颜色和大小

### 需求 3：产品表格展示

**用户故事：** 作为用户，我希望报告中的产品表格能以可视化的卡片或表格形式展示产品图片、价格和销量，以便我能直观地比较产品信息。

#### 验收标准

1. WHEN Markdown 内容包含产品表格（含 Product Title、Image、Price、Sales Volume、Source 列）时，THE ProductTable SHALL 将其解析并以可视化方式展示
2. THE ProductTable SHALL 展示每个产品的标题、图片、价格和销量信息
3. WHEN 产品数据包含图片 URL 时，THE ProductTable SHALL 加载并展示产品图片
4. IF 产品图片加载失败，THEN THE ProductTable SHALL 展示一个占位图标代替
5. THE ProductTable SHALL 使用 `Theme.of(context).colorScheme` 中的颜色，不硬编码颜色值

### 需求 4：新首页屏幕集成

**用户故事：** 作为用户，我希望新首页替换原有首页在导航中的位置，同时保留原有首页代码不被删除，以便我能看到新的报告展示页面。

#### 验收标准

1. THE NewHomepage SHALL 作为独立的屏幕文件创建在 `lib/screens/` 目录下
2. THE AppShell SHALL 将底部导航栏的 Home tab 指向 NewHomepage 而非原有的 HomeScreen
3. THE NewHomepage SHALL 保留原有 HomeScreen 的代码文件不做任何修改
4. WHEN NewHomepage 加载时，THE NewHomepage SHALL 从本地 asset 读取 `data.json` 并通过 ReportParser 解析数据
5. WHILE 数据正在加载时，THE NewHomepage SHALL 展示一个居中的加载指示器
6. IF 数据加载或解析失败，THEN THE NewHomepage SHALL 展示错误信息和重试按钮

### 需求 5：页面布局与滚动

**用户故事：** 作为用户，我希望报告内容能在一个可滚动的页面中完整展示，包括报告标题、所有 Markdown 段落和产品表格。

#### 验收标准

1. THE NewHomepage SHALL 在页面顶部展示报告标题，使用 `Theme.of(context).textTheme.headlineMedium` 样式
2. THE NewHomepage SHALL 按照 `data.json` 中内容段落的原始顺序依次渲染每个 ContentSection
3. THE NewHomepage SHALL 使用可滚动布局，允许用户上下滚动浏览全部报告内容
4. THE NewHomepage SHALL 在内容段落之间使用 16 像素的间距
5. THE NewHomepage SHALL 在页面两侧使用 16 像素的水平内边距
