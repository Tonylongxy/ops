import 'package:characters/characters.dart';
import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/routes/routes.dart';
import '../models/product_detail_response.dart';

class ProductDetailPageArgs {
  const ProductDetailPageArgs({
    required this.productId,
    this.previewName,
    this.previewImage,
  });

  factory ProductDetailPageArgs.from(Object? args) {
    if (args is ProductDetailPageArgs) {
      return args;
    }
    if (args is Map<String, dynamic>) {
      final productId = args['productId'] as String? ?? '';
      if (productId.isEmpty) {
        throw ArgumentError('productId 不能为空');
      }
      return ProductDetailPageArgs(
        productId: productId,
        previewName: args['previewName'] as String?,
        previewImage: args['previewImage'] as String?,
      );
    }
    throw ArgumentError('请通过 ProductDetailPageArgs 传入商品信息');
  }

  final String productId;
  final String? previewName;
  final String? previewImage;
}

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.args});

  final ProductDetailPageArgs args;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  ProductDetailResponse? _detail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final resp = await ApiClient().get('/product/detail/${widget.args.productId}');
      if (!mounted) return;
      setState(() {
        _detail = ProductDetailResponse.fromJson(resp);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '商品详情',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.home,
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '商品详情加载失败：$_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchDetail,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }
    final detail = _detail;
    if (detail == null) {
      return const Center(child: Text('暂无商品信息'));
    }
    return RefreshIndicator(
      onRefresh: _fetchDetail,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          _buildBanner(detail),
          _buildPriceSection(detail),
          _buildInfoSection(detail),
          _buildLicenseSection(detail),
          if (detail.detailPic.isNotEmpty) _buildDetailImage(detail.detailPic),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBanner(ProductDetailResponse detail) {
    final pics = detail.pics.isNotEmpty
        ? detail.pics.map((e) => e.middlePic.isNotEmpty ? e.middlePic : e.bigPic).toList()
        : (widget.args.previewImage?.isNotEmpty == true
            ? [widget.args.previewImage!]
            : <String>[]);
    final displayPics = pics.isNotEmpty ? pics : [''];

    return SizedBox(
      height: 280,
      child: PageView.builder(
        itemCount: displayPics.length,
        itemBuilder: (context, index) {
          final url = displayPics[index];
          return Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFB7E5FF), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: url.isNotEmpty
                  ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFEFEFEF),
      child: Center(
        child: Text(
          widget.args.previewName?.isNotEmpty == true
              ? widget.args.previewName!.characters.first
              : '图',
          style: const TextStyle(
            fontSize: 24,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection(ProductDetailResponse detail) {
    final info = detail.info;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB7E5FF), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info?.name ?? widget.args.previewName ?? '商品名称',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          if ((info?.spec ?? '').isNotEmpty)
            Text(
              info!.spec,
              style: const TextStyle(color: Colors.orange, fontSize: 14),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '¥${detail.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE66A1F),
                ),
              ),
              const SizedBox(width: 12),
              if (detail.originalPrice != null && detail.originalPrice! > 0)
                Text(
                  '¥${detail.originalPrice!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              const Spacer(),
              _buildFavoritedTag(detail),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildTag('库存', detail.checkStock ? '${detail.stockQty}' : '暂不可见'),
              if ((info?.salesUnitName ?? '').isNotEmpty)
                _buildTag('销售单位', info!.salesUnitName),
              if (detail.isOverbuyAllowed == 1) _buildTag('允许超卖', '是'),
              if ((info?.limitNum ?? 0) > 0)
                _buildTag('限购', '${info!.limitNum}'),
              if ((info?.minOrderQty ?? 0) > 0)
                _buildTag('起订量', '${info!.minOrderQty}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F6EE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label：$value',
        style: const TextStyle(color: Color(0xFF09AA43), fontSize: 12),
      ),
    );
  }

  Widget _buildInfoSection(ProductDetailResponse detail) {
    final info = detail.info;
    if (info == null) {
      return const SizedBox.shrink();
    }
    final rows = <Widget>[
      _buildInfoRow('商品编码', info.code),
      _buildInfoRow('标准编码', info.stdCode),
      _buildInfoRow('品牌', info.brandName),
      _buildInfoRow('注册证号', info.regNo),
      _buildInfoRow('注册证名称', info.regProductName),
      _buildInfoRow('生产企业', info.productEnterprise),
      _buildInfoRow('包装方式', info.pack),
      _buildInfoRow('包装单位', info.packName),
      _buildInfoRow('医械类别', info.machineType),
      _buildInfoRow('医械类号', info.machineSortNo),
      _buildInfoRow('医保码', info.medCode),
      _buildInfoRow('适用范围', info.scope),
      _buildInfoRow('产品标准', info.standard),
      _buildInfoRow('规格参数', info.specParam),
      _buildInfoRow('生产日期', info.factoryDate),
      _buildInfoRow('有效期至', info.periodValidity.isNotEmpty ? info.periodValidity : info.expireDate),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB7E5FF), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '商品信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseSection(ProductDetailResponse detail) {
    final info = detail.info;
    if (info == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB7E5FF), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '证照信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('证照UID', info.regUid),
          _buildInfoRow('证照编号', info.regNo),
          _buildInfoRow('证照有效期', info.periodValidity),
          _buildInfoRow('注册证产品名称', info.regProductName),
        ],
      ),
    );
  }

  Widget _buildDetailImage(String url) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB7E5FF), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '产品详情',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritedTag(ProductDetailResponse detail) {
    final isFavorited = detail.isFavorited;
    return Row(
      children: [
        Icon(
          isFavorited ? Icons.favorite : Icons.favorite_border,
          color: isFavorited ? Colors.redAccent : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          isFavorited ? '已收藏' : '收藏',
          style: TextStyle(
            color: isFavorited ? Colors.redAccent : Colors.grey,
          ),
        ),
      ],
    );
  }
}


