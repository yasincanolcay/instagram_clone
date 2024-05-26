import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class GlobalClass {
  static final customCacheManager = CacheManager(
    Config(
      'instacache',
      stalePeriod: const Duration(days: 15),
      maxNrOfCacheObjects: 100,
    ),
  );
}
