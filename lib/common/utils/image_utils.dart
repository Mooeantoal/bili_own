class ImageUtils {
  /// 生成缩略图URL
  static String thumbnailUrl(String url) {
    // 如果URL已经包含缩略图参数，直接返回
    if (url.contains('@')) {
      return url;
    }
    // 添加缩略图参数
    return '$url@100w_100h.webp';
  }
}