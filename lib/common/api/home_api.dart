import 'package:bili_own/common/models/local/home/recommend_item_info.dart';
import 'package:bili_own/common/models/local/video_tile/video_tile_info.dart';
import 'package:bili_own/common/models/network/home/recommend_video.dart';
import 'package:bili_own/common/utils/http_utils.dart';
import 'package:bili_own/common/api/api_constants.dart';
import 'dart:developer';

class HomeApi {
  static Future<RecommendVideoResponse> _requestRecommendVideos(
      int num, int refreshIdx) async {
    log("请求推荐视频: num=$num, refreshIdx=$refreshIdx");
    var response = await HttpUtils().get(
      ApiConstants.recommendItems,
      queryParameters: {
        'user-agent': ApiConstants.userAgent,
        'feed_version': "V3",
        'ps': num,
        'fresh_idx': refreshIdx
      },
    );
    log("推荐视频响应状态码: ${response.statusCode}");
    return RecommendVideoResponse.fromJson(response.data);
  }

  ///### 获取热门视频
  ///[pageSize]每页多少条视频
  ///[pageNum]页码
  static Future<List<VideoTileInfo>> getPopularVideos(
      {int pageSize = 20, required int pageNum}) async {
    var response = await HttpUtils().get(ApiConstants.popularVideos,
        queryParameters: {'ps': pageSize, 'pn': pageNum});
    if (response.data['code'] != 0) {
      throw "getPopularVideos: code:${response.data['code']}, message:${response.data['message']}";
    }
    List<VideoTileInfo> list = [];
    for (Map<String, dynamic> i in response.data['data']['list']) {
      list.add(VideoTileInfo(
          coverUrl: i['pic'] ?? '',
          bvid: i['bvid'] ?? '',
          cid: i['cid'] ?? 0,
          title: i['title'] ?? '',
          upName: i['owner']?['name'] ?? '',
          timeLength: i['duration'] ?? 0,
          playNum: i['stat']?['view'] ?? 0,
          pubDate: i['pubdate'] ?? 0));
    }
    return list;
  }

  ///#### 获取首页推荐
  ///[num]需要获取多少条推荐视频
  ///[refreshIdx]刷新加载的次数
  static Future<List<RecommendVideoItemInfo>> getRecommendVideoItems(
      {required int num, required int refreshIdx}) async {
    log("开始获取推荐视频: num=$num, refreshIdx=$refreshIdx");
    late RecommendVideoResponse response;
    try {
      response = await _requestRecommendVideos(num, refreshIdx);
    } catch (e, stackTrace) {
      log("请求推荐视频失败: $e");
      log("错误堆栈: $stackTrace");
      rethrow;
    }
    
    List<RecommendVideoItemInfo> list = [];
    if (response.code != 0) {
      log("获取推荐视频失败: code=${response.code}, message=${response.message}");
      throw "getRecommendVideoItems: code:${response.code}, message:${response.message}";
    }
    
    if (response.data == null || response.data!.item == null) {
      log("推荐视频数据为空");
      return list;
    }
    
    log("接收到 ${response.data!.item!.length} 个推荐视频项");
    for (var i in response.data!.item!) {
      list.add(RecommendVideoItemInfo(
          coverUrl: i.pic ?? "",
          danmakuNum: i.stat?.danmaku ?? 0,
          timeLength: i.duration ?? 0,
          title: i.title ?? "",
          upName: i.owner?.name ?? "",
          bvid: i.bvid ?? "",
          cid: i.cid ?? 0,
          playNum: i.stat?.view ?? 0));
    }
    log("成功解析 ${list.length} 个推荐视频项");
    return list;
  }
}