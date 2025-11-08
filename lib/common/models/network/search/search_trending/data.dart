import 'dart:convert';
import 'package:bili_you/common/models/network/search/search_trending/list.dart';

class SearchTrendingData {
  SearchTrendingData({
    this.code,
    this.message,
    this.data,
  });

  int? code;
  String? message;
  Data? data;

  factory SearchTrendingData.fromRawJson(String str) =>
      SearchTrendingData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SearchTrendingData.fromJson(Map<String, dynamic> json) =>
      SearchTrendingData(
        code: json["code"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  Data({
    this.trackid,
    this.list,
    this.topList,
  });

  String? trackid;
  List<SearchTrendingItemModel>? list;
  List<SearchTrendingItemModel>? topList;

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        trackid: json["trackid"],
        list: json["list"] == null
            ? []
            : List<SearchTrendingItemModel>.from(
                json["list"]!.map((x) => SearchTrendingItemModel.fromJson(x))),
        topList: json["top_list"] == null
            ? []
            : List<SearchTrendingItemModel>.from(
                json["top_list"]!.map(
                  (x) => SearchTrendingItemModel.fromJson(x),
                ),
              ),
      );

  Map<String, dynamic> toJson() => {
        "trackid": trackid,
        "list": list == null
            ? []
            : List<dynamic>.from(list!.map((x) => x.toJson())),
        "top_list": topList == null
            ? []
            : List<dynamic>.from(topList!.map((x) => x.toJson())),
      };
}