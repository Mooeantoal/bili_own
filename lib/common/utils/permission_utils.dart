import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  /// 请求存储权限
  static Future<bool> requestStoragePermission() async {
    // 检查是否有存储权限
    var status = await Permission.storage.status;
    
    // 如果没有权限，则请求权限
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    
    // 对于Android 11及以上版本，可能需要请求MANAGE_EXTERNAL_STORAGE权限
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }
    
    return status.isGranted;
  }
  
  /// 检查是否有存储权限
  static Future<bool> hasStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    }
    
    // 对于Android 11及以上版本，检查MANAGE_EXTERNAL_STORAGE权限
    status = await Permission.manageExternalStorage.status;
    return status.isGranted;
  }
  
  /// 打开应用设置页面
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}