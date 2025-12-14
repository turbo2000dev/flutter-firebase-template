# State Management with Riverpod 3.0

## Overview

This document outlines the state management strategy using Riverpod 3.0 with code generation. The architecture emphasizes type safety, testability, and reactive programming patterns while maintaining clear separation between UI and business logic.

## Core Concepts

### Provider Types

#### 1. Provider - Read-Only Computed State
```dart
// Simple value provider
@riverpod
String apiUrl(ApiUrlRef ref) {
  final env = ref.watch(environmentProvider);
  return env == Environment.prod 
    ? 'https://api.prod.example.com'
    : 'https://api.dev.example.com';
}

// Computed provider depending on other providers
@riverpod
double netWorth(NetWorthRef ref) {
  final assets = ref.watch(totalAssetsProvider);
  final liabilities = ref.watch(totalLiabilitiesProvider);
  return assets - liabilities;
}

// Provider with dependencies
@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return UserRepositoryImpl(dio);
}
```

#### 2. FutureProvider - Asynchronous Data
```dart
// Simple async fetch
@riverpod
Future<User> userProfile(UserProfileRef ref, String userId) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUser(userId);
}

// With error handling and caching
@riverpod
Future<List<Project>> userProjects(UserProjectsRef ref) async {
  // Auto-dispose after 5 minutes of inactivity
  ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());
  
  try {
    final user = ref.watch(currentUserProvider);
    if (user == null) throw UnauthorizedException();
    
    final repository = ref.watch(projectRepositoryProvider);
    return await repository.getProjects(user.id);
  } catch (e, stack) {
    // Log error
    ref.read(loggerProvider).error('Failed to fetch projects', e, stack);
    rethrow;
  }
}
```

#### 3. StreamProvider - Real-time Data
```dart
// Firestore stream
@riverpod
Stream<List<Asset>> assetsStream(AssetsStreamRef ref, String projectId) {
  final repository = ref.watch(assetRepositoryProvider);
  if (repository == null) return Stream.value([]);
  
  return repository.watchAssets(projectId);
}

// Combining multiple streams
@riverpod
Stream<ProjectionData> projectionStream(
  ProjectionStreamRef ref,
  String projectId,
  String scenarioId,
) {
  final assetsStream = ref.watch(assetsStreamProvider(projectId));
  final eventsStream = ref.watch(eventsStreamProvider(projectId));
  final scenarioStream = ref.watch(scenarioStreamProvider(scenarioId));
  
  return Rx.combineLatest3(
    assetsStream,
    eventsStream,
    scenarioStream,
    (assets, events, scenario) => ProjectionData(
      assets: assets,
      events: events,
      scenario: scenario,
    ),
  );
}
```

#### 4. NotifierProvider - Synchronous State Management
```dart
// Simple counter example
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;
  
  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

// Complex state with Freezed
@riverpod
class ProjectForm extends _$ProjectForm {
  @override
  ProjectFormState build() {
    return const ProjectFormState(
      name: '',
      description: '',
      individuals: [],
      currency: Currency.cad,
      startDate: null,
      errors: {},
    );
  }
  
  void updateName(String name) {
    state = state.copyWith(
      name: name,
      errors: {...state.errors}..remove('name'),
    );
    _validateName();
  }
  
  void addIndividual(Individual individual) {
    state = state.copyWith(
      individuals: [...state.individuals, individual],
    );
  }
  
  void removeIndividual(String individualId) {
    state = state.copyWith(
      individuals: state.individuals
          .where((i) => i.id != individualId)
          .toList(),
    );
  }
  
  Future<void> submit() async {
    if (!_validate()) return;
    
    state = state.copyWith(isSubmitting: true);
    
    try {
      final repository = ref.read(projectRepositoryProvider);
      await repository.createProject(state.toProject());
      
      // Navigate on success
      ref.read(routerProvider).go('/projects');
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errors: {'general': e.toString()},
      );
    }
  }
  
  bool _validate() {
    final errors = <String, String>{};
    
    if (state.name.isEmpty) {
      errors['name'] = 'Project name is required';
    }
    
    if (state.individuals.isEmpty) {
      errors['individuals'] = 'At least one individual is required';
    }
    
    state = state.copyWith(errors: errors);
    return errors.isEmpty;
  }
  
  void _validateName() {
    if (state.name.length < 3) {
      state = state.copyWith(
        errors: {...state.errors, 'name': 'Name too short'},
      );
    }
  }
}
```

#### 5. AsyncNotifierProvider - Asynchronous State Management
```dart
// Data fetching with state management
@riverpod
class ProjectDetails extends _$ProjectDetails {
  @override
  Future<Project> build(String projectId) async {
    final repository = ref.watch(projectRepositoryProvider);
    return repository.getProject(projectId);
  }
  
  Future<void> updateProject(Project project) async {
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      final repository = ref.read(projectRepositoryProvider);
      await repository.updateProject(project);
      return project;
    });
  }
  
  Future<void> deleteProject() async {
    final project = state.valueOrNull;
    if (project == null) return;
    
    state = const AsyncLoading();
    
    try {
      final repository = ref.read(projectRepositoryProvider);
      await repository.deleteProject(project.id);
      
      // Navigate after successful deletion
      ref.read(routerProvider).go('/projects');
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

// Paginated data loading
@riverpod
class ProjectList extends _$ProjectList {
  static const _pageSize = 20;
  
  @override
  Future<List<Project>> build() async {
    return _fetchProjects();
  }
  
  Future<List<Project>> _fetchProjects({String? lastId}) async {
    final repository = ref.watch(projectRepositoryProvider);
    return repository.getProjects(
      limit: _pageSize,
      startAfter: lastId,
    );
  }
  
  Future<void> loadMore() async {
    final currentProjects = state.valueOrNull ?? [];
    if (currentProjects.isEmpty) return;
    
    final lastId = currentProjects.last.id;
    final moreProjects = await _fetchProjects(lastId: lastId);
    
    state = AsyncData([...currentProjects, ...moreProjects]);
  }
  
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchProjects());
  }
  
  void removeProject(String projectId) {
    final projects = state.valueOrNull;
    if (projects == null) return;
    
    state = AsyncData(
      projects.where((p) => p.id != projectId).toList(),
    );
  }
}
```

## State Organization

### Feature-Based Structure
```dart
// features/auth/application/providers/auth_provider.dart

@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() {
    // Watch auth state changes
    ref.listen(authStateChangesProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            state = AuthState.authenticated(user);
          } else {
            state = const AuthState.unauthenticated();
          }
        },
        loading: () => state = const AuthState.loading(),
        error: (e, s) => state = AuthState.error(e.toString()),
      );
    });
    
    return const AuthState.initial();
  }
  
  Future<void> signIn(String email, String password) async {
    state = const AuthState.loading();
    
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signIn(email, password);
      state = AuthState.authenticated(user);
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
    }
  }
  
  Future<void> signOut() async {
    state = const AuthState.loading();
    
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      state = const AuthState.unauthenticated();
      
      // Clear all user data
      ref.invalidate(userProjectsProvider);
      ref.invalidate(userSettingsProvider);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}

// Auth state definition
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}
```

### Provider Scoping
```dart
// Project-scoped providers
@riverpod
Project? currentProject(CurrentProjectRef ref) {
  final projectId = ref.watch(selectedProjectIdProvider);
  if (projectId == null) return null;
  
  final projectAsync = ref.watch(projectDetailsProvider(projectId));
  return projectAsync.valueOrNull;
}

@riverpod
AssetRepository? assetRepository(AssetRepositoryRef ref) {
  final project = ref.watch(currentProjectProvider);
  if (project == null) return null;
  
  final firestore = ref.watch(firestoreProvider);
  return AssetRepositoryImpl(firestore, project.id);
}

// Family providers for parameterized state
@riverpod
class ScenarioController extends _$ScenarioController {
  @override
  Future<Scenario> build(String projectId, String scenarioId) async {
    final repository = ref.watch(scenarioRepositoryProvider(projectId));
    return repository.getScenario(scenarioId);
  }
  
  Future<void> updateParameter(String key, dynamic value) async {
    final scenario = state.valueOrNull;
    if (scenario == null) return;
    
    final updated = scenario.copyWith(
      parameters: {...scenario.parameters, key: value},
    );
    
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(scenarioRepositoryProvider(arg.projectId));
      await repository.updateScenario(updated);
      return updated;
    });
  }
}
```

## State Patterns

### Loading States
```dart
// Consistent loading pattern
class ProjectScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailsProvider(projectId));
    
    return projectAsync.when(
      data: (project) => ProjectView(project: project),
      loading: () => const LoadingScaffold(),
      error: (error, stack) => ErrorView(
        error: error,
        onRetry: () => ref.refresh(projectDetailsProvider(projectId)),
      ),
    );
  }
}

// Multiple async states
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(userProjectsProvider);
    final statsAsync = ref.watch(userStatsProvider);
    
    // Wait for all data
    if (projectsAsync.isLoading || statsAsync.isLoading) {
      return const LoadingScaffold();
    }
    
    // Handle any errors
    if (projectsAsync.hasError) {
      return ErrorView(error: projectsAsync.error!);
    }
    if (statsAsync.hasError) {
      return ErrorView(error: statsAsync.error!);
    }
    
    // All data loaded
    final projects = projectsAsync.requireValue;
    final stats = statsAsync.requireValue;
    
    return DashboardView(
      projects: projects,
      stats: stats,
    );
  }
}
```

### Form State Management
```dart
@riverpod
class AssetFormController extends _$AssetFormController {
  @override
  AssetFormState build() {
    return AssetFormState(
      assetType: AssetType.rrsp,
      fields: {},
      errors: {},
      isSubmitting: false,
    );
  }
  
  void setAssetType(AssetType type) {
    state = state.copyWith(
      assetType: type,
      fields: {}, // Reset fields when type changes
      errors: {},
    );
  }
  
  void updateField(String key, dynamic value) {
    state = state.copyWith(
      fields: {...state.fields, key: value},
      errors: {...state.errors}..remove(key),
    );
    
    // Validate field
    _validateField(key, value);
  }
  
  void _validateField(String key, dynamic value) {
    String? error;
    
    switch (key) {
      case 'balance':
        final balance = value as double?;
        if (balance == null || balance < 0) {
          error = 'Balance must be positive';
        }
        break;
      case 'contributionRoom':
        final room = value as double?;
        if (room == null || room < 0) {
          error = 'Contribution room must be positive';
        }
        break;
    }
    
    if (error != null) {
      state = state.copyWith(
        errors: {...state.errors, key: error},
      );
    }
  }
  
  Future<void> submit() async {
    if (!_validateAll()) return;
    
    state = state.copyWith(isSubmitting: true);
    
    try {
      final asset = _createAsset();
      final repository = ref.read(assetRepositoryProvider);
      
      if (repository == null) {
        throw Exception('No project selected');
      }
      
      await repository.createAsset(asset);
      
      // Clear form and navigate
      ref.invalidateSelf();
      ref.read(routerProvider).pop();
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errors: {'general': e.toString()},
      );
    }
  }
  
  bool _validateAll() {
    final errors = <String, String>{};
    
    // Validate required fields based on asset type
    switch (state.assetType) {
      case AssetType.rrsp:
        if (state.fields['accountHolder'] == null) {
          errors['accountHolder'] = 'Account holder is required';
        }
        if (state.fields['balance'] == null) {
          errors['balance'] = 'Balance is required';
        }
        break;
      case AssetType.realEstate:
        if (state.fields['propertyType'] == null) {
          errors['propertyType'] = 'Property type is required';
        }
        if (state.fields['currentValue'] == null) {
          errors['currentValue'] = 'Current value is required';
        }
        break;
      // ... other asset types
    }
    
    state = state.copyWith(errors: errors);
    return errors.isEmpty;
  }
  
  Asset _createAsset() {
    return Asset(
      id: const Uuid().v4(),
      type: state.assetType,
      data: state.fields,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

@freezed
class AssetFormState with _$AssetFormState {
  const factory AssetFormState({
    required AssetType assetType,
    required Map<String, dynamic> fields,
    required Map<String, String> errors,
    required bool isSubmitting,
  }) = _AssetFormState;
}
```

### Optimistic Updates
```dart
@riverpod
class TodoListController extends _$TodoListController {
  @override
  Future<List<Todo>> build() async {
    final repository = ref.watch(todoRepositoryProvider);
    return repository.getTodos();
  }
  
  Future<void> addTodo(String title) async {
    // Optimistic update
    final newTodo = Todo(
      id: const Uuid().v4(),
      title: title,
      completed: false,
      createdAt: DateTime.now(),
    );
    
    state = AsyncData([...?state.valueOrNull, newTodo]);
    
    // Actual update
    try {
      final repository = ref.read(todoRepositoryProvider);
      await repository.createTodo(newTodo);
    } catch (e) {
      // Rollback on error
      state = AsyncData(
        state.valueOrNull?.where((t) => t.id != newTodo.id).toList() ?? [],
      );
      
      // Show error
      ref.read(snackbarControllerProvider).showError(
        'Failed to add todo: $e',
      );
    }
  }
  
  Future<void> toggleTodo(String todoId) async {
    final todos = state.valueOrNull;
    if (todos == null) return;
    
    // Find and update todo optimistically
    final index = todos.indexWhere((t) => t.id == todoId);
    if (index == -1) return;
    
    final todo = todos[index];
    final updated = todo.copyWith(completed: !todo.completed);
    
    state = AsyncData([
      ...todos.sublist(0, index),
      updated,
      ...todos.sublist(index + 1),
    ]);
    
    // Actual update
    try {
      final repository = ref.read(todoRepositoryProvider);
      await repository.updateTodo(updated);
    } catch (e) {
      // Rollback
      state = AsyncData(todos);
      
      ref.read(snackbarControllerProvider).showError(
        'Failed to update todo: $e',
      );
    }
  }
}
```

### Caching Strategies
```dart
// Time-based cache invalidation
@riverpod
Future<MarketData> marketData(MarketDataRef ref) async {
  // Cache for 5 minutes
  ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());
  
  final api = ref.watch(marketApiProvider);
  return api.fetchMarketData();
}

// Manual cache management
@riverpod
class CachedDataController extends _$CachedDataController {
  Timer? _cacheTimer;
  
  @override
  Future<Data> build() async {
    ref.onDispose(() {
      _cacheTimer?.cancel();
    });
    
    return _fetchData();
  }
  
  Future<Data> _fetchData() async {
    // Cancel existing timer
    _cacheTimer?.cancel();
    
    // Set new cache expiration
    _cacheTimer = Timer(const Duration(minutes: 10), () {
      ref.invalidateSelf();
    });
    
    final repository = ref.watch(dataRepositoryProvider);
    return repository.getData();
  }
  
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchData());
  }
  
  void clearCache() {
    _cacheTimer?.cancel();
    ref.invalidateSelf();
  }
}
```

## Testing State

### Unit Testing Providers
```dart
void main() {
  group('AuthController', () {
    test('should sign in user successfully', () async {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(MockAuthService()),
        ],
      );
      
      final mockAuthService = container.read(authServiceProvider) as MockAuthService;
      when(() => mockAuthService.signIn(any(), any()))
          .thenAnswer((_) async => testUser);
      
      final controller = container.read(authControllerProvider.notifier);
      await controller.signIn('test@example.com', 'password');
      
      final state = container.read(authControllerProvider);
      expect(state, AuthState.authenticated(testUser));
    });
    
    test('should handle sign in error', () async {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(MockAuthService()),
        ],
      );
      
      final mockAuthService = container.read(authServiceProvider) as MockAuthService;
      when(() => mockAuthService.signIn(any(), any()))
          .thenThrow(AuthException('Invalid credentials'));
      
      final controller = container.read(authControllerProvider.notifier);
      await controller.signIn('test@example.com', 'wrong');
      
      final state = container.read(authControllerProvider);
      expect(state, const AuthState.error('Invalid credentials'));
    });
  });
  
  group('ProjectList', () {
    test('should load projects', () async {
      final container = ProviderContainer(
        overrides: [
          projectRepositoryProvider.overrideWithValue(MockProjectRepository()),
        ],
      );
      
      final mockRepo = container.read(projectRepositoryProvider) as MockProjectRepository;
      when(() => mockRepo.getProjects(limit: any(named: 'limit')))
          .thenAnswer((_) async => testProjects);
      
      // Wait for build to complete
      await container.read(projectListProvider.future);
      
      final state = container.read(projectListProvider);
      expect(state.valueOrNull, testProjects);
    });
    
    test('should handle pagination', () async {
      final container = ProviderContainer(
        overrides: [
          projectRepositoryProvider.overrideWithValue(MockProjectRepository()),
        ],
      );
      
      final mockRepo = container.read(projectRepositoryProvider) as MockProjectRepository;
      
      // First page
      when(() => mockRepo.getProjects(limit: any(named: 'limit')))
          .thenAnswer((_) async => firstPageProjects);
      
      // Second page
      when(() => mockRepo.getProjects(
        limit: any(named: 'limit'),
        startAfter: any(named: 'startAfter'),
      )).thenAnswer((_) async => secondPageProjects);
      
      await container.read(projectListProvider.future);
      
      final controller = container.read(projectListProvider.notifier);
      await controller.loadMore();
      
      final state = container.read(projectListProvider);
      expect(
        state.valueOrNull,
        [...firstPageProjects, ...secondPageProjects],
      );
    });
  });
}
```

### Widget Testing with Providers
```dart
void main() {
  testWidgets('ProjectScreen shows loading then data', (tester) async {
    // Create a mock provider
    final mockProjectProvider = FutureProvider.family<Project, String>((ref, id) async {
      await Future.delayed(const Duration(milliseconds: 100));
      return testProject;
    });
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectDetailsProvider.overrideWith(
            (ref, id) => mockProjectProvider(ref, id),
          ),
        ],
        child: const MaterialApp(
          home: ProjectScreen(projectId: 'test-id'),
        ),
      ),
    );
    
    // Should show loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Wait for data
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    
    // Should show project
    expect(find.text(testProject.name), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
  
  testWidgets('Form submission updates state correctly', (tester) async {
    final container = ProviderContainer(
      overrides: [
        assetRepositoryProvider.overrideWithValue(MockAssetRepository()),
      ],
    );
    
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: AssetFormScreen(),
        ),
      ),
    );
    
    // Fill form
    await tester.enterText(
      find.byKey(const Key('balance-field')),
      '10000',
    );
    
    // Submit
    await tester.tap(find.text('Save'));
    await tester.pump();
    
    // Check state
    final formState = container.read(assetFormControllerProvider);
    expect(formState.isSubmitting, isTrue);
    
    // Wait for async operation
    await tester.pumpAndSettle();
    
    // Verify navigation occurred
    verify(() => mockRouter.pop()).called(1);
  });
}
```

## Performance Optimization

### Selective Watching
```dart
// Watch only specific properties
class UserAvatar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuild when avatar URL changes
    final avatarUrl = ref.watch(
      userProfileProvider.select((profile) => profile.avatarUrl),
    );
    
    return CircleAvatar(
      backgroundImage: NetworkImage(avatarUrl),
    );
  }
}

// Multiple selective watches
class ProjectStats extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectCount = ref.watch(
      userProjectsProvider.select((projects) => projects.valueOrNull?.length ?? 0),
    );
    
    final totalValue = ref.watch(
      portfolioProvider.select((portfolio) => portfolio.totalValue),
    );
    
    return StatsCard(
      projectCount: projectCount,
      totalValue: totalValue,
    );
  }
}
```

### Provider Lifecycle Management
```dart
// Auto-dispose when not needed
@riverpod
Future<ExpensiveData> expensiveOperation(ExpensiveOperationRef ref) async {
  // Auto-disposed when no longer watched
  final api = ref.watch(apiProvider);
  return api.fetchExpensiveData();
}

// Keep alive for frequently accessed data
@Riverpod(keepAlive: true)
Future<UserSettings> userSettings(UserSettingsRef ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) throw UnauthorizedException();
  
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.getUserSettings(userId);
}

// Manual lifecycle control
@riverpod
class DataController extends _$DataController {
  @override
  Future<Data> build() async {
    // Keep alive while loading
    ref.keepAlive();
    
    try {
      final data = await _loadData();
      
      // Allow disposal after successful load
      ref.keepAlive();
      Timer(const Duration(minutes: 5), () {
        // Allow disposal after 5 minutes
        ref.invalidateSelf();
      });
      
      return data;
    } catch (e) {
      // Allow disposal on error
      ref.invalidateSelf();
      rethrow;
    }
  }
}
```

## Error Handling

### Consistent Error States
```dart
// Define error types
@freezed
class DataError with _$DataError {
  const factory DataError.network() = NetworkError;
  const factory DataError.permission() = PermissionError;
  const factory DataError.notFound() = NotFoundError;
  const factory DataError.unknown(String message) = UnknownError;
}

// Handle errors in providers
@riverpod
class DataProvider extends _$DataProvider {
  @override
  Future<Either<DataError, Data>> build() async {
    try {
      final repository = ref.watch(dataRepositoryProvider);
      final data = await repository.fetchData();
      return Right(data);
    } on NetworkException {
      return const Left(DataError.network());
    } on PermissionException {
      return const Left(DataError.permission());
    } on NotFoundException {
      return const Left(DataError.notFound());
    } catch (e) {
      return Left(DataError.unknown(e.toString()));
    }
  }
}

// Handle errors in UI
class DataScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dataProvider);
    
    return dataAsync.when(
      data: (either) => either.fold(
        (error) => error.when(
          network: () => const NetworkErrorView(),
          permission: () => const PermissionErrorView(),
          notFound: () => const NotFoundView(),
          unknown: (message) => ErrorView(message: message),
        ),
        (data) => DataView(data: data),
      ),
      loading: () => const LoadingView(),
      error: (e, s) => ErrorView(message: e.toString()),
    );
  }
}
```

## Best Practices Summary

### Do's
1. Use code generation for type safety
2. Keep providers focused and single-purpose
3. Use appropriate provider types for each use case
4. Handle loading and error states consistently
5. Test providers independently from UI
6. Use selective watching to optimize rebuilds
7. Properly manage provider lifecycle
8. Document complex state logic

### Don'ts
1. Don't put UI logic in providers
2. Don't create providers inside widgets
3. Don't use providers for ephemeral UI state
4. Don't ignore error handling
5. Don't create circular dependencies
6. Don't mutate state directly
7. Don't use watch in callbacks (use read)
8. Don't forget to dispose resources

---

*Version: 1.0*
*Last Updated: November 2024*
*Riverpod Version: 3.0+*
