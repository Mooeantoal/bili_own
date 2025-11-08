import 'dart:convert';

class SearchTrendingItemModel {
  SearchTrendingItemModel({
    this.keyword,
    this.showLiveIcon,
    this.icon,
    this.uri,
  });

  String? keyword;
  bool? showLiveIcon;
  String? icon;
  String? uri;

  factory SearchTrendingItemModel.fromRawJson(String str) =>
      SearchTrendingItemModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SearchTrendingItemModel.fromJson(Map<String, dynamic> json) =>
      SearchTrendingItemModel(
        keyword: json["keyword"],
        showLiveIcon: json["show_live_icon"],
        icon: json["icon"],
        uri: json["uri"],
      );

  Map<String, dynamic> toJson() => {
        "keyword": keyword,
        "show_live_icon": showLiveIcon,
        "icon": icon,
        "uri": uri,
      };
}