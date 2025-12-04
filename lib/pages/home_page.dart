import 'package:characters/characters.dart';
import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/routes/routes.dart';
import '../core/session/app_session.dart';
import '../models/login_response.dart';
import '../models/product_search_response.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _historyKeywords = [];
  List<SearchProductVo> _products = [];
  bool _isLoading = false;
  bool _isHistoryLoading = false;
  String? _errorMessage;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_handleSearchFocus);
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode
      ..removeListener(_handleSearchFocus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(),
            _buildPlaceholderTab('分类'),
            _buildPlaceholderTab('购物车'),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          _buildSearchHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetchProducts(keyword: _searchController.text),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  _buildProductSliver(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: Text(
        '$title功能开发中',
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<LoginResponse?>(
            valueListenable: AppSession.instance.currentUser,
            builder: (context, value, _) {
              final company = value?.customerName.isNotEmpty == true
                  ? value!.customerName
                  : '松佰医疗器械有限公司';
              final initials =
                  company.isNotEmpty ? company.characters.first : '松';
              return Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFE9F6EE),
                    child: Text(
                      initials,
                      style: const TextStyle(color: Color(0xFF45B073)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      company,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onSubmitted: _performSearch,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '请输入商品名称',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF09AA43),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () => _performSearch(_searchController.text),
                child: const Text('搜索'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_shouldShowHistoryPanel) _buildHistoryPanel(),
        ],
      ),
    );
  }

  Widget _buildProductSliver() {
    if (_isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '加载失败：$_errorMessage',
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _fetchProducts(keyword: _searchController.text),
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }
    if (_products.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            '暂无商品，试试其他关键词',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = _products[index];
            return _ProductCard(
              product: product,
              onTap: () => _onProductTap(product),
            );
          },
          childCount: _products.length,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == 3) {
          Navigator.of(context).pushNamed(AppRoutes.my);
          return;
        }
        setState(() => _currentIndex = index);
      },
      selectedItemColor: const Color(0xFF09AA43),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
        BottomNavigationBarItem(icon: Icon(Icons.apps), label: '分类'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: '购物车'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
      ],
    );
  }
  Future<void> _fetchProducts({String keyword = ''}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final payload = await ApiClient().post('/product/search', data: {
        'keyword': keyword,
      });
      final result = ProductSearchResponse.fromJson(payload);
      setState(() {
        _products = result.records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  bool get _shouldShowHistoryPanel => _searchFocusNode.hasFocus;

  void _handleSearchFocus() {
    if (_searchFocusNode.hasFocus) {
      _fetchHistoryKeywords();
    }
    setState(() {});
  }

  Future<void> _fetchHistoryKeywords() async {
    if (_isHistoryLoading) return;
    setState(() {
      _isHistoryLoading = true;
    });
    try {
      final payload = await ApiClient().get('/product/history');
      final data = payload['data'];
      if (!mounted) return;
      if (data is List) {
        setState(() {
          _historyKeywords = data
              .map((item) =>
                  (item is Map<String, dynamic> ? item['content'] : null))
              .whereType<String>()
              .toList();
        });
      }
    } catch (e) {
      debugPrint('历史搜索获取失败：$e');
    } finally {
      if (mounted) {
        setState(() {
          _isHistoryLoading = false;
        });
      }
    }
  }

  void _performSearch(String keyword) {
    final trimmed = keyword.trim();
    _searchController.text = trimmed;
    _fetchProducts(keyword: trimmed);
    FocusScope.of(context).unfocus();
  }

  Widget _buildHistoryPanel() {
    return Container(
      key: const ValueKey('history-panel'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: _isHistoryLoading
          ? const Center(
              child: SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              ),
            )
          : _historyKeywords.isEmpty
              ? const Center(
                  child: Text(
                    '暂无历史搜索记录',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '历史搜索',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: ListView.separated(
                        itemCount: _historyKeywords.length,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, thickness: 0.5),
                        itemBuilder: (context, index) {
                          final keyword = _historyKeywords[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              keyword,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _onHistoryItemTap(keyword),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  void _onHistoryItemTap(String keyword) {
    _searchController.text = keyword;
    _performSearch(keyword);
  }

  void _onProductTap(SearchProductVo product) {
    Navigator.of(context).pushNamed(
      AppRoutes.productDetail,
      arguments: ProductDetailPageArgs(
        productId: product.id,
        previewName: product.name,
        previewImage: product.mainPic,
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, this.onTap});

  final SearchProductVo product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product.mainPic.isNotEmpty
                      ? Image.network(
                          product.mainPic,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _PlaceholderImage(title: product.name),
                        )
                      : _PlaceholderImage(title: product.name),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.spec.isNotEmpty ? product.spec : '规格参数待完善',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '¥${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF09AA43),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            onPressed: () {},
                            icon: Icon(
                              product.isFavorited
                                  ? Icons.star
                                  : Icons.star_border,
                              color: product.isFavorited
                                  ? const Color(0xFF09AA43)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(32, 32),
                            shape: const CircleBorder(),
                            backgroundColor: const Color(0xFF09AA43),
                          ),
                          onPressed: () {},
                          child:
                              const Icon(Icons.add, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEFEFEF),
      child: Center(
        child: Text(
          title.isNotEmpty ? title.characters.first : '图',
          style: const TextStyle(
            fontSize: 28,
            color: Color(0xFFB0B0B0),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

