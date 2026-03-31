# 需求文档

## 简介

为现有 Flutter 电商项目设计一个基于底部导航栏（BottomNavigationBar）的 4-Tab 架构，包含首页、搜索页、购物车和我的页面。该架构需要在保留现有组件（Product 模型、ProductCardList、ProductFlag、RecentlyViewedSheet）的基础上，建立清晰的分层结构、状态管理方案和导航体系，为后续业务功能迭代提供坚实的架构基础。

## 术语表

- **App_Shell**: 应用的顶层容器 Widget，承载 BottomNavigationBar 和 Tab 页面切换逻辑
- **Tab_Navigator**: 每个 Tab 内部独立的导航栈，支持 Tab 内页面跳转而不影响底部导航栏状态
- **Home_Screen**: 首页 Tab，展示推荐商品、促销活动、分类入口等电商核心内容
- **Search_Screen**: 搜索页 Tab，提供商品搜索、搜索历史、搜索建议等功能
- **Cart_Screen**: 购物车 Tab，展示已添加商品、数量调整、价格汇总等购物车功能
- **Profile_Screen**: 我的页面 Tab，展示用户信息、订单入口、设置等个人中心功能
- **Cart_Service**: 购物车业务逻辑服务层，管理购物车状态和操作
- **Product_Repository**: 商品数据仓库层，负责商品数据的获取和缓存
- **Theme_System**: 基于 Material Design 的 ThemeData 主题系统，通过 ColorScheme.fromSeed 和 TextTheme 提供设计 token

## 需求

### 需求 1：App Shell 与底部导航

**用户故事：** 作为用户，我希望通过底部导航栏在首页、搜索、购物车和我的页面之间快速切换，以便高效浏览和使用 App 的各项功能。

#### 验收标准

1. THE App_Shell SHALL 在屏幕底部展示一个包含 4 个 Tab 项（首页、搜索、购物车、我的）的 BottomNavigationBar
2. WHEN 用户点击某个 Tab 项时，THE App_Shell SHALL 切换到对应的页面并高亮当前选中的 Tab 项
3. THE App_Shell SHALL 使用 IndexedStack 保持各 Tab 页面的状态，避免切换 Tab 时页面重建
4. WHEN App 启动时，THE App_Shell SHALL 默认选中首页 Tab
5. THE App_Shell SHALL 为每个 Tab 项展示对应的 Material Icon 和文字标签
6. WHILE 购物车中存在商品时，THE App_Shell SHALL 在购物车 Tab 图标上展示商品数量角标（Badge）

### 需求 2：Tab 内独立导航栈

**用户故事：** 作为用户，我希望在某个 Tab 内进入子页面后，切换到其他 Tab 再切回来时仍保留之前的浏览位置，以便获得流畅的导航体验。

#### 验收标准

1. THE Tab_Navigator SHALL 为每个 Tab 维护独立的 Navigator 导航栈
2. WHEN 用户在某个 Tab 内进行页面跳转时，THE Tab_Navigator SHALL 仅在该 Tab 的导航栈内进行 push/pop 操作，不影响其他 Tab 的导航状态
3. WHEN 用户按下系统返回按钮时，THE Tab_Navigator SHALL 优先 pop 当前 Tab 的导航栈；IF 当前 Tab 导航栈已在根页面，THEN THE Tab_Navigator SHALL 将焦点切换到首页 Tab 或退出 App
4. WHEN 用户重复点击当前已选中的 Tab 项时，THE Tab_Navigator SHALL 将该 Tab 的导航栈 pop 到根页面

### 需求 3：首页

**用户故事：** 作为用户，我希望在首页看到推荐商品和促销信息，以便快速发现感兴趣的商品。

#### 验收标准

1. THE Home_Screen SHALL 展示一个可垂直滚动的内容区域，包含促销横幅区、分类导航区和推荐商品列表区
2. THE Home_Screen SHALL 复用现有的 ProductCardList Widget 展示推荐商品
3. WHEN 用户点击某个商品卡片时，THE Home_Screen SHALL 在当前 Tab 导航栈内跳转到商品详情页
4. WHEN 用户下拉页面顶部时，THE Home_Screen SHALL 触发刷新操作并更新页面内容
5. THE Home_Screen SHALL 通过 Product_Repository 获取商品数据，不直接依赖具体的数据源实现

### 需求 4：搜索页

**用户故事：** 作为用户，我希望通过搜索功能快速找到目标商品，以便节省浏览时间。

#### 验收标准

1. THE Search_Screen SHALL 在页面顶部展示一个搜索输入框
2. WHEN 用户在搜索框中输入文字时，THE Search_Screen SHALL 展示搜索建议列表
3. WHEN 用户提交搜索关键词时，THE Search_Screen SHALL 展示匹配的商品搜索结果列表
4. THE Search_Screen SHALL 展示用户的搜索历史记录
5. WHEN 用户点击搜索历史中的某条记录时，THE Search_Screen SHALL 使用该记录作为关键词执行搜索
6. WHEN 搜索结果为空时，THE Search_Screen SHALL 展示空状态提示信息
7. THE Search_Screen SHALL 复用现有的 ProductCardList Widget 展示搜索结果中的商品

### 需求 5：购物车

**用户故事：** 作为用户，我希望在购物车中管理已选商品并查看价格汇总，以便做出购买决策。

#### 验收标准

1. THE Cart_Screen SHALL 展示购物车中所有商品的列表，包含商品图片、名称、单价和数量
2. WHEN 用户调整某商品的数量时，THE Cart_Screen SHALL 实时更新该商品的小计和购物车总价
3. WHEN 用户将某商品数量减至零或点击删除按钮时，THE Cart_Screen SHALL 从购物车中移除该商品
4. THE Cart_Screen SHALL 在列表底部展示价格汇总区域，包含商品总数和总价
5. WHEN 购物车为空时，THE Cart_Screen SHALL 展示空状态页面，包含引导用户去购物的提示和跳转按钮
6. THE Cart_Screen SHALL 通过 Cart_Service 管理购物车状态，不直接操作购物车数据

### 需求 6：我的页面

**用户故事：** 作为用户，我希望在个人中心查看账户信息和快捷入口，以便管理我的账户和订单。

#### 验收标准

1. THE Profile_Screen SHALL 在页面顶部展示用户头像、昵称和会员等级信息区域
2. THE Profile_Screen SHALL 展示功能入口列表，包含我的订单、收货地址、优惠券、设置等常用入口
3. WHEN 用户点击某个功能入口时，THE Profile_Screen SHALL 在当前 Tab 导航栈内跳转到对应的子页面
4. WHILE 用户未登录时，THE Profile_Screen SHALL 展示登录引导界面替代用户信息区域

### 需求 7：分层架构与状态管理

**用户故事：** 作为开发者，我希望项目具有清晰的分层架构和统一的状态管理方案，以便团队高效协作和长期维护。

#### 验收标准

1. THE App_Shell SHALL 遵循以下目录结构组织代码：screens/ 存放页面级 Widget，widgets/ 存放可复用组件，models/ 存放数据模型，services/ 存放业务逻辑，utils/ 存放工具函数
2. THE Cart_Service SHALL 作为全局单例提供购物车状态，支持多个页面监听购物车变化（如 App_Shell 的角标和 Cart_Screen 的列表）
3. THE Product_Repository SHALL 提供统一的商品数据访问接口，封装数据获取和缓存逻辑
4. THE Theme_System SHALL 使用 ColorScheme.fromSeed 生成颜色方案，所有 Widget 通过 Theme.of(context) 访问设计 token，禁止硬编码颜色和文字样式
5. WHEN 新增页面或组件时，THE App_Shell SHALL 确保新代码遵循现有的 Widget 构建模式（const 构造函数、super.key 参数、组合优于继承）

### 需求 8：现有组件集成

**用户故事：** 作为开发者，我希望新架构能无缝集成现有的 Widget 和模型，以便避免重复开发并保持代码一致性。

#### 验收标准

1. THE App_Shell SHALL 保留并集成现有的 Product 模型（包含 brand、title、rating、reviewCount、currentPrice、originalPrice、flagText、flagType、priceType、imageUrl 字段）
2. THE App_Shell SHALL 保留并集成现有的 ProductCardList、ProductFlag 和 RecentlyViewedSheet Widget
3. THE Home_Screen SHALL 集成 RecentlyViewedSheet，支持用户查看最近浏览的商品
4. WHEN 重构 main.dart 时，THE App_Shell SHALL 保留现有的 NewRelic 监控集成代码
