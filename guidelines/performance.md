# Performance Optimization Guide

## Overview

This document outlines comprehensive performance optimization strategies for the application. The goal is to achieve smooth 60fps animations, fast load times, efficient memory usage, and excellent battery life across all supported platforms.

## Performance Goals

### Key Metrics
- **Frame Rate**: Consistent 60fps (16.67ms per frame)
- **Initial Load**: < 3 seconds on 3G connection
- **Time to Interactive**: < 5 seconds
- **First Contentful Paint**: < 1 second
- **Memory Usage**: < 100MB active, < 50MB idle
- **Battery Drain**: < 2% per hour active use
- **Network Usage**: < 1MB per session average
- **Bundle Size**: < 15MB APK, < 30MB IPA

### Performance Budgets
```dart
class PerformanceBudgets {
  // Rendering
  static const Duration frameTime = Duration(microseconds: 16667); // 60fps
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const int maxWidgetDepth = 32;
  
  // Memory
  static const int maxMemoryMB = 100;
  static const int maxCacheSizeMB = 50;
  static const int maxImageCacheMB = 20;
  
  // Network
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxConcurrentRequests = 3;
  static const int maxRetries = 3;
  
  // Bundle
  static const int maxAssetSizeMB = 5;
  static const int maxCodeSizeMB = 10;
}
```

## Rendering Performance

### Widget Optimization

#### Use const Constructors
```dart
// ❌ Bad - Widget rebuilt unnecessarily
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16), // New instance every build
      child: Text('Hello'),
    );
  }
}

// ✅ Good - Widget cached and reused
class MyWidget extends StatelessWidget {
  const MyWidget({super.key}); // const constructor
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), // const instance
      child: const Text('Hello'), // const widget
    );
  }
}
```

#### Split Widget Trees
```dart
// ❌ Bad - Entire tree rebuilds
class ComplexScreen extends StatefulWidget {
  @override
  _ComplexScreenState createState() => _ComplexScreenState();
}

class _ComplexScreenState extends State<ComplexScreen> {
  int counter = 0;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Static content rebuilt unnecessarily
        ExpensiveHeaderWidget(),
        ExpensiveContentWidget(),
        // Only this needs to rebuild
        Text('Counter: $counter'),
        ElevatedButton(
          onPressed: () => setState(() => counter++),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}

// ✅ Good - Only counter rebuilds
class ComplexScreen extends StatelessWidget {
  const ComplexScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ExpensiveHeaderWidget(), // const, never rebuilds
        ExpensiveContentWidget(), // const, never rebuilds
        CounterSection(), // Only this rebuilds
      ],
    );
  }
}

class CounterSection extends StatefulWidget {
  const CounterSection({super.key});
  
  @override
  _CounterSectionState createState() => _CounterSectionState();
}

class _CounterSectionState extends State<CounterSection> {
  int counter = 0;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Counter: $counter'),
        ElevatedButton(
          onPressed: () => setState(() => counter++),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

#### Use Keys Strategically
```dart
// Preserve state in lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ExpensiveWidget(
      key: ValueKey(items[index].id), // Preserve state on reorder
      data: items[index],
    );
  },
);

// Optimize subtree rebuilds
class OptimizedList extends StatelessWidget {
  final List<Item> items;
  
  const OptimizedList({super.key, required this.items});
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return RepaintBoundary( // Isolate repaints
          child: ItemWidget(
            key: ValueKey(items[index].id),
            item: items[index],
          ),
        );
      },
    );
  }
}
```

### Animation Performance

#### Optimize Animations
```dart
class PerformantAnimation extends StatefulWidget {
  @override
  _PerformantAnimationState createState() => _PerformantAnimationState();
}

class _PerformantAnimationState extends State<PerformantAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Use curves for smooth animation
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Use AnimatedBuilder for optimal performance
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child, // Child built once and cached
        );
      },
      child: const ExpensiveWidget(), // Built once
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Use implicit animations when possible
class SimpleAnimation extends StatelessWidget {
  final bool isExpanded;
  
  const SimpleAnimation({super.key, required this.isExpanded});
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      height: isExpanded ? 200 : 100,
      child: const Content(),
    );
  }
}
```

#### Limit Concurrent Animations
```dart
class AnimationOrchestrator {
  static const int maxConcurrentAnimations = 3;
  final _activeAnimations = <AnimationController>[];
  final _queuedAnimations = <VoidCallback>[];
  
  Future<void> runAnimation(AnimationController controller) async {
    if (_activeAnimations.length >= maxConcurrentAnimations) {
      await _waitForSlot();
    }
    
    _activeAnimations.add(controller);
    
    try {
      await controller.forward().orCancel;
    } finally {
      _activeAnimations.remove(controller);
      _processQueue();
    }
  }
  
  Future<void> _waitForSlot() async {
    final completer = Completer<void>();
    _queuedAnimations.add(completer.complete);
    await completer.future;
  }
  
  void _processQueue() {
    if (_queuedAnimations.isNotEmpty && 
        _activeAnimations.length < maxConcurrentAnimations) {
      final next = _queuedAnimations.removeAt(0);
      next();
    }
  }
}
```

## Memory Management

### Image Optimization

#### Efficient Image Loading
```dart
class ImageOptimization {
  // Cache images appropriately
  static void configureImageCache() {
    // Increase cache size for image-heavy apps
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20; // 100MB
    PaintingBinding.instance.imageCache.maximumSize = 100; // 100 images
  }
  
  // Load images efficiently
  static Widget optimizedNetworkImage(String url, {
    required double width,
    required double height,
  }) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      memCacheWidth: (width * window.devicePixelRatio).toInt(),
      memCacheHeight: (height * window.devicePixelRatio).toInt(),
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, url) => const ShimmerPlaceholder(),
      errorWidget: (context, url, error) => const ErrorPlaceholder(),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
  
  // Dispose images when not needed
  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
  
  // Use appropriate image formats
  static String getOptimalImageUrl(String baseUrl, BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final isWiFi = context.read(connectivityProvider).isWiFi;
    
    // Use WebP for better compression
    String format = 'webp';
    
    // Adjust quality based on connection
    int quality = isWiFi ? 90 : 70;
    
    // Get appropriate size
    String size = pixelRatio > 2 ? '3x' : pixelRatio > 1 ? '2x' : '1x';
    
    return '$baseUrl?format=$format&quality=$quality&size=$size';
  }
}

// Lazy load images in lists
class LazyImageList extends StatelessWidget {
  final List<String> imageUrls;
  
  const LazyImageList({super.key, required this.imageUrls});
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return LazyLoadImage(
          url: imageUrls[index],
          visibilityThreshold: 0.5, // Load when 50% visible
        );
      },
    );
  }
}

class LazyLoadImage extends StatefulWidget {
  final String url;
  final double visibilityThreshold;
  
  const LazyLoadImage({
    super.key,
    required this.url,
    this.visibilityThreshold = 0.3,
  });
  
  @override
  _LazyLoadImageState createState() => _LazyLoadImageState();
}

class _LazyLoadImageState extends State<LazyLoadImage> {
  bool _shouldLoad = false;
  
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(widget.url),
      onVisibilityChanged: (info) {
        if (!_shouldLoad && info.visibleFraction >= widget.visibilityThreshold) {
          setState(() => _shouldLoad = true);
        }
      },
      child: _shouldLoad
          ? CachedNetworkImage(imageUrl: widget.url)
          : const SizedBox(height: 200), // Placeholder
    );
  }
}
```

### Memory Leak Prevention
```dart
class MemoryManagement {
  // Dispose controllers properly
  class ProperDisposal extends StatefulWidget {
    @override
    _ProperDisposalState createState() => _ProperDisposalState();
  }
  
  class _ProperDisposalState extends State<ProperDisposal> {
    late final TextEditingController _textController;
    late final ScrollController _scrollController;
    late final AnimationController _animationController;
    late final StreamController<int> _streamController;
    StreamSubscription<int>? _subscription;
    Timer? _timer;
    
    @override
    void initState() {
      super.initState();
      _textController = TextEditingController();
      _scrollController = ScrollController();
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      );
      _streamController = StreamController<int>.broadcast();
      
      // Subscribe with disposal in mind
      _subscription = _streamController.stream.listen((data) {
        // Handle data
      });
      
      // Timer with disposal
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          // Only update if widget is still mounted
          setState(() {});
        }
      });
    }
    
    @override
    void dispose() {
      // Dispose in reverse order of initialization
      _timer?.cancel();
      _subscription?.cancel();
      _streamController.close();
      _animationController.dispose();
      _scrollController.dispose();
      _textController.dispose();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return Container();
    }
  }
  
  // Use weak references for callbacks
  static void avoidMemoryLeaksWithCallbacks() {
    class CallbackHandler {
      WeakReference<State>? _stateRef;
      
      void setCallback(State state) {
        _stateRef = WeakReference(state);
      }
      
      void executeCallback() {
        final state = _stateRef?.target;
        if (state != null && state.mounted) {
          // Safe to use state
        }
      }
    }
  }
  
  // Clear caches periodically
  static void setupCacheCleaning() {
    Timer.periodic(const Duration(minutes: 30), (timer) {
      // Clear old cache entries
      if (PaintingBinding.instance.imageCache.currentSizeBytes > 50 << 20) {
        PaintingBinding.instance.imageCache.evict();
      }
    });
  }
}
```

## Network Performance

### API Optimization

#### Efficient Data Fetching
```dart
class NetworkOptimization {
  // Implement request batching
  class RequestBatcher {
    final Duration batchWindow = const Duration(milliseconds: 100);
    final int maxBatchSize = 10;
    
    final _pendingRequests = <String, Completer<dynamic>>{};
    Timer? _batchTimer;
    
    Future<T> addRequest<T>(String endpoint, Map<String, dynamic> params) {
      final completer = Completer<T>();
      final key = '$endpoint:${jsonEncode(params)}';
      
      _pendingRequests[key] = completer;
      
      // Start batch timer if not running
      _batchTimer ??= Timer(batchWindow, _executeBatch);
      
      // Execute immediately if batch is full
      if (_pendingRequests.length >= maxBatchSize) {
        _executeBatch();
      }
      
      return completer.future;
    }
    
    void _executeBatch() async {
      _batchTimer?.cancel();
      _batchTimer = null;
      
      if (_pendingRequests.isEmpty) return;
      
      // Create batch request
      final batch = _pendingRequests.keys.map((key) {
        final parts = key.split(':');
        return {
          'endpoint': parts[0],
          'params': jsonDecode(parts[1]),
        };
      }).toList();
      
      try {
        // Send batch request
        final responses = await _api.batch(batch);
        
        // Resolve completers
        var index = 0;
        _pendingRequests.forEach((key, completer) {
          completer.complete(responses[index++]);
        });
      } catch (e) {
        // Reject all completers
        _pendingRequests.forEach((key, completer) {
          completer.completeError(e);
        });
      } finally {
        _pendingRequests.clear();
      }
    }
  }
  
  // Implement response caching
  class ResponseCache {
    final _cache = <String, CachedResponse>{};
    final Duration defaultTTL = const Duration(minutes: 5);
    
    Future<T> getOrFetch<T>(
      String key,
      Future<T> Function() fetcher, {
      Duration? ttl,
    }) async {
      // Check cache
      final cached = _cache[key];
      if (cached != null && !cached.isExpired) {
        return cached.data as T;
      }
      
      // Fetch new data
      final data = await fetcher();
      
      // Store in cache
      _cache[key] = CachedResponse(
        data: data,
        expiry: DateTime.now().add(ttl ?? defaultTTL),
      );
      
      return data;
    }
    
    void invalidate(String key) {
      _cache.remove(key);
    }
    
    void invalidatePattern(String pattern) {
      _cache.removeWhere((key, value) => key.contains(pattern));
    }
    
    void clear() {
      _cache.clear();
    }
  }
  
  // Implement pagination
  class PaginatedLoader<T> {
    final int pageSize;
    final Future<List<T>> Function(int page, int size) fetcher;
    
    final _items = <T>[];
    int _currentPage = 0;
    bool _hasMore = true;
    bool _isLoading = false;
    
    PaginatedLoader({
      this.pageSize = 20,
      required this.fetcher,
    });
    
    List<T> get items => List.unmodifiable(_items);
    bool get hasMore => _hasMore;
    bool get isLoading => _isLoading;
    
    Future<void> loadMore() async {
      if (_isLoading || !_hasMore) return;
      
      _isLoading = true;
      
      try {
        final newItems = await fetcher(_currentPage, pageSize);
        
        if (newItems.length < pageSize) {
          _hasMore = false;
        }
        
        _items.addAll(newItems);
        _currentPage++;
      } finally {
        _isLoading = false;
      }
    }
    
    Future<void> refresh() async {
      _items.clear();
      _currentPage = 0;
      _hasMore = true;
      await loadMore();
    }
  }
}

// Implement compression
class CompressionMiddleware extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Compress request body if large
    if (options.data != null && options.data.toString().length > 1024) {
      options.headers['Content-Encoding'] = 'gzip';
      options.data = gzip.encode(utf8.encode(jsonEncode(options.data)));
    }
    
    // Request compressed responses
    options.headers['Accept-Encoding'] = 'gzip, deflate';
    
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Decompress if needed
    if (response.headers.value('content-encoding') == 'gzip') {
      response.data = utf8.decode(gzip.decode(response.data));
    }
    
    handler.next(response);
  }
}
```

### Connection Management
```dart
class ConnectionOptimization {
  // Implement connection pooling
  static Dio createOptimizedClient() {
    final dio = Dio();
    
    // Configure connection pool
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.maxConnectionsPerHost = 6;
      client.idleTimeout = const Duration(seconds: 15);
      client.connectionTimeout = const Duration(seconds: 30);
      return client;
    };
    
    // Add retry logic
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 4),
        ],
      ),
    );
    
    // Add timeout
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    
    return dio;
  }
  
  // Implement offline queue
  class OfflineQueue {
    final _queue = <QueuedRequest>[];
    final _localStorage = LocalStorage('offline_queue');
    StreamSubscription? _connectivitySubscription;
    
    void init() {
      // Load persisted queue
      _loadQueue();
      
      // Monitor connectivity
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
        if (result != ConnectivityResult.none) {
          _processQueue();
        }
      });
    }
    
    Future<void> enqueue(QueuedRequest request) async {
      _queue.add(request);
      await _saveQueue();
      
      // Try to process immediately
      if (await _isOnline()) {
        _processQueue();
      }
    }
    
    void _processQueue() async {
      while (_queue.isNotEmpty && await _isOnline()) {
        final request = _queue.first;
        
        try {
          await request.execute();
          _queue.removeAt(0);
          await _saveQueue();
        } catch (e) {
          // Network error, stop processing
          break;
        }
      }
    }
    
    Future<bool> _isOnline() async {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    }
    
    void _loadQueue() {
      final saved = _localStorage.getItem('queue');
      if (saved != null) {
        _queue.addAll(
          (saved as List).map((e) => QueuedRequest.fromJson(e)),
        );
      }
    }
    
    Future<void> _saveQueue() async {
      await _localStorage.setItem(
        'queue',
        _queue.map((e) => e.toJson()).toList(),
      );
    }
    
    void dispose() {
      _connectivitySubscription?.cancel();
    }
  }
}
```

## Build Optimization

### Code Splitting
```dart
// Use deferred loading for features
import 'package:{{PROJECT_NAME}}/features/projections/projections.dart' deferred as projections;
import 'package:{{PROJECT_NAME}}/features/reports/reports.dart' deferred as reports;

class FeatureLoader {
  static Future<void> loadProjections() async {
    await projections.loadLibrary();
  }
  
  static Future<void> loadReports() async {
    await reports.loadLibrary();
  }
  
  // Load feature when needed
  static Future<Widget> getProjectionsScreen() async {
    await loadProjections();
    return projections.ProjectionsScreen();
  }
}

// Route configuration with lazy loading
final routes = {
  '/': (context) => const HomeScreen(),
  '/projections': (context) => FutureBuilder<Widget>(
    future: FeatureLoader.getProjectionsScreen(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return snapshot.data!;
      }
      return const LoadingScreen();
    },
  ),
};
```

### Tree Shaking
```dart
// Use conditional imports for platform-specific code
import 'platform_service_stub.dart'
    if (dart.library.io) 'platform_service_mobile.dart'
    if (dart.library.html) 'platform_service_web.dart';

// Remove unused code with tree shaking
class OptimizedImports {
  // ❌ Bad - Imports entire library
  import 'package:rxdart/rxdart.dart';
  
  // ✅ Good - Import only what's needed
  import 'package:rxdart/subjects.dart' show BehaviorSubject;
  import 'package:rxdart/transformers.dart' show DebounceExtensions;
}

// Use --split-debug-info for smaller release builds
// flutter build apk --release --split-debug-info=debug_info/
// flutter build ios --release --split-debug-info=debug_info/
```

### Asset Optimization
```yaml
# pubspec.yaml
flutter:
  assets:
    # Use asset variants for different resolutions
    - assets/images/
    - assets/images/2.0x/
    - assets/images/3.0x/
    
  # Optimize fonts
  fonts:
    - family: CustomFont
      fonts:
        - asset: fonts/CustomFont-Regular.ttf
          weight: 400
        - asset: fonts/CustomFont-Bold.ttf
          weight: 700
  
  # Enable asset compression
  uses-material-design: true
```

```dart
// Optimize asset loading
class AssetOptimization {
  // Preload critical assets
  static Future<void> preloadAssets(BuildContext context) async {
    // Preload images
    await Future.wait([
      precacheImage(const AssetImage('assets/images/logo.png'), context),
      precacheImage(const AssetImage('assets/images/splash.png'), context),
    ]);
    
    // Preload SVGs
    await Future.wait([
      precachePicture(
        ExactAssetPicture(
          SvgPicture.svgStringDecoderBuilder,
          'assets/icons/home.svg',
        ),
        context,
      ),
    ]);
  }
  
  // Use appropriate image formats
  static Widget optimizedAssetImage(String asset) {
    // Use WebP for better compression
    final webpAsset = asset.replaceAll('.png', '.webp');
    
    return Image.asset(
      webpAsset,
      errorBuilder: (context, error, stack) {
        // Fallback to PNG if WebP not supported
        return Image.asset(asset);
      },
    );
  }
}
```

## Database Performance

### Query Optimization
```dart
class DatabaseOptimization {
  // Use indexes for frequently queried fields
  static const String createIndexes = '''
    CREATE INDEX idx_projects_user_id ON projects(user_id);
    CREATE INDEX idx_assets_project_id ON assets(project_id);
    CREATE INDEX idx_events_date ON events(event_date);
    CREATE INDEX idx_projections_scenario ON projections(scenario_id, year);
  ''';
  
  // Batch operations for better performance
  Future<void> batchInsert(List<Asset> assets) async {
    final batch = db.batch();
    
    for (final asset in assets) {
      batch.insert('assets', asset.toMap());
    }
    
    await batch.commit(noResult: true);
  }
  
  // Use transactions for consistency and performance
  Future<void> updateProjectWithAssets(
    Project project,
    List<Asset> assets,
  ) async {
    await db.transaction((txn) async {
      // Update project
      await txn.update(
        'projects',
        project.toMap(),
        where: 'id = ?',
        whereArgs: [project.id],
      );
      
      // Delete old assets
      await txn.delete(
        'assets',
        where: 'project_id = ?',
        whereArgs: [project.id],
      );
      
      // Insert new assets
      final batch = txn.batch();
      for (final asset in assets) {
        batch.insert('assets', asset.toMap());
      }
      await batch.commit();
    });
  }
  
  // Optimize queries with proper WHERE clauses
  Future<List<Asset>> getAssetsByType(String projectId, AssetType type) async {
    // ✅ Good - Uses index and limits results
    return db.query(
      'assets',
      where: 'project_id = ? AND asset_type = ?',
      whereArgs: [projectId, type.toString()],
      orderBy: 'created_at DESC',
      limit: 100,
    );
    
    // ❌ Bad - Fetches all then filters
    // final all = await db.query('assets');
    // return all.where((a) => a['project_id'] == projectId && a['asset_type'] == type.toString()).toList();
  }
  
  // Use pagination for large datasets
  Future<List<Transaction>> getTransactionsPaginated(
    int page,
    int pageSize,
  ) async {
    final offset = page * pageSize;
    
    return db.query(
      'transactions',
      orderBy: 'created_at DESC',
      limit: pageSize,
      offset: offset,
    );
  }
}

// Firestore optimization
class FirestoreOptimization {
  // Use composite indexes
  static const firestoreIndexes = '''
    {
      "indexes": [
        {
          "collectionGroup": "assets",
          "queryScope": "COLLECTION",
          "fields": [
            {"fieldPath": "projectId", "order": "ASCENDING"},
            {"fieldPath": "assetType", "order": "ASCENDING"},
            {"fieldPath": "createdAt", "order": "DESCENDING"}
          ]
        }
      ]
    }
  ''';
  
  // Implement field masks to reduce data transfer
  Future<Project> getProjectBasicInfo(String projectId) async {
    final doc = await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .get(const GetOptions(
          source: Source.cache, // Try cache first
        ));
    
    // Only fetch needed fields
    return Project(
      id: doc.id,
      name: doc.data()?['name'] ?? '',
      createdAt: doc.data()?['createdAt']?.toDate() ?? DateTime.now(),
    );
  }
  
  // Use batched writes
  Future<void> batchUpdateAssets(List<Asset> assets) async {
    final batch = FirebaseFirestore.instance.batch();
    
    for (final asset in assets) {
      final ref = FirebaseFirestore.instance
          .collection('assets')
          .doc(asset.id);
      
      batch.update(ref, asset.toMap());
    }
    
    await batch.commit();
  }
  
  // Implement offline persistence
  static Future<void> enableOffline() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 100 * 1024 * 1024, // 100MB
    );
  }
}
```

## Startup Performance

### App Initialization
```dart
// Optimize main.dart
void main() async {
  // Start performance monitoring immediately
  final startTime = DateTime.now();
  
  // Essential initialization only
  WidgetsFlutterBinding.ensureInitialized();
  
  // Run app with minimal setup
  runApp(const SplashApp());
  
  // Initialize in background
  unawaited(_initializeApp(startTime));
}

// Minimal splash screen
class SplashApp extends StatelessWidget {
  const SplashApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}

// Background initialization
Future<void> _initializeApp(DateTime startTime) async {
  // Initialize in priority order
  await Future.wait([
    _initializeEssentials(),
    _preloadAssets(),
  ]);
  
  // Initialize non-critical services
  unawaited(_initializeSecondary());
  
  // Log startup time
  final duration = DateTime.now().difference(startTime);
  analytics.logEvent('app_startup', {'duration_ms': duration.inMilliseconds});
  
  // Navigate to main app
  runApp(const MainApp());
}

Future<void> _initializeEssentials() async {
  // Only critical initialization
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}

Future<void> _initializeSecondary() async {
  // Non-critical services
  await Future.wait([
    NotificationService.initialize(),
    AnalyticsService.initialize(),
    CrashReporting.initialize(),
  ]);
}
```

### Lazy Loading
```dart
// Lazy initialize heavy services
class ServiceLocator {
  static final _services = <Type, dynamic>{};
  
  static T get<T>() {
    if (!_services.containsKey(T)) {
      _services[T] = _createService<T>();
    }
    return _services[T] as T;
  }
  
  static dynamic _createService<T>() {
    switch (T) {
      case ProjectionCalculator:
        return ProjectionCalculator();
      case ReportGenerator:
        return ReportGenerator();
      case ChartingService:
        return ChartingService();
      default:
        throw Exception('Service not found');
    }
  }
  
  // Preload service in background
  static Future<void> preload<T>() async {
    await Future.microtask(() => get<T>());
  }
}

// Lazy load heavy widgets
class LazyWidget extends StatefulWidget {
  final Widget Function() builder;
  final Widget placeholder;
  
  const LazyWidget({
    super.key,
    required this.builder,
    this.placeholder = const CircularProgressIndicator(),
  });
  
  @override
  _LazyWidgetState createState() => _LazyWidgetState();
}

class _LazyWidgetState extends State<LazyWidget> {
  Widget? _widget;
  
  @override
  void initState() {
    super.initState();
    // Load widget in next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _widget = widget.builder();
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return _widget ?? widget.placeholder;
  }
}
```

## Performance Monitoring

### Runtime Monitoring
```dart
class PerformanceMonitor {
  static final _frameCallbacks = <FrameCallback>[];
  static var _isMonitoring = false;
  
  static void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    
    // Monitor frame rendering
    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
      final renderTime = WidgetsBinding.instance.window.onReportTimings;
      // Log if frame takes too long
    });
    
    // Monitor memory
    Timer.periodic(const Duration(minutes: 1), (_) {
      final info = ProcessInfo.currentRss;
      if (info > 100 * 1024 * 1024) {
        // Log high memory usage
        analytics.logEvent('high_memory_usage', {'bytes': info});
      }
    });
  }
  
  // Track specific operations
  static Future<T> trackOperation<T>(
    String name,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await operation();
      stopwatch.stop();
      
      // Log performance
      analytics.logEvent('operation_performance', {
        'name': name,
        'duration_ms': stopwatch.elapsedMilliseconds,
        'success': true,
      });
      
      return result;
    } catch (e) {
      stopwatch.stop();
      
      analytics.logEvent('operation_performance', {
        'name': name,
        'duration_ms': stopwatch.elapsedMilliseconds,
        'success': false,
        'error': e.toString(),
      });
      
      rethrow;
    }
  }
  
  // Custom timeline events
  static void beginTimelineTask(String name) {
    Timeline.startSync(name);
  }
  
  static void endTimelineTask() {
    Timeline.finishSync();
  }
  
  // Performance reporting
  static void reportMetrics() {
    final metrics = {
      'frame_rate': SchedulerBinding.instance.currentFrameTimeStamp,
      'memory_usage': ProcessInfo.currentRss,
      'cache_size': PaintingBinding.instance.imageCache.currentSizeBytes,
    };
    
    analytics.logEvent('performance_metrics', metrics);
  }
}

// Widget performance tracking
class PerformanceTrackingWidget extends StatefulWidget {
  final Widget child;
  final String name;
  
  const PerformanceTrackingWidget({
    super.key,
    required this.child,
    required this.name,
  });
  
  @override
  _PerformanceTrackingWidgetState createState() => _PerformanceTrackingWidgetState();
}

class _PerformanceTrackingWidgetState extends State<PerformanceTrackingWidget> {
  late Stopwatch _buildStopwatch;
  
  @override
  void initState() {
    super.initState();
    _buildStopwatch = Stopwatch();
  }
  
  @override
  Widget build(BuildContext context) {
    _buildStopwatch.reset();
    _buildStopwatch.start();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildStopwatch.stop();
      
      if (_buildStopwatch.elapsedMilliseconds > 16) {
        // Log slow build
        debugPrint('Slow build: ${widget.name} took ${_buildStopwatch.elapsedMilliseconds}ms');
      }
    });
    
    return widget.child;
  }
}
```

## Platform-Specific Optimizations

### iOS Optimization
```dart
// iOS-specific optimizations
class IOSOptimization {
  static void configure() {
    if (!Platform.isIOS) return;
    
    // Disable implicit animations for better performance
    CupertinoRouteTransitionMixin.isPopGestureEnabled = false;
    
    // Use iOS-specific caching
    NSURLCache.setSharedURLCache(
      memoryCacheSize: 50 * 1024 * 1024, // 50MB
      diskCacheSize: 100 * 1024 * 1024, // 100MB
    );
    
    // Enable Metal renderer for better performance
    IOSViewController.forceSoftwareRendering = false;
  }
}
```

### Android Optimization
```dart
// Android-specific optimizations
class AndroidOptimization {
  static void configure() {
    if (!Platform.isAndroid) return;
    
    // Enable hardware acceleration
    AndroidViewController.setRenderMode(
      AndroidViewRenderMode.texture,
    );
    
    // Configure memory
    SystemChannels.platform.invokeMethod('SystemChrome.setApplicationSwitcherDescription', {
      'label': 'Retirement Planner',
      'primaryColor': 0xFF2196F3,
    });
    
    // Enable R8/ProGuard
    // In android/app/build.gradle:
    // minifyEnabled true
    // shrinkResources true
    // proguardFiles getDefaultProguardFile('proguard-android-optimize.txt')
  }
}
```

### Web Optimization
```dart
// Web-specific optimizations
class WebOptimization {
  static void configure() {
    if (!kIsWeb) return;
    
    // Use CanvasKit for better performance
    // flutter build web --web-renderer canvaskit
    
    // Enable PWA features
    // In web/manifest.json and index.html
    
    // Optimize for web
    WebViewController.platform = WebWebViewPlatform();
    
    // Lazy load images
    document.querySelectorAll('img').forEach((img) {
      img.loading = 'lazy';
    });
  }
}
```

## Performance Checklist

### Development
- [ ] Use const constructors everywhere possible
- [ ] Split large widgets into smaller ones
- [ ] Implement shouldRebuild for custom painters
- [ ] Use RepaintBoundary for complex widgets
- [ ] Dispose all controllers and subscriptions
- [ ] Avoid setState in frequently called methods
- [ ] Use keys appropriately in lists

### Images
- [ ] Resize images to display size
- [ ] Use appropriate formats (WebP preferred)
- [ ] Implement lazy loading for images
- [ ] Cache network images
- [ ] Clear image cache periodically
- [ ] Use placeholder images

### Network
- [ ] Implement request caching
- [ ] Use pagination for large datasets
- [ ] Compress request/response data
- [ ] Batch API requests
- [ ] Implement offline queue
- [ ] Set appropriate timeouts

### Database
- [ ] Create indexes for queried fields
- [ ] Use transactions for multiple operations
- [ ] Implement query pagination
- [ ] Cache frequently accessed data
- [ ] Use batch operations
- [ ] Optimize Firestore queries

### Build
- [ ] Enable tree shaking
- [ ] Use deferred loading
- [ ] Split debug symbols
- [ ] Optimize assets
- [ ] Minify code
- [ ] Remove unused dependencies

### Monitoring
- [ ] Track frame rendering time
- [ ] Monitor memory usage
- [ ] Log slow operations
- [ ] Set up crash reporting
- [ ] Track app startup time
- [ ] Monitor network performance

---

*Version: 1.0*
*Last Updated: November 2024*
*Performance Review: Monthly*
