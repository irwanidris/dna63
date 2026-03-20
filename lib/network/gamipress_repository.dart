import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/models/gamipress/common_gamipress_model.dart';
import 'package:socialv/models/gamipress/rewards_model.dart';
import 'package:socialv/network/network_utils.dart';
import 'package:socialv/utils/app_constants.dart';

Future<List<CommonGamiPressModel>> getGamiPressRewardsList({
  int page = 1,
  required String slug,
  required List<CommonGamiPressModel> rankList,
  Function(bool)? lastPageCallback,
}) async {
  List<String> params = [];

  params.add('per_page=$PER_PAGE');
  params.add('page=$page');
 
  Iterable it = await handleResponse(await buildHttpResponse(
    getEndPoint(
      endPoint: '${APIEndPoint.gamiPress}/${slug}',
      params: params,
    ),
    method: HttpMethod.GET,
  ));

  if (page == 1) rankList.clear();

  lastPageCallback?.call(it.validate().length != PER_PAGE);
  rankList.addAll(it.map((e) => CommonGamiPressModel.fromJson(e)).toList());

  return rankList;
}

Future<RewardsModel> rewards({required int userID}) async {
  return RewardsModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.gamipressEndPoint}/$userID/${APIEndPoint.earningsEndPoint}')));
}

Future<List<Rank>> userAchievements({required int userID, int page = 1}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.gamipressEndPoint}/$userID/${APIEndPoint.achievementEndPoint}/&page=$page&per_page=$PER_PAGE', method: HttpMethod.GET));
  return it.map((e) => Rank.fromJson(e)).toList();
}
