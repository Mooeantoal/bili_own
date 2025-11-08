import 'package:bili_own/common/widget/loading_state.dart';
import 'package:bili_own/common/api/search_api.dart';
import 'package:bili_own/common/models/network/search/search_trending/data.dart';
import 'package:bili_own/common/models/network/search/search_trending/list.dart';
import 'package:bili_own/pages/common/common_list_controller.dart';

class SearchTrendingController
    extends CommonListController<SearchTrendingData, SearchTrendingItemModel> {
  int topCount = 0;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<SearchTrendingItemModel>? getDataList(SearchTrendingData response) {
    List<SearchTrendingItemModel> topList =
        response.data?.topList ?? <SearchTrendingItemModel>[];
    topCount = topList.length;
    return response.data?.list == null ? topList : topList
      ..addAll(response.data?.list ?? []);
  }

  @override
  Future<LoadingState<SearchTrendingData>> customGetData() async {
    try {
      final data = await SearchApi.searchTrending();
      return LoadingState.success(data);
    } catch (e) {
      return LoadingState.error(e.toString());
    }
  }
}