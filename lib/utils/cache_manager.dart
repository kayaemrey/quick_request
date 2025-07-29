class CacheManager {
  final _cache = <String, dynamic>{};

  T? get<T>(String key) => _cache[key] as T?;
  void set<T>(String key, T value) => _cache[key] = value;
  void remove(String key) => _cache.remove(key);
  void clear() => _cache.clear();
}
