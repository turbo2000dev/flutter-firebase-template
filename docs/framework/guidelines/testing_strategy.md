# Testing Strategy

## Overview

This document outlines the comprehensive testing strategy for the application. The strategy follows the testing pyramid approach with emphasis on maintainability, coverage, and continuous integration.

## Testing Philosophy

### Core Principles
1. **Test Behavior, Not Implementation**: Focus on what the code does, not how
2. **Isolation**: Each test should be independent
3. **Repeatability**: Tests must produce consistent results
4. **Clarity**: Test names clearly describe what is being tested
5. **Speed**: Fast tests encourage frequent execution
6. **Coverage**: Aim for high coverage without sacrificing quality
7. **Maintenance**: Keep tests simple and maintainable

### Testing Pyramid

```
                    E2E Tests (5%)
                   /              \
                  /  Slow, Costly  \
                 /   Full Journey   \
                /                    \
               Integration Tests (15%)
              /                        \
             /   Feature Workflows      \
            /    API Integration         \
           /                              \
          Widget/Component Tests (30%)
         /                                  \
        /     UI Components & Screens        \
       /       User Interactions              \
      /                                        \
     Unit Tests (50%)
    /                                            \
   /  Fast, Cheap, Isolated Business Logic       \
  /    Domain Models, Services, Utilities         \
 /                                                  \
```

## Test Coverage Requirements

### Coverage Goals
- **Overall**: Minimum 80% coverage
- **Critical Paths**: 100% coverage
  - Authentication flows
  - Financial calculations
  - Data persistence
  - Payment processing
- **Domain Layer**: 95% coverage
- **Data Layer**: 90% coverage
- **Application Layer**: 85% coverage
- **Presentation Layer**: 70% coverage
- **Services Layer**: 80% coverage
- **Utilities**: 100% coverage

### Coverage Exclusions

**IMPORTANT: Always exclude generated files when measuring coverage.**

Generated files (.g.dart, .freezed.dart) contain auto-generated code that:
- Is not written by developers
- Cannot be meaningfully tested
- Inflates or deflates coverage metrics artificially

```yaml
# Files to exclude from coverage metrics
exclude:
  - "**/*.g.dart"           # Generated code (JSON serialization, Riverpod)
  - "**/*.freezed.dart"     # Freezed generated (immutable classes)
  - "**/*.config.dart"      # Injectable config
  - "**/main.dart"          # Entry point
  - "**/firebase_options.dart" # Firebase config
  - "test/**"               # Test files
```

### Measuring Coverage

**Always use the coverage report script for accurate metrics:**

```bash
# Generate coverage data
flutter test --coverage

# Analyze coverage (excludes generated files automatically)
python3 scripts/coverage-report.py

# For CI/CD (exits with error if below 80% threshold)
python3 scripts/coverage-report.py --ci

# For JSON output (useful for dashboards/automation)
python3 scripts/coverage-report.py --json
```

**DO NOT use raw lcov output** - it includes generated files and gives inaccurate results.

## Unit Testing

### What to Unit Test
- Business logic
- Domain models
- Use cases
- Repositories
- Services
- Utilities
- Validators
- Formatters
- Calculations

### Unit Test Structure
```dart
// test/features/projections/domain/calculators/tax_calculator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:{{PROJECT_NAME}}/features/projections/domain/calculators/tax_calculator.dart';

void main() {
  group('TaxCalculator', () {
    late TaxCalculator calculator;
    
    setUp(() {
      calculator = TaxCalculator();
    });
    
    group('calculateFederalTax', () {
      test('should calculate correct tax for income under basic exemption', () {
        // Arrange
        const income = 15000.0;
        const expectedTax = 0.0;
        
        // Act
        final tax = calculator.calculateFederalTax(income);
        
        // Assert
        expect(tax, expectedTax);
      });
      
      test('should apply correct marginal rates for high income', () {
        // Arrange
        const income = 250000.0;
        
        // Act
        final tax = calculator.calculateFederalTax(income);
        
        // Assert
        expect(tax, greaterThan(60000));
        expect(tax, lessThan(80000));
      });
      
      test('should throw for negative income', () {
        // Arrange
        const income = -1000.0;
        
        // Act & Assert
        expect(
          () => calculator.calculateFederalTax(income),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
    
    group('calculate{{TARGET_REGION}}Tax', () {
      test('should include provincial deductions', () {
        // Arrange
        const income = 50000.0;
        const hasSpouse = true;
        const dependents = 2;
        
        // Act
        final tax = calculator.calculate{{TARGET_REGION}}Tax(
          income: income,
          hasSpouse: hasSpouse,
          dependents: dependents,
        );
        
        // Assert
        expect(tax, lessThan(calculator.calculate{{TARGET_REGION}}Tax(income: income)));
      });
    });
  });
}
```

### Mocking Strategy
```dart
// Using Mocktail for mocking
import 'package:mocktail/mocktail.dart';

// Mock definition
class MockProjectRepository extends Mock implements ProjectRepository {}

// Usage in tests
void main() {
  group('GetProjectsUseCase', () {
    late GetProjectsUseCase useCase;
    late MockProjectRepository mockRepository;
    
    setUp(() {
      mockRepository = MockProjectRepository();
      useCase = GetProjectsUseCase(mockRepository);
    });
    
    test('should return projects from repository', () async {
      // Arrange
      final expectedProjects = [
        Project(id: '1', name: 'Project 1'),
        Project(id: '2', name: 'Project 2'),
      ];
      
      when(() => mockRepository.getProjects())
          .thenAnswer((_) async => expectedProjects);
      
      // Act
      final result = await useCase.execute();
      
      // Assert
      expect(result, expectedProjects);
      verify(() => mockRepository.getProjects()).called(1);
    });
    
    test('should handle repository errors', () async {
      // Arrange
      when(() => mockRepository.getProjects())
          .thenThrow(NetworkException('No connection'));
      
      // Act & Assert
      expect(
        () => useCase.execute(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
```

### Testing Async Code
```dart
// Testing Futures
test('should fetch user data asynchronously', () async {
  // Arrange
  final future = repository.fetchUserData('user-id');
  
  // Act & Assert
  await expectLater(future, completion(isA<User>()));
});

// Testing Streams
test('should emit values in correct order', () async {
  // Arrange
  final stream = service.watchValues();
  
  // Act & Assert
  await expectLater(
    stream,
    emitsInOrder([
      1,
      2,
      3,
      emitsDone,
    ]),
  );
});

// Testing with fake async
testWidgets('should debounce search input', (tester) async {
  await tester.runAsync(() async {
    // Arrange
    final controller = SearchController();
    final results = <String>[];
    controller.results.listen(results.add);
    
    // Act
    controller.search('a');
    await Future.delayed(const Duration(milliseconds: 100));
    controller.search('ab');
    await Future.delayed(const Duration(milliseconds: 100));
    controller.search('abc');
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Assert
    expect(results, ['abc']); // Only final value after debounce
  });
});
```

## Widget Testing

### What to Widget Test
- Individual widgets
- Screen layouts
- User interactions
- Form validation
- Navigation flows
- State changes
- Error displays

### Widget Test Examples
```dart
// test/features/auth/presentation/widgets/login_form_test.dart

void main() {
  group('LoginForm', () {
    testWidgets('should display email and password fields', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoginForm()),
        ),
      );
      
      // Assert
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byKey(const Key('email-field')), findsOneWidget);
      expect(find.byKey(const Key('password-field')), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
    
    testWidgets('should show validation errors', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoginForm()),
        ),
      );
      
      // Act - Submit empty form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Assert
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });
    
    testWidgets('should call onSubmit with valid data', (tester) async {
      // Arrange
      String? submittedEmail;
      String? submittedPassword;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(
              onSubmit: (email, password) {
                submittedEmail = email;
                submittedPassword = password;
              },
            ),
          ),
        ),
      );
      
      // Act
      await tester.enterText(
        find.byKey(const Key('email-field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password-field')),
        'password123',
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Assert
      expect(submittedEmail, 'test@example.com');
      expect(submittedPassword, 'password123');
    });
  });
}
```

### Testing with Riverpod
```dart
// test/features/projects/presentation/screens/project_list_screen_test.dart

void main() {
  group('ProjectListScreen', () {
    testWidgets('should display loading initially', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectListProvider.overrideWith((ref) {
              return const AsyncLoading();
            }),
          ],
          child: const MaterialApp(
            home: ProjectListScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should display projects when loaded', (tester) async {
      // Arrange
      final projects = [
        Project(id: '1', name: 'Retirement Plan A'),
        Project(id: '2', name: 'Retirement Plan B'),
      ];
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectListProvider.overrideWith((ref) {
              return AsyncData(projects);
            }),
          ],
          child: const MaterialApp(
            home: ProjectListScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Retirement Plan A'), findsOneWidget);
      expect(find.text('Retirement Plan B'), findsOneWidget);
    });
    
    testWidgets('should show error message on failure', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectListProvider.overrideWith((ref) {
              return const AsyncError(
                'Failed to load projects',
                StackTrace.empty,
              );
            }),
          ],
          child: const MaterialApp(
            home: ProjectListScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Failed to load projects'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget); // Retry button
    });
  });
}
```

### Golden Tests
```dart
// test/golden/widgets/project_card_golden_test.dart

void main() {
  group('ProjectCard Golden Tests', () {
    testWidgets('should match golden file for default state', (tester) async {
      // Arrange
      final project = Project(
        id: '1',
        name: 'My Retirement Plan',
        description: 'Planning for retirement at 65',
        individuals: [
          Individual(name: 'John Doe', birthDate: DateTime(1970, 1, 1)),
        ],
        createdAt: DateTime(2024, 1, 1),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: ProjectCard(project: project),
              ),
            ),
          ),
        ),
      );
      
      // Act & Assert
      await expectLater(
        find.byType(ProjectCard),
        matchesGoldenFile('goldens/project_card_default.png'),
      );
    });
    
    testWidgets('should match golden file for selected state', (tester) async {
      // Similar setup with selected state
      await expectLater(
        find.byType(ProjectCard),
        matchesGoldenFile('goldens/project_card_selected.png'),
      );
    });
  });
}
```

## Integration Testing

### What to Integration Test
- Feature workflows
- API integrations
- Database operations
- Authentication flows
- Multi-screen flows
- State persistence

### Integration Test Structure
```dart
// integration_test/auth_flow_test.dart

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Authentication Flow', () {
    testWidgets('should complete full authentication flow', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to login
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      
      // Fill login form
      await tester.enterText(
        find.byKey(const Key('email-field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password-field')),
        'Test123!',
      );
      
      // Submit
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      
      // Verify navigation to dashboard
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('Welcome back!'), findsOneWidget);
      
      // Test logout
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      
      // Verify back at login
      expect(find.byType(LoginScreen), findsOneWidget);
    });
    
    testWidgets('should handle invalid credentials', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to login
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      
      // Fill with invalid credentials
      await tester.enterText(
        find.byKey(const Key('email-field')),
        'wrong@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password-field')),
        'wrongpassword',
      );
      
      // Submit
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      
      // Verify error message
      expect(find.text('Invalid email or password'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
  
  group('Project Creation Flow', () {
    testWidgets('should create a new project', (tester) async {
      // Login first
      await loginAsTestUser(tester);
      
      // Navigate to projects
      await tester.tap(find.byIcon(Icons.folder));
      await tester.pumpAndSettle();
      
      // Tap create button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Fill project form
      await tester.enterText(
        find.byKey(const Key('project-name')),
        'Test Retirement Plan',
      );
      await tester.enterText(
        find.byKey(const Key('project-description')),
        'Planning for retirement at 65',
      );
      
      // Add individual
      await tester.tap(find.text('Add Individual'));
      await tester.pumpAndSettle();
      
      await tester.enterText(
        find.byKey(const Key('individual-name')),
        'John Doe',
      );
      await tester.tap(find.byKey(const Key('birth-date')));
      await tester.pumpAndSettle();
      // Select date from date picker
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      
      // Save individual
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      
      // Save project
      await tester.tap(find.text('Create Project'));
      await tester.pumpAndSettle();
      
      // Verify project created
      expect(find.text('Test Retirement Plan'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });
  });
}

// Helper functions
Future<void> loginAsTestUser(WidgetTester tester) async {
  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle();
  
  await tester.enterText(
    find.byKey(const Key('email-field')),
    'test@example.com',
  );
  await tester.enterText(
    find.byKey(const Key('password-field')),
    'Test123!',
  );
  
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
}
```

### API Integration Tests
```dart
// test/integration/api/market_data_api_test.dart

void main() {
  group('MarketDataApi Integration', () {
    late MarketDataApi api;
    late Dio dio;
    
    setUp(() {
      dio = Dio();
      dio.interceptors.add(LogInterceptor());
      api = MarketDataApi(dio);
    });
    
    test('should fetch real market data', () async {
      // This test hits the actual API
      final data = await api.getMarketData('TSX:XIU');
      
      expect(data, isNotNull);
      expect(data.symbol, 'TSX:XIU');
      expect(data.price, greaterThan(0));
      expect(data.change, isNotNull);
    });
    
    test('should handle rate limiting gracefully', () async {
      // Make multiple rapid requests
      final futures = List.generate(
        10,
        (_) => api.getMarketData('TSX:XIU'),
      );
      
      // Should not throw, but may return cached data
      final results = await Future.wait(futures);
      expect(results, hasLength(10));
    });
    
    test('should handle network errors', () async {
      // Disconnect network or use wrong URL
      dio.options.baseUrl = 'https://invalid.example.com';
      
      expect(
        () => api.getMarketData('TSX:XIU'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
```

## E2E Testing

### E2E Test Scenarios
```dart
// e2e_test/retirement_planning_journey_test.dart

void main() {
  group('Complete Retirement Planning Journey', () {
    testWidgets('should complete full user journey', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 1. Registration
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();
      
      await fillRegistrationForm(tester);
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();
      
      // 2. Email verification (mock in test env)
      await verifyEmail(tester);
      
      // 3. Complete onboarding
      await completeOnboarding(tester);
      
      // 4. Create first project
      await createProject(tester, 'My Retirement Plan');
      
      // 5. Add assets
      await addRRSPAccount(tester, balance: 50000);
      await addTFSAAccount(tester, balance: 25000);
      await addRealEstate(tester, value: 500000);
      
      // 6. Set retirement events
      await addRetirementEvent(tester, age: 65);
      
      // 7. Create scenarios
      await createScenario(tester, 'Optimistic', returnRate: 0.07);
      await createScenario(tester, 'Conservative', returnRate: 0.04);
      
      // 8. View projections
      await viewProjections(tester);
      
      // 9. Generate report
      await generateReport(tester);
      
      // Verify complete journey
      expect(find.text('Report Generated'), findsOneWidget);
    });
  });
}
```

## Test Data Management

### Test Fixtures
```dart
// test/fixtures/test_data.dart

class TestData {
  static final testUser = User(
    id: 'test-user-id',
    email: 'test@example.com',
    name: 'Test User',
    createdAt: DateTime(2024, 1, 1),
  );
  
  static final testProject = Project(
    id: 'test-project-id',
    name: 'Test Retirement Plan',
    userId: testUser.id,
    individuals: [testIndividual],
    createdAt: DateTime(2024, 1, 1),
  );
  
  static final testIndividual = Individual(
    id: 'test-individual-id',
    name: 'John Doe',
    birthDate: DateTime(1970, 1, 1),
    gender: Gender.male,
  );
  
  static final testAssets = [
    Asset.rrsp(
      id: 'rrsp-1',
      accountHolder: testIndividual.id,
      balance: 100000,
      contributionRoom: 50000,
    ),
    Asset.tfsa(
      id: 'tfsa-1',
      accountHolder: testIndividual.id,
      balance: 50000,
      contributionRoom: 25000,
    ),
  ];
}

// Builders for complex test data
class ProjectBuilder {
  String id = 'project-id';
  String name = 'Test Project';
  List<Individual> individuals = [];
  
  ProjectBuilder withId(String id) {
    this.id = id;
    return this;
  }
  
  ProjectBuilder withName(String name) {
    this.name = name;
    return this;
  }
  
  ProjectBuilder withIndividuals(List<Individual> individuals) {
    this.individuals = individuals;
    return this;
  }
  
  Project build() {
    return Project(
      id: id,
      name: name,
      individuals: individuals,
      createdAt: DateTime.now(),
    );
  }
}

// Usage
final project = ProjectBuilder()
    .withName('Custom Project')
    .withIndividuals([individual1, individual2])
    .build();
```

### Faker for Realistic Data
```dart
// test/fixtures/faker_extensions.dart

import 'package:faker/faker.dart';

extension FakerExtensions on Faker {
  Project fakeProject() {
    return Project(
      id: guid.guid(),
      name: '${person.lastName()} Family Retirement',
      description: lorem.sentence(),
      individuals: List.generate(
        randomGenerator.integer(3, min: 1),
        (_) => fakeIndividual(),
      ),
      createdAt: date.dateTime(minYear: 2020, maxYear: 2024),
    );
  }
  
  Individual fakeIndividual() {
    return Individual(
      id: guid.guid(),
      name: person.name(),
      birthDate: date.dateTime(minYear: 1950, maxYear: 2000),
      gender: randomGenerator.boolean() ? Gender.male : Gender.female,
    );
  }
  
  Asset fakeAsset() {
    final types = [
      () => Asset.rrsp(
            id: guid.guid(),
            balance: randomGenerator.decimal(scale: 100000, min: 1000),
            contributionRoom: randomGenerator.decimal(scale: 50000),
          ),
      () => Asset.tfsa(
            id: guid.guid(),
            balance: randomGenerator.decimal(scale: 50000, min: 1000),
            contributionRoom: randomGenerator.decimal(scale: 10000),
          ),
      () => Asset.realEstate(
            id: guid.guid(),
            propertyType: PropertyType.primaryResidence,
            currentValue: randomGenerator.decimal(
              scale: 1000000,
              min: 200000,
            ),
          ),
    ];
    
    return types[randomGenerator.integer(types.length)]();
  }
}

// Usage in tests
final faker = Faker();
final projects = List.generate(10, (_) => faker.fakeProject());
```

## Performance Testing

### Widget Performance Tests
```dart
// test/performance/scrolling_performance_test.dart

void main() {
  testWidgets('ProjectList scrolling performance', (tester) async {
    // Generate large dataset
    final projects = List.generate(1000, (i) => 
      Project(id: '$i', name: 'Project $i'),
    );
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectListProvider.overrideWith((ref) => AsyncData(projects)),
        ],
        child: const MaterialApp(
          home: ProjectListScreen(),
        ),
      ),
    );
    
    final listFinder = find.byType(Scrollable);
    
    // Measure frame rendering time during scroll
    await tester.timedDrag(
      listFinder,
      const Offset(0, -5000),
      const Duration(seconds: 2),
    );
    
    // Verify smooth scrolling (60 fps = 16.67ms per frame)
    expect(
      tester.binding.framesEnabled,
      isTrue,
      reason: 'Frames should not be skipped',
    );
  });
}
```

### Calculation Performance Tests
```dart
// test/performance/projection_calculation_test.dart

void main() {
  test('projection calculation performance', () {
    final calculator = ProjectionCalculator();
    final parameters = createComplexParameters();
    
    final stopwatch = Stopwatch()..start();
    final result = calculator.calculate(parameters);
    stopwatch.stop();
    
    // Should complete within 500ms even for complex scenarios
    expect(stopwatch.elapsedMilliseconds, lessThan(500));
    expect(result.years, hasLength(50));
  });
  
  test('batch calculation performance', () {
    final calculator = ProjectionCalculator();
    final scenarios = List.generate(10, (_) => createComplexParameters());
    
    final stopwatch = Stopwatch()..start();
    final results = scenarios.map(calculator.calculate).toList();
    stopwatch.stop();
    
    // Should handle multiple scenarios efficiently
    expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    expect(results, hasLength(10));
  });
}
```

## Continuous Integration

### CI Configuration
```yaml
# .github/workflows/test.yml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run code generation
        run: flutter pub run build_runner build --delete-conflicting-outputs
      
      - name: Analyze code
        run: flutter analyze
      
      - name: Run unit tests
        run: flutter test --coverage
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
      
      - name: Run widget tests
        run: flutter test test/widgets
      
      - name: Build APK
        run: flutter build apk --debug
      
      - name: Run integration tests
        run: flutter test integration_test

  golden:
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run golden tests
        run: flutter test --update-goldens test/golden
      
      - name: Upload golden failures
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: golden-failures
          path: test/golden/failures/
```

### Pre-commit Hooks
```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: flutter-analyze
        name: Flutter Analyze
        entry: flutter analyze
        language: system
        pass_filenames: false
        
      - id: flutter-format
        name: Flutter Format
        entry: flutter format --set-exit-if-changed .
        language: system
        pass_filenames: false
        
      - id: flutter-test
        name: Flutter Test
        entry: flutter test
        language: system
        pass_filenames: false
```

## Test Reporting

### Coverage Report Generation
```bash
# Generate coverage report
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html
```

### Test Result Dashboard
```dart
// test/test_reporter.dart

class TestReporter {
  static void generateReport(List<TestResult> results) {
    final totalTests = results.length;
    final passedTests = results.where((r) => r.passed).length;
    final failedTests = totalTests - passedTests;
    final duration = results.fold<Duration>(
      Duration.zero,
      (sum, r) => sum + r.duration,
    );
    
    print('╔══════════════════════════════════════╗');
    print('║         Test Results Summary         ║');
    print('╠══════════════════════════════════════╣');
    print('║ Total Tests:    ${totalTests.toString().padLeft(20)} ║');
    print('║ Passed:         ${passedTests.toString().padLeft(20)} ║');
    print('║ Failed:         ${failedTests.toString().padLeft(20)} ║');
    print('║ Duration:       ${duration.toString().padLeft(20)} ║');
    print('║ Pass Rate:      ${(passedTests / totalTests * 100).toStringAsFixed(1).padLeft(19)}% ║');
    print('╚══════════════════════════════════════╝');
    
    if (failedTests > 0) {
      print('\nFailed Tests:');
      results.where((r) => !r.passed).forEach((r) {
        print('  ❌ ${r.name}');
        print('     ${r.error}');
      });
    }
  }
}
```

## Testing Best Practices

### Do's
1. Write tests before fixing bugs
2. Keep tests simple and focused
3. Use descriptive test names
4. Test edge cases and error conditions
5. Mock external dependencies
6. Use test fixtures for consistency
7. Run tests frequently
8. Maintain test coverage
9. Review tests in code reviews
10. Update tests when requirements change

### Don'ts
1. Don't test implementation details
2. Don't write brittle tests
3. Don't ignore failing tests
4. Don't duplicate test logic
5. Don't test framework code
6. Don't use production data
7. Don't skip async handling
8. Don't forget cleanup
9. Don't test multiple behaviors in one test
10. Don't couple tests together

---

*Version: 1.0*
*Last Updated: November 2024*
*Testing Framework: Flutter Test 3.24+*
