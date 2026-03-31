# 实现计划：电商 App 架构

## 概述

基于设计文档，按分层架构自底向上实现：先建立数据模型和服务层，再构建通用 Widget，然后实现各页面，最后重构 main.dart 完成整体集成。测试任务作为子任务穿插在实现步骤中，确保尽早验证核心逻辑。

## 任务

- [x] 1. 建立常量定义和数据模型层
  - [x] 1.1 创建 `lib/utils/constants.dart`，定义 Tab 索引常量（homeTab=0, searchTab=1, cartTab=2, profileTab=3）和其他全局常量
    - _需求: 1.1, 1.5_
  - [x] 1.2 创建 `lib/models/cart_item.dart`，实现 CartItem 模型
    - 持有 Product 引用和 quantity 字段
    - 实现 subtotal getter（解析 currentPrice 字符串为 double，PriceType.seeInCart 返回 0.0）
    - 重写 == 和 hashCode（基于 product.title）
    - _需求: 5.1, 5.2_
  - [x] 1.3 创建 `lib/models/user_profile.dart`，实现 UserProfile 模型
    - 包含 nickname、avatarUrl、memberLevel 字段，const 构造函数
    - _需求: 6.1_

- [x] 2. 实现服务层
  - [x] 2.1 创建 `lib/services/cart_service.dart`，实现 CartService
    - 继承 ChangeNotifier，实现全局单例模式
    - 实现 items、totalCount、totalPrice、isEmpty getter
    - 实现 addItem（已存在则数量+1）、updateQuantity（<=0 时移除）、removeItem、clear 方法
    - 每次操作后调用 notifyListeners()
    - _需求: 5.1, 5.2, 5.3, 5.4, 7.2_
  - [ ]* 2.2 编写属性测试：购物车总价与总数量不变量
    - **Property 7: 购物车总价与总数量不变量**
    - **验证: 需求 5.2, 5.4**
  - [ ]* 2.3 编写属性测试：数量归零等价于移除
    - **Property 8: 数量归零等价于移除**
    - **验证: 需求 5.3**
  - [ ]* 2.4 编写属性测试：CartService 单例一致性
    - **Property 9: CartService 单例一致性**
    - **验证: 需求 7.2**
  - [ ]* 2.5 编写属性测试：购物车添加商品幂等合并
    - **Property 10: 购物车添加商品幂等合并**
    - **验证: 需求 5.1**
  - [x] 2.6 创建 `lib/services/product_repository.dart`，实现 ProductRepository
    - 实现 getRecommendedProducts、searchProducts、getProductDetail、getRecentlyViewed 方法
    - 当前阶段使用本地 mock 数据（将 main.dart 中的 _sampleProducts 迁移至此）
    - _需求: 3.5, 7.3_
  - [x] 2.7 创建 `lib/services/search_service.dart`，实现 SearchService
    - 实现 getSuggestions、getHistory、addToHistory、clearHistory 方法
    - 搜索逻辑：在 brand 和 title 中不区分大小写匹配关键词
    - _需求: 4.2, 4.3, 4.4, 4.5_
  - [ ]* 2.8 编写属性测试：搜索结果与关键词匹配
    - **Property 6: 搜索结果与关键词匹配**
    - **验证: 需求 4.3**

- [ ] 3. 检查点 - 确保数据模型和服务层测试通过
  - 确保所有测试通过，如有问题请询问用户。

- [x] 4. 实现通用 Widget 组件
  - [x] 4.1 创建 `lib/widgets/empty_state.dart`，实现 EmptyState 通用空状态组件
    - 接受 icon、title、subtitle、actionLabel、onAction 参数
    - 使用 Theme.of(context) 获取颜色和文字样式
    - _需求: 4.6, 5.5_
  - [x] 4.2 创建 `lib/widgets/cart_badge.dart`，实现 CartBadge 角标组件
    - 通过 ListenableBuilder 监听 CartService，展示商品总数
    - 购物车为空时不展示角标
    - _需求: 1.6_
  - [ ]* 4.3 编写属性测试：购物车角标数量与购物车状态一致
    - **Property 2: 购物车角标数量与购物车状态一致**
    - **验证: 需求 1.6**
  - [x] 4.4 创建 `lib/widgets/cart_item_tile.dart`，实现购物车商品行组件
    - 展示商品图片、名称、单价、数量调整按钮和小计
    - 通过回调通知数量变化和删除操作
    - _需求: 5.1, 5.2, 5.3_
  - [x] 4.5 创建 `lib/widgets/search_history_chip.dart`，实现搜索历史标签组件
    - _需求: 4.4, 4.5_
  - [x] 4.6 创建 `lib/widgets/promo_banner.dart`，实现促销横幅组件
    - _需求: 3.1_
  - [x] 4.7 创建 `lib/widgets/category_nav.dart`，实现分类导航组件
    - _需求: 3.1_
  - [x] 4.8 创建 `lib/widgets/tab_navigator.dart`，实现 TabNavigator
    - 接受 navigatorKey 和 child 参数
    - 为每个 Tab 提供独立的 Navigator 导航栈
    - _需求: 2.1, 2.2_

- [x] 5. 实现页面层
  - [x] 5.1 创建 `lib/screens/home_screen.dart`，实现 HomeScreen
    - 可垂直滚动布局：PromoBanner + CategoryNav + ProductCardList（复用现有组件）
    - 通过 ProductRepository 获取数据
    - 支持 RefreshIndicator 下拉刷新
    - 集成 RecentlyViewedSheet
    - 商品卡片点击跳转商品详情（Tab 内导航）
    - _需求: 3.1, 3.2, 3.3, 3.4, 3.5, 8.2, 8.3_
  - [x] 5.2 创建 `lib/screens/search_screen.dart`，实现 SearchScreen
    - 顶部搜索框 + 搜索历史 + 搜索建议 + 搜索结果（复用 ProductCardList）
    - 通过 SearchService 管理搜索逻辑
    - 空结果展示 EmptyState 组件
    - _需求: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7_
  - [x] 5.3 创建 `lib/screens/cart_screen.dart`，实现 CartScreen
    - 通过 ListenableBuilder 监听 CartService
    - 商品列表（CartItemTile）+ 底部价格汇总区域（商品总数 + 总价）
    - 空购物车展示 EmptyState + 引导按钮
    - _需求: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_
  - [x] 5.4 创建 `lib/screens/profile_screen.dart`，实现 ProfileScreen
    - 顶部用户信息区（头像、昵称、会员等级）
    - 功能入口列表（我的订单、收货地址、优惠券、设置）
    - 未登录时展示登录引导界面
    - 点击功能入口在 Tab 内导航跳转
    - _需求: 6.1, 6.2, 6.3, 6.4_
  - [ ]* 5.5 编写单元测试：各页面 UI 结构验证
    - 测试 AppShell 初始状态（默认选中首页 Tab）— 验收标准 1.4
    - 测试 BottomNavigationBar 包含 4 个 Tab 项 — 验收标准 1.1, 1.5
    - 测试 IndexedStack 结构 — 验收标准 1.3
    - 测试搜索空结果展示空状态 — 验收标准 4.6
    - 测试购物车空状态展示引导页面 — 验收标准 5.5
    - 测试 ProfileScreen 登录/未登录状态切换 — 验收标准 6.4
    - 测试 HomeScreen 集成 RecentlyViewedSheet — 验收标准 8.3
    - _需求: 1.1, 1.3, 1.4, 1.5, 3.1, 4.1, 4.6, 5.5, 6.1, 6.2, 6.4, 8.3_

- [x] 6. 检查点 - 确保页面和 Widget 测试通过
  - 所有文件零诊断错误。

- [x] 7. 实现 AppShell 与导航集成
  - [x] 7.1 创建 `lib/screens/app_shell.dart`，实现 AppShell
    - Scaffold + BottomNavigationBar（4 个 Tab：首页、搜索、购物车、我的）
    - 使用 IndexedStack + TabNavigator 保持各 Tab 状态
    - 购物车 Tab 图标集成 CartBadge 角标
    - 实现 _onTabTapped：切换 Tab，重复点击当前 Tab 时 pop 到根页面
    - 实现 _onWillPop：返回按钮优先 pop 当前 Tab 栈，根页面时切换到首页或退出
    - _需求: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 2.1, 2.2, 2.3, 2.4_
  - [ ]* 7.2 编写属性测试：Tab 切换正确更新当前索引
    - **Property 1: Tab 切换正确更新当前索引**
    - **验证: 需求 1.2**
  - [ ]* 7.3 编写属性测试：Tab 导航栈隔离性
    - **Property 3: Tab 导航栈隔离性**
    - **验证: 需求 2.2**
  - [ ]* 7.4 编写属性测试：返回按钮优先 Pop 当前 Tab 栈
    - **Property 4: 返回按钮优先 Pop 当前 Tab 栈**
    - **验证: 需求 2.3**
  - [ ]* 7.5 编写属性测试：重复点击当前 Tab 回到根页面
    - **Property 5: 重复点击当前 Tab 回到根页面**
    - **验证: 需求 2.4**

- [x] 8. 重构 main.dart 并完成集成
  - [x] 8.1 重构 `lib/main.dart`
    - 保留 NewRelic 监控集成（runZonedGuarded + FlutterError.onError）
    - 清理冗余代码（移除 MyHomePage、_sampleProducts 等 demo 代码）
    - 将 MaterialApp 的 home 改为 AppShell
    - 保持现有主题配置 ColorScheme.fromSeed(seedColor: Colors.deepPurple)
    - _需求: 7.1, 7.4, 7.5, 8.1, 8.4_
  - [ ] 8.2 在 `pubspec.yaml` 中添加 `glados` 测试依赖
    - 在 dev_dependencies 中添加 glados 包
    - _需求: 测试策略_

- [ ] 9. 最终检查点 - 确保所有测试通过，完成集成验证
  - 确保所有测试通过，如有问题请询问用户。

## 备注

- 标记 `*` 的子任务为可选测试任务，可跳过以加速 MVP 开发
- 每个任务引用了具体的需求编号，确保可追溯性
- 属性测试使用 glados 包，每个属性至少运行 100 次迭代
- 属性测试注释格式：`// Feature: ecommerce-app-architecture, Property N: 属性名称`
- 检查点任务确保增量验证，避免问题累积
- 现有组件（ProductCardList、ProductFlag、RecentlyViewedSheet）保持不变，直接复用
