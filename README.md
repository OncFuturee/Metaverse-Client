# Metaverse-Client
元宇宙视频客户端是一个基于 Flutter 框架开发的跨平台应用，旨在打造一个身临其境的赛博世界，使用户能够在虚拟空间中探索、互动和分享。该应用融合了最新的视频技术、社交互动和 3D 虚拟体验，为用户提供一个全新的数字化社交和娱乐平台。
# 项目架构
本项目基于`模块化设计`和`插件式开发`,拥有`横向扩展能力`。
## 关键设计原则
- 开闭原则：对扩展开放，对修改关闭
- 单一职责：每个模块 / 类只负责单一功能
- 依赖倒置：依赖抽象而非具体实现
- 接口隔离：细粒度接口减少依赖
- 插件式架构：通过注册机制动态添加功能
## 完整项目结构
```plaintext
lib/
├── app/                   # 应用全局配置（不变）
│   ├── app.dart           # 应用入口
│   ├── app_config.dart    # 应用配置
│   └── app_theme.dart     # 主题配置
│
├── core/                  # 核心框架（不变）
│   ├── di/                # 依赖注入（服务注册）
│   ├── errors/            # 错误处理
│   ├── exceptions/        # 异常类型
│   ├── utils/             # 工具类
│   ├── constants/         # 常量定义
│   ├── registry/          # 模块注册表
│   └── event_bus/         # 事件总线（模块间通信）
│
├── domain/                # 领域层（不变）
│   ├── entities/          # 通用实体
│   ├── value_objects/     # 值对象
│   └── shared/            # 共享业务逻辑
│
├── platform/              # 平台适配（不变）
│   ├── base/              # 平台接口定义
│   ├── android/           # Android 实现
│   ├── ios/               # iOS 实现
│   ├── web/               # Web 实现
│   └── desktop/           # 桌面端实现
│
├── features/              # 功能模块（横向扩展点）
│   ├── auth/              # 认证模块
│   │   ├── domain/        # 认证领域逻辑
│   │   ├── data/          # 认证数据层
│   │   ├── presentation/  # 认证UI
│   │   └── auth_module.dart  # 模块注册
│   │
│   ├── video_player/      # 视频播放模块
│   │   ├── domain/        # 视频领域逻辑
│   │   ├── data/          # 视频数据层
│   │   ├── presentation/  # 视频UI
│   │   └── video_module.dart  # 模块注册
│   │
│   ├── social/            # 社交模块
│   │   ├── domain/        # 社交领域逻辑
│   │   ├── data/          # 社交数据层
│   │   ├── presentation/  # 社交UI
│   │   └── social_module.dart  # 模块注册
│   │
│   └── ...                # 未来可扩展模块（如直播、AR滤镜等）
│
└── main.dart              # 程序入口点
```
### 核心目录详解
1. app/ - 应用全局配置
```plaintext
app/
├── app.dart           # 应用入口点，初始化模块
├── app_config.dart    # 应用配置（API地址、环境变量等）
└── app_theme.dart     # 主题配置（亮色/暗色模式）
```
2. core/ - 核心框架
```plaintext
core/
├── di/                # 依赖注入
│   ├── injection_container.dart  # 全局服务注册
│   └── service_locator.dart      # 服务定位器
│
├── errors/            # 错误处理
│   ├── failure.dart    # 统一错误类型
│   └── error_handler.dart  # 错误处理器
│
├── registry/          # 模块注册表
│   ├── feature_registry.dart  # 功能模块注册
│   └── factory_registry.dart  # 工厂模式注册
│
├── event_bus/         # 事件总线
│   └── app_event_bus.dart  # 全局事件总线
│
└── utils/             # 工具类
    ├── logger.dart    # 日志工具
    └── network_info.dart  # 网络状态工具
```
3. domain/ - 领域层
```plaintext
domain/
├── entities/          # 通用实体（跨模块共享）
│   ├── user.dart      # 用户实体
│   ├── video.dart     # 视频实体
│   └── comment.dart   # 评论实体
│
├── value_objects/     # 值对象
│   ├── unique_id.dart  # 唯一ID
│   └── email_address.dart  # 邮箱地址
│
└── shared/            # 共享业务逻辑
    └── use_case.dart  # 用例基类
```
4. platform/ - 平台适配
```plaintext
platform/
├── base/              # 平台接口定义
│   ├── file_service.dart     # 文件操作接口
│   ├── cache_service.dart    # 缓存服务接口
│   └── device_info.dart      # 设备信息接口
│
├── android/           # Android 实现
│   ├── file_service_android.dart  # 文件操作实现
│   └── ...
│
├── ios/               # iOS 实现
│   ├── file_service_ios.dart  # 文件操作实现
│   └── ...
│
└── web/               # Web 实现
    ├── file_service_web.dart  # 文件操作实现
    └── ...
```
#### 功能模块结构（以video_player为例）
```plaintext
features/video_player/
├── domain/                # 领域层
│   ├── entities/          # 视频相关实体
│   ├── repositories/      # 仓库接口
│   ├── use_cases/         # 用例（业务逻辑）
│   └── video_failure.dart  # 视频模块错误类型
│
├── data/                  # 数据层
│   ├── datasources/       # 数据源
│   │   ├── local/         # 本地数据源
│   │   └── remote/        # 远程数据源
│   ├── models/            # 数据模型
│   ├── repositories/      # 仓库实现
│   └── video_mapper.dart  # 实体与模型映射
│
├── presentation/          # 表现层
│   ├── screens/           # 页面
│   ├── widgets/           # 组件
│   ├── providers/         # 状态管理（Provider）
│   └── routes/            # 路由
│
└── video_module.dart      # 模块注册
```
#### 模块注册示例
```dart
// features/video_player/video_module.dart
class VideoPlayerModule implements FeatureModule {
  @override
  String get name => 'video_player';
  
  @override
  void init() {
    // 注册依赖
    sl.registerLazySingleton<VideoRepository>(
      () => VideoRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ),
    );
    
    // 注册用例
    sl.registerLazySingleton(() => GetVideoDetails(sl()));
    sl.registerLazySingleton(() => ToggleVideoLike(sl()));
    
    // 注册平台实现
    if (kIsWeb) {
      sl.registerLazySingleton<VideoPlayerService>(() => WebVideoPlayerServiceImpl());
    } else {
      sl.registerLazySingleton<VideoPlayerService>(() => MobileVideoPlayerServiceImpl());
    }
  }
  
  @override
  List<Route> get routes => [
    MaterialPageRoute(builder: (_) => VideoPlayerScreen()),
    MaterialPageRoute(builder: (_) => VideoDetailScreen()),
  ];
}
```
#### 主程序初始化
```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initCore(); // 初始化核心服务
  
  // 注册功能模块
  FeatureRegistry.registerModule(AuthModule());
  FeatureRegistry.registerModule(VideoPlayerModule());
  FeatureRegistry.registerModule(SocialModule());
  
  // 未来扩展只需添加新模块
  // FeatureRegistry.registerModule(LiveStreamingModule());
  // FeatureRegistry.registerModule(ARFilterModule());
  
  runApp(const MyApp());
}
```
#### 横向扩展示例
添加新功能（如直播）时，只需创建新模块：
```plaintext
features/live_streaming/
├── domain/
├── data/
├── presentation/
└── live_streaming_module.dart  # 新模块注册
```
#### 关键设计亮点
- 核心框架稳定：core/、domain/、platform/ 目录结构固定，不随业务扩展变化
- 功能模块隔离：每个模块拥有独立的 MVC 结构，通过接口与外部通信
- 注册表机制：通过 FeatureRegistry 动态注册模块，避免硬编码
- 依赖倒置：模块间依赖抽象接口，而非具体实现
- 事件驱动：通过 EventBus 实现松耦合的模块间通信

这种架构设计使项目可以像**插件系统**一样轻松添加新功能，同时保持现有代码的稳定性和可维护性。
