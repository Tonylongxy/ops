import '../core/utils/json_utils.dart';

class ProductDetailResponse {
  const ProductDetailResponse({
    required this.info,
    required this.detailPic,
    required this.pics,
    required this.price,
    required this.stockQty,
    required this.checkStock,
    required this.isOverbuyAllowed,
    required this.isFavorited,
    required this.favoriteId,
    required this.originalPrice,
    required this.activityList,
    required this.saleId,
    required this.labelImgUrl,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    final picsJson = json['pics'] as List<dynamic>? ?? [];
    final activities = json['activityList'] as List<dynamic>? ?? [];
    return ProductDetailResponse(
      info: json['info'] != null
          ? ProductInfo.fromJson(json['info'] as Map<String, dynamic>)
          : null,
      detailPic: json['detailPic'] as String? ?? '',
      pics: picsJson
          .map((e) => ProductPic.fromJson(e as Map<String, dynamic>))
          .toList(),
      price: JsonUtils.parseDouble(json['price']) ?? 0,
      stockQty: JsonUtils.parseInt(json['stockQty']) ?? 0,
      checkStock: json['checkStock'] as bool? ?? false,
      isOverbuyAllowed: JsonUtils.parseInt(json['isOverbuyAllowed']) ?? 0,
      isFavorited: json['isFavorited'] as bool? ?? false,
      favoriteId: JsonUtils.parseInt(json['favoriteId']),
      originalPrice: JsonUtils.parseDouble(json['originalPrice']),
      activityList: activities
          .whereType<Map<String, dynamic>>()
          .map(ActivityInfo.fromJson)
          .toList(),
      saleId: json['saleId'] as String?,
      labelImgUrl: json['labelImgUrl'] as String?,
    );
  }

  final ProductInfo? info;
  final String detailPic;
  final List<ProductPic> pics;
  final double price;
  final int stockQty;
  final bool checkStock;
  final int isOverbuyAllowed;
  final bool isFavorited;
  final int? favoriteId;
  final double? originalPrice;
  final List<ActivityInfo> activityList;
  final String? saleId;
  final String? labelImgUrl;
}

class ProductPic {
  const ProductPic({
    required this.smallPic,
    required this.middlePic,
    required this.bigPic,
    required this.seq,
  });

  factory ProductPic.fromJson(Map<String, dynamic> json) {
    return ProductPic(
      smallPic: json['smallPic'] as String? ?? '',
      middlePic: json['middlePic'] as String? ?? '',
      bigPic: json['bigPic'] as String? ?? '',
      seq: JsonUtils.parseInt(json['seq']) ?? 0,
    );
  }

  final String smallPic;
  final String middlePic;
  final String bigPic;
  final int seq;
}

class ProductInfo {
  const ProductInfo({
    required this.id,
    required this.code,
    required this.name,
    required this.spec,
    required this.type,
    required this.stdCode,
    required this.brandId,
    required this.brandName,
    required this.brandLog,
    required this.productCount,
    required this.regUid,
    required this.regNo,
    required this.regProductName,
    required this.pack,
    required this.packName,
    required this.productEnterprise,
    required this.periodValidity,
    required this.scope,
    required this.standard,
    required this.machineType,
    required this.machineSortNo,
    required this.medCode,
    required this.salesUnitName,
    required this.specParam,
    required this.factoryDate,
    required this.expireDate,
    required this.limitNum,
    required this.minOrderQty,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      spec: json['spec'] as String? ?? '',
      type: JsonUtils.parseInt(json['type']) ?? 0,
      stdCode: json['stdCode'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      brandName: json['brandName'] as String? ?? '',
      brandLog: json['brandLog'] as String? ?? '',
      productCount: JsonUtils.parseInt(json['productCount']) ?? 0,
      regUid: json['regUid'] as String? ?? '',
      regNo: json['regNo'] as String? ?? '',
      regProductName: json['regProductName'] as String? ?? '',
      pack: json['pack'] as String? ?? '',
      packName: json['packName'] as String? ?? '',
      productEnterprise: json['productEnterprise'] as String? ?? '',
      periodValidity: json['periodValidity'] as String? ?? '',
      scope: json['scope'] as String? ?? '',
      standard: json['standard'] as String? ?? '',
      machineType: json['machineType'] as String? ?? '',
      machineSortNo: json['machineSortNo'] as String? ?? '',
      medCode: json['medCode'] as String? ?? '',
      salesUnitName: json['salesUnitName'] as String? ?? '',
      specParam: json['specParam'] as String? ?? '',
      factoryDate: json['factoryDate'] as String? ?? '',
      expireDate: json['expireDate'] as String? ?? '',
      limitNum: JsonUtils.parseInt(json['limitNum']) ?? 0,
      minOrderQty: JsonUtils.parseInt(json['minOrderQty']) ?? 0,
    );
  }

  final String id;
  final String code;
  final String name;
  final String spec;
  final int type;
  final String stdCode;
  final String brandId;
  final String brandName;
  final String brandLog;
  final int productCount;
  final String regUid;
  final String regNo;
  final String regProductName;
  final String pack;
  final String packName;
  final String productEnterprise;
  final String periodValidity;
  final String scope;
  final String standard;
  final String machineType;
  final String machineSortNo;
  final String medCode;
  final String salesUnitName;
  final String specParam;
  final String factoryDate;
  final String expireDate;
  final int limitNum;
  final int minOrderQty;
}

class ActivityInfo {
  const ActivityInfo({required this.raw});

  factory ActivityInfo.fromJson(Map<String, dynamic> json) {
    return ActivityInfo(raw: json);
  }

  final Map<String, dynamic> raw;
}


