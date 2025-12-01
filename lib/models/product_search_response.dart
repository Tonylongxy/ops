import '../core/utils/json_utils.dart';

class ProductSearchResponse {
  const ProductSearchResponse({
    required this.records,
    required this.total,
  });

  factory ProductSearchResponse.fromJson(Map<String, dynamic> json) {
    final recordsJson = json['records'] as List<dynamic>? ?? [];
    return ProductSearchResponse(
      records: recordsJson
          .map((item) => SearchProductVo.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: JsonUtils.parseInt(json['total']) ?? 0,
    );
  }

  final List<SearchProductVo> records;
  final int total;
}

class SearchProductVo {
  const SearchProductVo({
    required this.id,
    required this.name,
    required this.code,
    required this.spec,
    required this.mainPic,
    required this.price,
    required this.spuCode,
    required this.spuQty,
    required this.seq,
    required this.stdCode,
    required this.isFavorited,
    required this.favoriteId,
    required this.guidePrice,
    required this.activeStart,
    required this.activeEnd,
    required this.activePrice,
    required this.searchScore,
    required this.isEshop,
  });

  factory SearchProductVo.fromJson(Map<String, dynamic> json) {
    return SearchProductVo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      spec: json['spec'] as String? ?? '',
      mainPic: json['mainPic'] as String? ?? '',
      price: JsonUtils.parseDouble(json['price']) ?? 0,
      spuCode: json['spuCode'] as String? ?? '',
      spuQty: JsonUtils.parseInt(json['spuQty']) ?? 0,
      seq: JsonUtils.parseInt(json['seq']) ?? 0,
      stdCode: json['stdCode'] as String? ?? '',
      isFavorited: json['isFavorited'] as bool? ?? false,
      favoriteId: JsonUtils.parseInt(json['favoriteId']),
      guidePrice: JsonUtils.parseDouble(json['guidePrice']),
      activeStart: json['activeStart'] as String?,
      activeEnd: json['activeEnd'] as String?,
      activePrice: JsonUtils.parseDouble(json['activePrice']),
      searchScore: JsonUtils.parseDouble(json['searchScore']),
      isEshop: JsonUtils.parseInt(json['isEshop']),
    );
  }

  final String id;
  final String name;
  final String code;
  final String spec;
  final String mainPic;
  final double price;
  final String spuCode;
  final int spuQty;
  final int seq;
  final String stdCode;
  final bool isFavorited;
  final int? favoriteId;
  final double? guidePrice;
  final String? activeStart;
  final String? activeEnd;
  final double? activePrice;
  final double? searchScore;
  final int? isEshop;
}



