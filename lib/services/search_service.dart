import 'product_repository.dart';

/// 搜索服务，管理搜索历史和搜索建议
class SearchService {
  final ProductRepository _repository;
  final List<String> _history = [];

  SearchService({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();

  /// 获取搜索建议（基于商品 brand 和 title 匹配）
  Future<List<String>> getSuggestions(String query) async {
    if (query.isEmpty) return [];
    final products = await _repository.searchProducts(query);
    return products.map((p) => p.title).toList();
  }

  /// 获取搜索历史
  List<String> getHistory() => List.unmodifiable(_history);

  /// 添加搜索记录（去重，最新的排在前面）
  void addToHistory(String query) {
    if (query.trim().isEmpty) return;
    _history.remove(query);
    _history.insert(0, query);
    if (_history.length > 20) {
      _history.removeLast();
    }
  }

  /// 清除搜索历史
  void clearHistory() {
    _history.clear();
  }
}
