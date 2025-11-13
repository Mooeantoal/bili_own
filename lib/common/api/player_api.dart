import 'package:bili_own/common/api/api_constants.dart';
import 'package:bili_own/common/models/network/video_play/video_play.dart';
import 'package:bili_own/common/models/network/proto/danmaku/danmaku.pb.dart';
import 'package:bili_own/common/models/network/reply/reply.dart';
import 'package:bili_own/common/utils/http_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PlayerApi {
  /// 获取视频播放地址
  static Future<VideoPlayResponse> getVideoPlayUrl({
    required String bvid,
    required int cid,
    int quality = 64,
    int fnval = 4048, // 4048: dash
  }) async {
    try {
      var response = await HttpUtils().get(
        ApiConstants.videoPlay,
        queryParameters: {
          'bvid': bvid,
          'cid': cid,
          'qn': quality,
          'fnval': fnval,
          'fnver': 0,
          'force_host': 2,
          'type': '',
          'otype': 'json',
          if (fnval > 2) 'fourk': 1,
        },
        options: Options(
          headers: {
            'user-agent': ApiConstants.userAgent,
            'referer': 'https://www.bilibili.com/',
          },
        ),
      );

      return VideoPlayResponse.fromJson(response.data);
    } catch (e) {
      print("获取视频播放地址失败: $e");
      rethrow;
    }
  }

  /// 获取番剧播放地址
  static Future<VideoPlayResponse> getBangumiPlayUrl({
    required String epid,
    required int cid,
    int quality = 64,
    int fnval = 4048,
  }) async {
    try {
      var response = await HttpUtils().get(
        ApiConstants.bangumiPlayUrl,
        queryParameters: {
          'ep_id': epid,
          'cid': cid,
          'qn': quality,
          'fnval': fnval,
          'fnver': 0,
          'force_host': 2,
          'module': 'bangumi',
          'season_type': 1,
          'session': _generateSession(),
          'track_path': '',
          'device': 'android',
          'mobi_app': 'android',
          'platform': 'android',
          if (fnval > 2) 'fourk': 1,
        },
      );

      return VideoPlayResponse.fromJson(response.data);
    } catch (e) {
      print("获取番剧播放地址失败: $e");
      rethrow;
    }
  }

  /// 获取弹幕列表
  static Future<DmSegMobileReply> getDanmakuList({
    required int cid,
    int segmentIndex = 1,
  }) async {
    try {
      var response = await HttpUtils().get(
        ApiConstants.danmaku,
        queryParameters: {
          'type': 1,
          'oid': cid,
          'segment_index': segmentIndex,
        },
        options: Options(responseType: ResponseType.bytes),
      );

      return DmSegMobileReply.fromBuffer(response.data);
    } catch (e) {
      print("获取弹幕列表失败: $e");
      rethrow;
    }
  }

  /// 发送弹幕
  static Future<void> sendDanmaku({
    required String message,
    required String aid,
    required String oid,
    required int progress,
    required int color,
    required int fontsize,
    required int mode,
  }) async {
    try {
      var response = await HttpUtils().post(
        ApiConstants.sendDanmaku,
        data: {
          'msg': message,
          'type': 1,
          'aid': aid,
          'oid': oid,
          'progress': progress,
          'color': color,
          'fontsize': fontsize,
          'mode': mode,
          'rnd': DateTime.now().millisecondsSinceEpoch,
        },
      );

      if (response.data['code'] != 0) {
        throw Exception('发送弹幕失败: ${response.data['message']}');
      }
    } catch (e) {
      print("发送弹幕失败: $e");
      rethrow;
    }
  }

  /// 生成会话ID
  static String _generateSession() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

class CommentApi {
  /// 获取主评论列表
  static Future<ReplyResponse> getMainList({
    required String oid,
    required int sort,
    required ReplyType type,
    required int pageNum,
    required int pageSize,
  }) async {
    try {
      var response = await HttpUtils().get(
        ApiConstants.reply,
        queryParameters: {
          'oid': oid,
          'plat': 2,
          'sort': sort,
          'pn': pageNum,
          'ps': pageSize,
          'type': type.code,
        },
      );

      return await compute(
        (response) => ReplyResponse.fromJson(response),
        response.data,
      );
    } catch (e) {
      print("获取主评论列表失败: $e");
      rethrow;
    }
  }

  /// 获取评论回复列表
  static Future<ReplyResponse> getReplyList({
    required String oid,
    required String rpid,
    required ReplyType type,
    required int pageNum,
    required int pageSize,
  }) async {
    try {
      var response = await HttpUtils().get(
        ApiConstants.reply,
        queryParameters: {
          'oid': oid,
          'plat': 2,
          'root': rpid,
          'sort': 0,
          'type': type.code,
          'pn': pageNum,
          'ps': pageSize,
        },
      );

      return await compute(
        (response) => ReplyResponse.fromJson(response),
        response.data,
      );
    } catch (e) {
      print("获取评论回复列表失败: $e");
      rethrow;
    }
  }

  /// 点赞/取消赞评论
  static Future<void> likeComment({
    required ReplyType type,
    required String oid,
    required int rpid,
    required int action, // 0: 取消赞, 1: 点赞
  }) async {
    try {
      var response = await HttpUtils().post(
        ApiConstants.replyAction,
        data: {
          'type': type.code,
          'oid': oid,
          'rpid': rpid,
          'action': action,
        },
      );

      if (response.data['code'] != 0) {
        throw Exception('点赞评论失败: ${response.data['message']}');
      }
    } catch (e) {
      print("点赞评论失败: $e");
      rethrow;
    }
  }

  /// 添加评论
  static Future<void> addComment({
    required String message,
    required ReplyType type,
    required String oid,
    String? root,
    String? parent,
  }) async {
    try {
      var params = {
        'type': type.code,
        'oid': oid,
        'message': message,
        'plat': 2,
      };

      if (root != null) params['root'] = root;
      if (parent != null) params['parent'] = parent;

      var response = await HttpUtils().post(
        ApiConstants.replyAdd,
        data: params,
      );

      if (response.data['code'] != 0) {
        throw Exception('添加评论失败: ${response.data['message']}');
      }
    } catch (e) {
      print("添加评论失败: $e");
      rethrow;
    }
  }

  /// 删除评论
  static Future<void> deleteComment({
    required ReplyType type,
    required String oid,
    required int rpid,
  }) async {
    try {
      var response = await HttpUtils().post(
        ApiConstants.replyDel,
        data: {
          'type': type.code,
          'oid': oid,
          'rpid': rpid,
        },
      );

      if (response.data['code'] != 0) {
        throw Exception('删除评论失败: ${response.data['message']}');
      }
    } catch (e) {
      print("删除评论失败: $e");
      rethrow;
    }
  }
}

/// 评论类型枚举
enum ReplyType {
  video, // 视频评论
  bangumi, // 番剧评论
  article, // 文章评论
}

/// 评论类型扩展
extension ReplyTypeCode on ReplyType {
  int get code {
    switch (this) {
      case ReplyType.video:
        return 1;
      case ReplyType.bangumi:
        return 11;
      case ReplyType.article:
        return 12;
      default:
        return 1;
    }
  }
}