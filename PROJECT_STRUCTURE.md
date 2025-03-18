# ActiveBg 项目结构说明

## 目录结构

### core/
核心功能目录
- `constants/`: 常量定义
  - `app_constants.dart`: 应用常量
- `services/`: 核心服务
  - `wallpaper_service.dart`: 壁纸服务
- `utils/`: 工具类
  - `file_util.dart`: 文件操作
  - `network_util.dart`: 网络请求

### features/
功能模块目录
- `wallpaper/`: 壁纸功能
  - `dynamic/`: 动态壁纸
  - `static/`: 静态壁纸
  - `timer/`: 定时切换
- `settings/`: 设置功能
- `link_parser/`: 链接解析

### shared/
共享资源目录
- `widgets/`: 通用组件
- `models/`: 数据模型
- `themes/`: 主题配置
  - `app_theme.dart`: 应用主题

### pages/
页面目录
- `home/`: 主页
  - `home_page.dart`: 主页面
- `settings/`: 设置页面

## 开发规范

### 命名规范
- 文件名: 小写下划线 (`home_page.dart`)
- 类名: 大驼峰 (`HomePage`)
- 变量/方法: 小驼峰 (`userName`)

### 导入顺序
1. Dart/Flutter SDK
2. 第三方包
3. 本项目文件

### 代码组织
- 相关功能放在同一目录
- 共用组件放在 shared
- 页面放在 pages