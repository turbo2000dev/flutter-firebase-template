# Coding Standards

## Overview

This document defines the coding standards for the application. Following these standards ensures code consistency, maintainability, and quality across the entire codebase.

## Dart Style Guide

### Naming Conventions

#### Classes and Types
```dart
// ✅ Good - PascalCase for classes
class UserProfile {}
class RetirementCalculator {}
abstract class AuthRepository {}

// ❌ Bad
class user_profile {}
class retirementcalculator {}
```

#### Variables and Functions
```dart
// ✅ Good - camelCase for variables and functions
final userName = 'John Doe';
void calculateRetirement() {}
Stream<User> getUserStream() {}

// ❌ Bad
final UserName = 'John Doe';
void CalculateRetirement() {}
```

#### Constants
```dart
// ✅ Good - lowerCamelCase for constants
const defaultTimeout = Duration(seconds: 30);
const maxRetryAttempts = 3;
const apiBaseUrl = 'https://api.example.com';

// ❌ Bad
const DEFAULT_TIMEOUT = Duration(seconds: 30);
const MAX_RETRY_ATTEMPTS = 3;
```

#### Private Members
```dart
// ✅ Good - underscore prefix for private members
class Calculator {
  final _privateField = 0;
  
  void _privateMethod() {}
}

// Use private members when scope is class-only
```

#### File Names
```dart
// ✅ Good - snake_case for file names
user_profile.dart
retirement_calculator.dart
auth_repository_impl.dart

// ❌ Bad
UserProfile.dart
retirement-calculator.dart
authRepositoryImpl.dart
```

### Code Organization

#### Import Order
```dart
// 1. Dart imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Package imports (alphabetical)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// 4. Project imports (by feature)
import 'package:{{PROJECT_NAME}}/core/constants/app_constants.dart';
import 'package:{{PROJECT_NAME}}/features/auth/domain/entities/user.dart';

// 5. Part files
part 'user.freezed.dart';
part 'user.g.dart';
```

#### Class Organization
```dart
class ExampleWidget extends ConsumerWidget {
  // 1. Static constants
  static const double padding = 16.0;
  
  // 2. Static variables
  static int instanceCount = 0;
  
  // 3. Factory constructors
  factory ExampleWidget.primary() => ExampleWidget();
  
  // 4. Named constructors
  const ExampleWidget({
    super.key,
    required this.title,
    this.subtitle,
  });
  
  // 5. Final fields
  final String title;
  final String? subtitle;
  
  // 6. Getters and setters
  String get displayTitle => title.toUpperCase();
  
  // 7. Override methods
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
  
  // 8. Public methods
  void handleTap() {}
  
  // 9. Private methods
  void _processData() {}
}
```

### Formatting Rules

#### Line Length
```dart
// Maximum 80 characters per line (enforced by dartfmt)
// Exception: URLs and file paths can exceed limit

// ✅ Good
final result = await repository
    .fetchUserData(userId)
    .timeout(const Duration(seconds: 30));

// ❌ Bad
final result = await repository.fetchUserData(userId).timeout(const Duration(seconds: 30));
```

#### Indentation
```dart
// Use 2 spaces for indentation (no tabs)

// ✅ Good
class Example {
  void method() {
    if (condition) {
      doSomething();
    }
  }
}
```

#### Trailing Commas
```dart
// ✅ Good - Use trailing commas for better formatting
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      'Hello',
      style: Theme.of(context).textTheme.headlineMedium,
    ),
  );
}

// ❌ Bad - No trailing commas makes formatting worse
Widget build(BuildContext context) {
  return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)), child: Text('Hello', style: Theme.of(context).textTheme.headlineMedium));
}
```

### Documentation

#### Class Documentation
```dart
/// A calculator for retirement projections.
///
/// This class handles all calculations related to {{PROJECT_DESCRIPTION}},
/// including income projections, tax calculations, and asset growth.
///
/// Example:
/// ```dart
/// final calculator = RetirementCalculator();
/// final projection = calculator.calculate(parameters);
/// ```
class RetirementCalculator {
  // Implementation
}
```

#### Method Documentation
```dart
/// Calculates the retirement projection for the given parameters.
///
/// [parameters] The input parameters for the calculation.
/// [scenario] Optional scenario to apply (defaults to base scenario).
/// 
/// Returns a [ProjectionResult] containing yearly cash flows.
/// 
/// Throws [CalculationException] if parameters are invalid.
Future<ProjectionResult> calculate(
  ProjectionParameters parameters, {
  Scenario? scenario,
}) async {
  // Implementation
}
```

#### Inline Comments
```dart
// ✅ Good - Explains why, not what
// Use exponential backoff to avoid overwhelming the server
await Future.delayed(Duration(seconds: math.pow(2, attempt).toInt()));

// ❌ Bad - States the obvious
// Increment counter by 1
counter++;

// ✅ Good - Complex logic explanation
// {{TARGET_REGION}} tax calculation requires special handling for pension income
// splitting between spouses when both are over 65
final taxableIncome = calculate{{TARGET_REGION}}TaxableIncome(income, age, hasSpouse);
```

## Flutter Best Practices

### Widget Guidelines

#### Prefer Stateless Widgets
```dart
// ✅ Good - Stateless when possible
class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.user});
  
  final User user;
  
  @override
  Widget build(BuildContext context) {
    return Card(child: Text(user.name));
  }
}

// Only use StatefulWidget when necessary
class CounterWidget extends StatefulWidget {
  // When local state is required
}
```

#### Use const Constructors
```dart
// ✅ Good - const for compile-time constants
class MyWidget extends StatelessWidget {
  const MyWidget({super.key}); // const constructor
  
  @override
  Widget build(BuildContext context) {
    return const Padding( // const widget
      padding: EdgeInsets.all(16), // const value
      child: Text('Hello'), // const child
    );
  }
}
```

#### Widget Composition
```dart
// ✅ Good - Small, focused widgets
class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ProfileHeader(),
        const _ProfileDetails(),
        const _ProfileActions(),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  // Focused responsibility
}

// ❌ Bad - Large, monolithic widget
class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 500+ lines of nested widgets
  }
}
```

#### Key Usage
```dart
// ✅ Good - Keys for list items
ListView.builder(
  itemBuilder: (context, index) {
    return UserTile(
      key: ValueKey(users[index].id), // Preserve state
      user: users[index],
    );
  },
);

// ✅ Good - Keys for form fields
TextFormField(
  key: const ValueKey('email'), // Testing and state preservation
  controller: emailController,
);
```

### State Management with Riverpod

#### Provider Naming
```dart
// ✅ Good - Descriptive provider names
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier(ref);
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

// ❌ Bad - Vague names
final provider = StateNotifierProvider((ref) => SomeNotifier());
final data = Provider((ref) => something);
```

#### Provider Organization
```dart
// ✅ Good - Providers in feature modules
// features/auth/application/providers/auth_provider.dart

@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() => const AuthState.initial();
  
  Future<void> signIn(String email, String password) async {
    // Implementation
  }
}

// ❌ Bad - All providers in one file
// providers.dart - Contains 50+ providers
```

#### Avoid Provider Overuse
```dart
// ✅ Good - Local state for UI-only concerns
class _ExpandableCardState extends State<ExpandableCard> {
  bool _isExpanded = false; // Local state, not provider
  
  @override
  Widget build(BuildContext context) {
    // Use local state
  }
}

// ❌ Bad - Provider for ephemeral UI state
final isExpandedProvider = StateProvider<bool>((ref) => false);
```

### Error Handling

#### Use Type-Safe Errors
```dart
// ✅ Good - Sealed classes for errors
@freezed
class AuthFailure with _$AuthFailure {
  const factory AuthFailure.invalidEmail() = _InvalidEmail;
  const factory AuthFailure.weakPassword() = _WeakPassword;
  const factory AuthFailure.emailInUse() = _EmailInUse;
  const factory AuthFailure.networkError() = _NetworkError;
}

// Handle errors with pattern matching
authFailure.when(
  invalidEmail: () => showError('Invalid email format'),
  weakPassword: () => showError('Password too weak'),
  emailInUse: () => showError('Email already registered'),
  networkError: () => showError('Check your connection'),
);
```

#### Graceful Error Recovery
```dart
// ✅ Good - Provide fallbacks and recovery options
Widget build(BuildContext context, WidgetRef ref) {
  final asyncValue = ref.watch(dataProvider);
  
  return asyncValue.when(
    data: (data) => DataView(data: data),
    loading: () => const LoadingIndicator(),
    error: (error, stack) => ErrorView(
      error: error,
      onRetry: () => ref.refresh(dataProvider),
    ),
  );
}
```

### Performance Guidelines

#### Use const Where Possible
```dart
// ✅ Good
const padding = EdgeInsets.all(16);
const duration = Duration(seconds: 2);
const TextStyle(fontSize: 16);

// Widget tree
const Padding(
  padding: EdgeInsets.all(16),
  child: Text('Static Text'),
);
```

#### Avoid Expensive Operations in build()
```dart
// ❌ Bad - Heavy computation in build
@override
Widget build(BuildContext context) {
  final result = expensiveCalculation(); // Runs on every rebuild
  return Text(result);
}

// ✅ Good - Cache or compute outside build
late final String result = expensiveCalculation(); // Computed once

// Or use providers for computed values
final calculatedValueProvider = Provider((ref) {
  return expensiveCalculation();
});
```

#### Optimize Lists
```dart
// ✅ Good - Builder for long lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
);

// ✅ Good - Separate item widgets
class ItemWidget extends StatelessWidget {
  const ItemWidget(this.item, {super.key});
  
  final Item item;
  
  @override
  Widget build(BuildContext context) {
    // Item rendering
  }
}

// ❌ Bad - All items built at once
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
);
```

## Testing Standards

### Test Organization
```dart
// ✅ Good - Mirror source structure
// test/features/auth/domain/use_cases/sign_in_use_case_test.dart

void main() {
  group('SignInUseCase', () {
    late SignInUseCase useCase;
    late MockAuthRepository mockRepository;
    
    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = SignInUseCase(mockRepository);
    });
    
    group('execute', () {
      test('should return user when credentials are valid', () async {
        // Arrange
        when(() => mockRepository.signIn(any(), any()))
            .thenAnswer((_) async => testUser);
        
        // Act
        final result = await useCase.execute('email', 'password');
        
        // Assert
        expect(result, equals(testUser));
      });
      
      test('should throw when credentials are invalid', () async {
        // Test implementation
      });
    });
  });
}
```

### Test Naming
```dart
// ✅ Good - Descriptive test names
test('should return filtered list when search term is provided', () {});
test('should throw ValidationException when email is invalid', () {});
test('should update cache when data is successfully fetched', () {});

// ❌ Bad - Vague test names
test('test 1', () {});
test('works', () {});
test('error case', () {});
```

### Widget Testing
```dart
// ✅ Good - Comprehensive widget tests
testWidgets('UserCard displays user information', (tester) async {
  // Arrange
  final user = User(name: 'John', email: 'john@example.com');
  
  // Act
  await tester.pumpWidget(
    MaterialApp(
      home: UserCard(user: user),
    ),
  );
  
  // Assert
  expect(find.text('John'), findsOneWidget);
  expect(find.text('john@example.com'), findsOneWidget);
});

// Test interactions
testWidgets('button triggers callback on tap', (tester) async {
  bool wasPressed = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: CustomButton(
        onPressed: () => wasPressed = true,
      ),
    ),
  );
  
  await tester.tap(find.byType(CustomButton));
  await tester.pump();
  
  expect(wasPressed, isTrue);
});
```

## Code Quality

### Linting Rules
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Error rules
    always_use_package_imports: true
    avoid_dynamic_calls: true
    avoid_returning_null_for_future: true
    avoid_type_to_string: true
    
    # Style rules
    always_declare_return_types: true
    always_put_required_named_parameters_first: true
    annotate_overrides: true
    avoid_annotating_with_dynamic: true
    avoid_bool_literals_in_conditional_expressions: true
    avoid_catching_errors: true
    avoid_empty_else: true
    avoid_field_initializers_in_const_classes: true
    avoid_final_parameters: true
    avoid_init_to_null: true
    avoid_null_checks_in_equality_operators: true
    avoid_positional_boolean_parameters: true
    avoid_print: true
    avoid_redundant_argument_values: true
    avoid_renaming_method_parameters: true
    avoid_return_types_on_setters: true
    avoid_returning_null: true
    avoid_single_cascade_in_expression_statements: true
    avoid_unnecessary_containers: true
    avoid_unused_constructor_parameters: true
    avoid_void_async: true
    await_only_futures: true
    camel_case_extensions: true
    camel_case_types: true
    cascade_invocations: true
    cast_nullable_to_non_nullable: true
    constant_identifier_names: true
    curly_braces_in_flow_control_structures: true
    deprecated_consistency: true
    directives_ordering: true
    empty_catches: true
    empty_constructor_bodies: true
    exhaustive_cases: true
    file_names: true
    flutter_style_todos: true
    implementation_imports: true
    leading_newlines_in_multiline_strings: true
    library_names: true
    library_prefixes: true
    library_private_types_in_public_api: true
    missing_whitespace_between_adjacent_strings: true
    no_adjacent_strings_in_list: true
    no_duplicate_case_values: true
    no_leading_underscores_for_library_prefixes: true
    no_logic_in_create_state: true
    no_runtimeType_toString: true
    non_constant_identifier_names: true
    noop_primitive_operations: true
    null_check_on_nullable_type_parameter: true
    null_closures: true
    omit_local_variable_types: true
    one_member_abstracts: true
    only_throw_errors: true
    overridden_fields: true
    package_api_docs: true
    package_names: true
    package_prefixed_library_names: true
    parameter_assignments: true
    prefer_adjacent_string_concatenation: true
    prefer_asserts_in_initializer_lists: true
    prefer_asserts_with_message: true
    prefer_collection_literals: true
    prefer_conditional_assignment: true
    prefer_const_constructors: true
    prefer_const_constructors_in_immutables: true
    prefer_const_declarations: true
    prefer_const_literals_to_create_immutables: true
    prefer_constructors_over_static_methods: true
    prefer_contains: true
    prefer_equal_for_default_values: true
    prefer_final_fields: true
    prefer_final_in_for_each: true
    prefer_final_locals: true
    prefer_for_elements_to_map_fromIterable: true
    prefer_function_declarations_over_variables: true
    prefer_generic_function_type_aliases: true
    prefer_if_elements_to_conditional_expressions: true
    prefer_if_null_operators: true
    prefer_initializing_formals: true
    prefer_inlined_adds: true
    prefer_int_literals: true
    prefer_interpolation_to_compose_strings: true
    prefer_is_empty: true
    prefer_is_not_empty: true
    prefer_is_not_operator: true
    prefer_iterable_whereType: true
    prefer_null_aware_method_calls: true
    prefer_null_aware_operators: true
    prefer_single_quotes: true
    prefer_spread_collections: true
    prefer_typing_uninitialized_variables: true
    prefer_void_to_null: true
    provide_deprecation_message: true
    recursive_getters: true
    require_trailing_commas: true
    sized_box_for_whitespace: true
    sized_box_shrink_expand: true
    slash_for_doc_comments: true
    sort_child_properties_last: true
    sort_constructors_first: true
    sort_pub_dependencies: true
    sort_unnamed_constructors_first: true
    test_types_in_equals: true
    throw_in_finally: true
    tighten_type_of_initializing_formals: true
    type_annotate_public_apis: true
    type_init_formals: true
    unawaited_futures: true
    unnecessary_await_in_return: true
    unnecessary_brace_in_string_interps: true
    unnecessary_const: true
    unnecessary_constructor_name: true
    unnecessary_getters_setters: true
    unnecessary_lambdas: true
    unnecessary_late: true
    unnecessary_new: true
    unnecessary_null_aware_assignments: true
    unnecessary_null_aware_operator_on_extension_on_nullable: true
    unnecessary_null_checks: true
    unnecessary_null_in_if_null_operators: true
    unnecessary_nullable_for_final_variable_declarations: true
    unnecessary_overrides: true
    unnecessary_parenthesis: true
    unnecessary_raw_strings: true
    unnecessary_statements: true
    unnecessary_string_escapes: true
    unnecessary_string_interpolations: true
    unnecessary_this: true
    unnecessary_to_list_in_spreads: true
    unrelated_type_equality_checks: true
    unsafe_html: true
    use_build_context_synchronously: true
    use_colored_box: true
    use_decorated_box: true
    use_enums: true
    use_full_hex_values_for_flutter_colors: true
    use_function_type_syntax_for_parameters: true
    use_if_null_to_convert_nulls_to_bools: true
    use_is_even_rather_than_modulo: true
    use_key_in_widget_constructors: true
    use_late_for_private_fields_and_variables: true
    use_named_constants: true
    use_raw_strings: true
    use_rethrow_when_possible: true
    use_setters_to_change_properties: true
    use_string_buffers: true
    use_super_parameters: true
    use_test_throws_matchers: true
    use_to_and_as_if_applicable: true
    valid_regexps: true
    void_checks: true

analyzer:
  errors:
    missing_required_param: error
    missing_return: error
    invalid_override_of_non_virtual_member: error
    todo: ignore
    
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.config.dart"
    - "build/**"
    - ".dart_tool/**"
```

### Code Review Checklist

#### Functionality
- [ ] Code performs intended functionality
- [ ] Edge cases are handled
- [ ] Error scenarios are addressed
- [ ] No regressions introduced

#### Code Quality
- [ ] Follows naming conventions
- [ ] DRY principle applied
- [ ] SOLID principles followed
- [ ] No code smells

#### Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Test coverage maintained
- [ ] All tests passing

#### Documentation
- [ ] Public APIs documented
- [ ] Complex logic explained
- [ ] README updated if needed
- [ ] CHANGELOG updated

#### Performance
- [ ] No unnecessary rebuilds
- [ ] Efficient algorithms used
- [ ] Memory leaks prevented
- [ ] Loading states handled

#### Security
- [ ] Input validation present
- [ ] No sensitive data logged
- [ ] Authentication checked
- [ ] Authorization verified

#### UI/UX
- [ ] Responsive design tested
- [ ] Accessibility considered
- [ ] Loading indicators present
- [ ] Error messages user-friendly

## Git Conventions

### Branch Naming
```bash
# Feature branches
feature/AUTH-123-social-login
feature/PROJ-456-scenario-comparison

# Bug fix branches
fix/BUG-789-calculation-error
fix/CRASH-321-null-pointer

# Hotfix branches
hotfix/PROD-111-critical-security-issue

# Release branches
release/1.2.0
release/2.0.0-beta.1
```

### Commit Messages
```bash
# Format: <type>(<scope>): <subject>
# 
# <body>
# 
# <footer>

# Examples:

feat(auth): add biometric authentication support

Implement Face ID and fingerprint authentication for iOS and Android.
Users can now enable biometric login from security settings.

Closes #123

fix(projections): correct tax calculation for {{TARGET_REGION}} residents

The previous implementation didn't account for provincial tax credits.
This fix ensures accurate tax calculations for {{TARGET_REGION}} taxpayers.

Bug: BUG-456

docs(readme): update setup instructions for M1 Macs

Add specific instructions for developers using Apple Silicon.

refactor(assets): extract asset repository interface

Move repository interface to domain layer following clean architecture.
No functional changes.

test(scenarios): add integration tests for scenario comparison

Cover edge cases when comparing multiple scenarios with different parameters.

chore(deps): upgrade riverpod to 2.5.0

Update includes breaking changes that require provider syntax updates.

BREAKING CHANGE: Providers now require explicit type annotations
```

### Pull Request Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-reviewed code
- [ ] Added/updated tests
- [ ] Tests pass locally
- [ ] Updated documentation
- [ ] No new warnings

## Screenshots (if applicable)
Before | After

## Testing Instructions
1. Step to reproduce/test
2. Expected behavior
3. Actual behavior

## Related Issues
Closes #XXX
```

## Conclusion

Following these coding standards ensures our codebase remains clean, consistent, and maintainable. Regular code reviews and automated tooling help enforce these standards. When in doubt, prioritize readability and maintainability over cleverness.

---

*Version: 1.0*
*Last Updated: November 2024*
*Next Review: February 2025*
