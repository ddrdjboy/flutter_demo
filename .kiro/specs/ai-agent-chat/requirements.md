# 需求文档

## 简介

将现有 Flutter 电商应用中的搜索页面（Search Tab）替换为 AI Agent 聊天页面。集成 `flutter_ai_toolkit` 包提供聊天 UI，通过自定义 `DeepSeekProvider` 实现 `LlmProvider` 接口，调用 DeepSeek API（OpenAI 兼容格式）的 chat completions 端点，提供智能对话功能。用户可以在该页面与 AI 助手进行多轮对话，获取商品推荐、购物建议等服务。

## 术语表

- **App_Shell**: 应用主框架，包含底部导航栏和 `IndexedStack` 页面切换逻辑，定义在 `app_shell.dart`
- **Chat_Screen**: 替换原搜索页面的 AI 聊天页面，承载 `LlmChatView` 组件
- **LlmChatView**: `flutter_ai_toolkit` 包提供的聊天界面组件，支持多轮对话、流式响应、富文本显示
- **LlmProvider**: `flutter_ai_toolkit` 包中定义的抽象接口，要求实现 `generateStream`、`sendMessageStream`、`history` get/set，并继承 `Listenable`
- **DeepSeekProvider**: 自定义实现的 `LlmProvider`，通过 HTTP 请求调用 DeepSeek API 的 chat completions 端点，支持流式响应（SSE）
- **DeepSeek_API**: DeepSeek 提供的 OpenAI 兼容 API 服务，端点为 `https://api.deepseek.com/chat/completions`，使用 Bearer Token 认证
- **Bottom_Navigation**: 应用底部导航栏，包含 Home、Search（将改为 Chat）、Cart、Profile 四个标签

## 需求

### 需求 1：添加依赖包

**用户故事：** 作为开发者，我希望项目正确引入 `flutter_ai_toolkit` 和 `http` 依赖，以便使用 AI 聊天 UI 和调用 DeepSeek API。

#### 验收标准

1. THE pubspec.yaml SHALL 包含 `flutter_ai_toolkit` 和 `http` 依赖声明
2. WHEN 执行 `flutter pub get` 时，THE 依赖管理器 SHALL 成功解析并下载所有依赖包

### 需求 2：DeepSeek API Key 配置

**用户故事：** 作为开发者，我希望 DeepSeek API Key 通过安全的方式配置，以便应用能够认证 API 请求且密钥不会泄露到代码仓库中。

#### 验收标准

1. THE 应用 SHALL 通过 `--dart-define=DEEPSEEK_API_KEY=xxx` 编译参数或环境变量方式传入 API Key
2. THE DeepSeekProvider SHALL 从 `String.fromEnvironment('DEEPSEEK_API_KEY')` 读取 API Key
3. IF API Key 为空，THEN THE DeepSeekProvider SHALL 抛出明确的配置错误提示信息

### 需求 3：实现 DeepSeekProvider

**用户故事：** 作为开发者，我希望有一个自定义的 `DeepSeekProvider` 实现 `LlmProvider` 接口，以便通过 DeepSeek API 提供 AI 对话能力。

#### 验收标准

1. THE DeepSeekProvider SHALL 实现 `LlmProvider` 接口，包括 `generateStream`、`sendMessageStream`、`history` getter 和 setter
2. THE DeepSeekProvider SHALL 向 `https://api.deepseek.com/chat/completions` 端点发送 POST 请求，请求头包含 `Authorization: Bearer <API_KEY>` 和 `Content-Type: application/json`
3. THE DeepSeekProvider SHALL 在请求体中设置 `stream: true` 以启用流式响应（SSE）
4. THE DeepSeekProvider SHALL 使用 `deepseek-chat` 作为默认模型名称
5. WHEN `sendMessageStream` 被调用时，THE DeepSeekProvider SHALL 将用户消息追加到对话历史，发送完整对话历史给 API，并以 `Stream<String>` 形式逐步返回 AI 响应内容
6. WHEN `generateStream` 被调用时，THE DeepSeekProvider SHALL 发送单条 prompt 给 API（不包含对话历史），并以 `Stream<String>` 形式返回响应
7. THE DeepSeekProvider SHALL 正确解析 SSE 格式的响应数据，提取每个 `data:` 行中的 `choices[0].delta.content` 字段
8. WHEN SSE 响应包含 `data: [DONE]` 时，THE DeepSeekProvider SHALL 结束当前流
9. IF API 请求返回非 200 状态码，THEN THE DeepSeekProvider SHALL 通过流发送错误信息通知调用方
10. THE DeepSeekProvider SHALL 实现 `Listenable` 接口（通过 `ChangeNotifier` mixin），在对话历史变更时通知监听者

### 需求 4：创建 AI 聊天页面

**用户故事：** 作为用户，我希望在原搜索标签页看到一个 AI 聊天界面，以便与 AI 助手进行对话。

#### 验收标准

1. THE Chat_Screen SHALL 替换原有的 SearchScreen，作为底部导航第二个标签页的内容
2. THE Chat_Screen SHALL 使用 `LlmChatView` 组件作为主要聊天界面
3. THE Chat_Screen SHALL 创建 `DeepSeekProvider` 实例并传递给 `LlmChatView` 的 `provider` 参数
4. THE Chat_Screen SHALL 包含一个 AppBar，标题显示为"AI 助手"
5. THE Chat_Screen SHALL 遵循应用现有的 Material Design 主题，使用 `Theme.of(context).colorScheme` 获取颜色

### 需求 5：更新底部导航栏

**用户故事：** 作为用户，我希望底部导航栏的标签和图标反映页面功能的变化，以便清楚地知道该标签页是 AI 聊天功能。

#### 验收标准

1. THE Bottom_Navigation SHALL 将第二个标签的标签文字从"Search"更改为"Chat"
2. THE Bottom_Navigation SHALL 将第二个标签的图标从 `Icons.search` 更改为 `Icons.chat_bubble_outline`（未选中）和 `Icons.chat_bubble`（选中）
3. THE App_Shell SHALL 将 `_screens` 列表中的 `SearchScreen()` 替换为 `ChatScreen()`

### 需求 6：清理废弃代码

**用户故事：** 作为开发者，我希望移除不再使用的搜索相关代码，以保持代码库整洁。

#### 验收标准

1. THE 项目 SHALL 删除 `lib/screens/search_screen.dart` 文件
2. THE App_Shell SHALL 移除对 `SearchScreen` 的导入语句
3. THE App_Shell SHALL 添加对 `ChatScreen` 的导入语句

### 需求 7：常量更新

**用户故事：** 作为开发者，我希望标签页常量名称反映实际功能，以便代码可读性更好。

#### 验收标准

1. THE constants.dart SHALL 将 `searchTab` 常量重命名为 `chatTab`，值保持为 `1`
2. WHEN 其他文件引用了 `searchTab` 常量时，THE 引用处 SHALL 同步更新为 `chatTab`
