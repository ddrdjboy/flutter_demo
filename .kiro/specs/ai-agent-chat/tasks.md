# 实施计划：AI Agent 聊天功能

## 概述

将搜索标签页替换为 AI 聊天页面，核心工作包括：添加依赖、实现 DeepSeekProvider、创建 ChatScreen、更新导航栏和常量、清理废弃代码。每个任务按增量方式构建，确保前后衔接，无孤立代码。

## 任务

- [x] 1. 添加依赖并更新常量
  - [x] 1.1 在 `pubspec.yaml` 中添加 `flutter_ai_toolkit` 和 `http` 依赖
    - 在 `dependencies` 下添加 `flutter_ai_toolkit` 和 `http`
    - 执行 `flutter pub get` 确保依赖解析成功
    - _需求: 1.1, 1.2_

  - [x] 1.2 将 `lib/utils/constants.dart` 中的 `searchTab` 重命名为 `chatTab`
    - 将 `const int searchTab = 1` 改为 `const int chatTab = 1`
    - 检查并同步更新所有引用 `searchTab` 的文件
    - _需求: 7.1, 7.2_

- [x] 2. 实现 DeepSeekProvider
  - [x] 2.1 创建 `lib/services/deepseek_provider.dart`，实现 `DeepSeekProvider` 类
    - 继承 `ChangeNotifier` 并实现 `LlmProvider` 接口
    - 构造函数接收可选 `apiKey`、`model`（默认 `deepseek-chat`）、`systemPrompt` 参数
    - 从 `String.fromEnvironment('DEEPSEEK_API_KEY')` 读取 API Key，若为空抛出 `AssertionError`
    - 实现 `history` getter/setter，setter 中调用 `notifyListeners()`
    - 实现 `_buildRequestBody` 方法，构建包含 `model`、`messages`、`stream: true` 的请求体
    - 实现 `_parseSseLine` 方法，解析 SSE `data:` 行，提取 `choices[0].delta.content`
    - 实现 `_requestStream` 方法，发送 HTTP POST 到 `https://api.deepseek.com/chat/completions`，请求头包含 `Authorization: Bearer <key>` 和 `Content-Type: application/json`，解析 SSE 流并 yield 内容片段，遇到 `data: [DONE]` 结束流，非 200 状态码通过流发送错误信息，捕获网络异常发送友好提示
    - 实现 `generateStream`：发送单条 prompt（不含历史），返回 `Stream<String>`
    - 实现 `sendMessageStream`：追加用户消息到历史，发送完整对话历史，返回流式响应，完成后追加 AI 响应到历史并 `notifyListeners()`
    - _需求: 2.1, 2.2, 2.3, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10_

  - [ ]* 2.2 编写 DeepSeekProvider 单元测试
    - 在 `test/services/deepseek_provider_test.dart` 中编写测试
    - 测试有效 API Key 创建成功
    - 测试空 API Key 抛出 AssertionError
    - 测试默认模型名称为 `deepseek-chat`
    - 测试 SSE 正常行解析、`data: [DONE]` 终止、空行跳过、异常 JSON 安全处理
    - 测试请求体包含 `stream: true` 和正确的请求头
    - _需求: 2.3, 3.2, 3.3, 3.4, 3.7, 3.8_

  - [ ]* 2.3 编写属性测试：空 API Key 抛出错误
    - **属性 1: 空 API Key 抛出错误**
    - 生成随机空白字符串（空串、空格、制表符等），验证全部抛出错误
    - **验证需求: 2.3**

  - [ ]* 2.4 编写属性测试：SSE 解析正确提取内容
    - **属性 4: SSE 解析正确提取内容**
    - 生成随机字符串内容，构造有效 SSE 行，验证解析结果与原始内容一致
    - **验证需求: 3.7**

  - [ ]* 2.5 编写属性测试：非 200 状态码产生错误信息
    - **属性 5: 非 200 状态码产生错误信息**
    - 生成随机非 200 状态码（100-599 范围，排除 200），验证流输出包含错误信息
    - **验证需求: 3.9**

- [ ] 3. 检查点 - 确保 Provider 实现和测试通过
  - 确保所有测试通过，如有疑问请询问用户。

- [ ] 4. 创建 ChatScreen 并更新导航
  - [x] 4.1 创建 `lib/screens/chat_screen.dart`
    - 创建 `ChatScreen` 为 `StatefulWidget`
    - 在 `initState` 中创建 `DeepSeekProvider` 实例
    - 使用 `Scaffold` 包含 `AppBar`（标题"AI 助手"）和 `LlmChatView(provider: _provider)` 作为 body
    - 在 `dispose` 中释放 Provider 资源
    - 使用 `Theme.of(context).colorScheme` 获取颜色，遵循现有主题
    - _需求: 4.1, 4.2, 4.3, 4.4, 4.5_

  - [x] 4.2 更新 `lib/screens/app_shell.dart`
    - 移除 `import 'search_screen.dart'`，添加 `import 'chat_screen.dart'`
    - 将 `_screens` 列表中的 `SearchScreen()` 替换为 `ChatScreen()`
    - 将底部导航第二项图标改为 `Icons.chat_bubble_outline`（未选中）和 `Icons.chat_bubble`（选中），标签改为 `'Chat'`
    - _需求: 5.1, 5.2, 5.3, 6.2, 6.3_

  - [x] 4.3 删除 `lib/screens/search_screen.dart`
    - 移除废弃的搜索页面文件
    - _需求: 6.1_

  - [ ]* 4.4 编写 ChatScreen Widget 测试
    - 在 `test/screens/chat_screen_test.dart` 中编写测试
    - 验证 AppBar 标题为"AI 助手"
    - 验证包含 LlmChatView 组件
    - _需求: 4.2, 4.4_

  - [ ]* 4.5 编写导航集成测试
    - 验证底部导航第二项标签为"Chat"
    - 验证图标为 `chat_bubble_outline` / `chat_bubble`
    - _需求: 5.1, 5.2_

- [ ] 5. 检查点 - 确保所有测试通过
  - 确保所有测试通过，如有疑问请询问用户。

- [ ] 6. 属性测试补充
  - [ ]* 6.1 编写属性测试：sendMessageStream 对话历史累积
    - **属性 2: sendMessageStream 对话历史累积**
    - 生成随机消息序列，模拟 API 响应，验证每次调用后历史长度增加 2
    - **验证需求: 3.5**

  - [ ]* 6.2 编写属性测试：generateStream 不影响对话历史
    - **属性 3: generateStream 不影响对话历史**
    - 生成随机 prompt 和随机初始历史状态，验证调用后历史不变
    - **验证需求: 3.6**

  - [ ]* 6.3 编写属性测试：对话历史变更触发通知
    - **属性 6: 对话历史变更触发通知**
    - 生成随机消息序列，注册监听者，验证每次历史变更都触发通知回调
    - **验证需求: 3.10**

- [ ] 7. 最终检查点 - 确保所有测试通过
  - 确保所有测试通过，如有疑问请询问用户。

## 备注

- 标记 `*` 的任务为可选，可跳过以加快 MVP 进度
- 每个任务引用了具体需求编号，确保可追溯性
- 属性测试验证普遍正确性，单元测试验证具体场景和边界情况
- 属性测试每个至少运行 100 次迭代
