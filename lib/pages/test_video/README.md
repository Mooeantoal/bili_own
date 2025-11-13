# 测试视频页面

这个页面用于测试从bilimiao项目移植的功能。

## 功能测试

1. **播放器功能测试** - 测试视频播放、暂停、快进等基本功能
2. **弹幕功能测试** - 测试弹幕显示、控制等
3. **评论功能测试** - 测试评论显示、交互等
4. **完整视频详情页面测试** - 整合播放器、弹幕、评论的完整页面测试
5. **Bilimiao风格视频详情页面** - 模仿bilimiao项目的视频详情页面结构

## 文件结构

- `view.dart` - 页面主视图
- `controller.dart` - 页面控制器
- `widgets/test_video_player.dart` - 测试视频播放器组件
- `widgets/test_danmaku.dart` - 测试弹幕组件
- `widgets/test_reply.dart` - 测试评论组件
- `widgets/test_video_player_panel.dart` - 测试播放器控制面板
- `widgets/test_danmaku_panel.dart` - 测试弹幕控制面板
- `widgets/video_detail_page.dart` - 完整视频详情页面
- `widgets/video_detail_route.dart` - 视频详情页面路由
- `route.dart` - 测试页面路由

## 使用方法

在首页点击右下角的虫子图标按钮即可访问测试页面。
点击"Bilimiao风格视频详情页面"按钮可以查看模仿bilimiao项目的完整视频详情页面。