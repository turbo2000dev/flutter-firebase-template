# Security Guidelines

## Overview

This document outlines the comprehensive security strategy for the application. Given the sensitive financial and personal data involved, security is paramount and must be implemented at every layer of the application.

## Security Principles

### Defense in Depth
Implement multiple layers of security controls:
1. **Network Security**: TLS, certificate pinning
2. **Application Security**: Input validation, secure coding
3. **Data Security**: Encryption at rest and in transit
4. **Access Control**: Authentication and authorization
5. **Monitoring**: Logging, alerting, anomaly detection

### Least Privilege
- Grant minimum necessary permissions
- Segment user access by role
- Isolate sensitive operations
- Time-bound access tokens

### Zero Trust
- Verify every request
- Assume breach mindset
- Continuous validation
- Never trust, always verify

## Authentication Security

### Password Requirements
```dart
class PasswordPolicy {
  static const int minLength = 8;
  static const int maxLength = 128;
  static const int minUppercase = 1;
  static const int minLowercase = 1;
  static const int minDigits = 1;
  static const int minSpecialChars = 1;
  static const int passwordHistoryCount = 5;
  static const Duration passwordExpiry = Duration(days: 90);
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 30);
  
  static ValidationResult validate(String password) {
    final errors = <String>[];
    
    if (password.length < minLength) {
      errors.add('Password must be at least $minLength characters');
    }
    
    if (password.length > maxLength) {
      errors.add('Password must not exceed $maxLength characters');
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add('Password must contain uppercase letters');
    }
    
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add('Password must contain lowercase letters');
    }
    
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      errors.add('Password must contain numbers');
    }
    
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      errors.add('Password must contain special characters');
    }
    
    // Check for common patterns
    if (_hasCommonPatterns(password)) {
      errors.add('Password contains common patterns');
    }
    
    // Check against breach database
    if (_isBreachedPassword(password)) {
      errors.add('This password has been found in data breaches');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      strength: _calculateStrength(password),
    );
  }
  
  static bool _hasCommonPatterns(String password) {
    final patterns = [
      r'12345',
      r'qwerty',
      r'password',
      r'abc123',
      r'111111',
    ];
    
    final lowerPassword = password.toLowerCase();
    return patterns.any((pattern) => lowerPassword.contains(pattern));
  }
  
  static bool _isBreachedPassword(String password) {
    // Check against Have I Been Pwned API
    final hash = sha1.convert(utf8.encode(password)).toString().toUpperCase();
    final prefix = hash.substring(0, 5);
    final suffix = hash.substring(5);
    
    // Make API call to check if password has been breached
    // This is a simplified example
    return false;
  }
  
  static PasswordStrength _calculateStrength(String password) {
    int score = 0;
    
    // Length scoring
    score += (password.length / 4).floor();
    
    // Complexity scoring
    if (RegExp(r'[a-z]').hasMatch(password)) score += 1;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 2;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 2;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) score += 3;
    
    // Entropy scoring
    final uniqueChars = password.split('').toSet().length;
    score += (uniqueChars / 3).floor();
    
    if (score < 5) return PasswordStrength.weak;
    if (score < 10) return PasswordStrength.fair;
    if (score < 15) return PasswordStrength.good;
    return PasswordStrength.strong;
  }
}
```

### Multi-Factor Authentication (MFA)
```dart
class MFAService {
  static const int otpLength = 6;
  static const Duration otpValidity = Duration(minutes: 5);
  static const int backupCodesCount = 10;
  
  // TOTP Implementation
  Future<void> enableTOTP(String userId) async {
    final secret = _generateSecret();
    
    // Store encrypted secret
    await _secureStorage.write(
      key: 'mfa_secret_$userId',
      value: secret,
    );
    
    // Generate QR code for authenticator app
    final otpAuth = 'otpauth://totp/RetirementApp:$userId?'
        'secret=$secret&issuer=RetirementApp';
    
    return otpAuth;
  }
  
  bool verifyTOTP(String userId, String token) {
    final secret = await _secureStorage.read(key: 'mfa_secret_$userId');
    if (secret == null) return false;
    
    final totp = OTP.generateTOTPCode(
      secret,
      DateTime.now().millisecondsSinceEpoch,
    );
    
    return token == totp;
  }
  
  // SMS OTP Implementation
  Future<void> sendSMSOTP(String phoneNumber) async {
    final otp = _generateOTP();
    final hashedOTP = _hashOTP(otp);
    
    // Store with expiry
    await _cache.set(
      'sms_otp_$phoneNumber',
      hashedOTP,
      expiry: otpValidity,
    );
    
    // Send via SMS service
    await _smsService.send(
      to: phoneNumber,
      message: 'Your verification code is: $otp. Valid for 5 minutes.',
    );
  }
  
  // Backup codes
  List<String> generateBackupCodes(String userId) {
    final codes = List.generate(
      backupCodesCount,
      (_) => _generateSecureCode(),
    );
    
    // Store hashed codes
    final hashedCodes = codes.map(_hashCode).toList();
    await _secureStorage.write(
      key: 'backup_codes_$userId',
      value: jsonEncode(hashedCodes),
    );
    
    return codes; // Return unhashed for user to save
  }
  
  String _generateSecret() {
    final random = Random.secure();
    final bytes = List.generate(20, (_) => random.nextInt(256));
    return base32.encode(Uint8List.fromList(bytes));
  }
  
  String _generateOTP() {
    final random = Random.secure();
    return List.generate(otpLength, (_) => random.nextInt(10)).join();
  }
  
  String _hashOTP(String otp) {
    return sha256.convert(utf8.encode(otp)).toString();
  }
}
```

### Biometric Authentication
```dart
class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }
  
  Future<BiometricType?> getAvailableBiometric() async {
    final availableBiometrics = await _localAuth.getAvailableBiometrics();
    
    if (Platform.isIOS) {
      if (availableBiometrics.contains(BiometricType.face)) {
        return BiometricType.face;
      }
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return BiometricType.fingerprint;
      }
    } else if (Platform.isAndroid) {
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return BiometricType.fingerprint;
      }
    }
    
    return null;
  }
  
  Future<bool> authenticate({required String reason}) async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );
      
      if (authenticated) {
        // Log successful authentication
        await _auditLog.log(
          event: 'biometric_auth_success',
          timestamp: DateTime.now(),
        );
      }
      
      return authenticated;
    } on PlatformException catch (e) {
      // Log authentication failure
      await _auditLog.log(
        event: 'biometric_auth_failure',
        error: e.message,
        timestamp: DateTime.now(),
      );
      
      return false;
    }
  }
  
  // Store encrypted credentials with biometric protection
  Future<void> storeBiometricCredentials(
    String userId,
    String encryptedToken,
  ) async {
    if (!await isBiometricAvailable()) {
      throw SecurityException('Biometric not available');
    }
    
    // Use platform-specific secure storage
    if (Platform.isIOS) {
      await _keychainStorage.write(
        key: 'biometric_token_$userId',
        value: encryptedToken,
        options: KeychainOptions(
          accessibility: KeychainAccessibility.whenPasscodeSetThisDeviceOnly,
          authenticationPrompt: 'Authenticate to access your account',
        ),
      );
    } else if (Platform.isAndroid) {
      await _androidKeystore.write(
        key: 'biometric_token_$userId',
        value: encryptedToken,
        options: AndroidOptions(
          encryptedSharedPreferences: true,
          authenticationRequired: true,
        ),
      );
    }
  }
}
```

## Data Security

### Encryption at Rest
```dart
class DataEncryption {
  static const int keySize = 256;
  static const int ivSize = 128;
  static const int saltSize = 128;
  static const int iterations = 10000;
  
  // Generate encryption key from password
  Uint8List deriveKey(String password, Uint8List salt) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(salt, iterations, keySize ~/ 8));
    return pbkdf2.process(utf8.encode(password));
  }
  
  // Encrypt sensitive data
  String encrypt(String plaintext, String password) {
    final salt = _generateSalt();
    final key = deriveKey(password, salt);
    final iv = _generateIV();
    
    final cipher = GCMBlockCipher(AESEngine());
    cipher.init(
      true,
      AEADParameters(
        KeyParameter(key),
        128,
        iv,
        Uint8List(0),
      ),
    );
    
    final encrypted = cipher.process(utf8.encode(plaintext));
    
    // Combine salt + iv + encrypted data
    final combined = Uint8List(salt.length + iv.length + encrypted.length);
    combined.setRange(0, salt.length, salt);
    combined.setRange(salt.length, salt.length + iv.length, iv);
    combined.setRange(salt.length + iv.length, combined.length, encrypted);
    
    return base64.encode(combined);
  }
  
  // Decrypt sensitive data
  String decrypt(String ciphertext, String password) {
    final combined = base64.decode(ciphertext);
    
    // Extract components
    final salt = combined.sublist(0, saltSize ~/ 8);
    final iv = combined.sublist(saltSize ~/ 8, saltSize ~/ 8 + ivSize ~/ 8);
    final encrypted = combined.sublist(saltSize ~/ 8 + ivSize ~/ 8);
    
    final key = deriveKey(password, salt);
    
    final cipher = GCMBlockCipher(AESEngine());
    cipher.init(
      false,
      AEADParameters(
        KeyParameter(key),
        128,
        iv,
        Uint8List(0),
      ),
    );
    
    final decrypted = cipher.process(encrypted);
    return utf8.decode(decrypted);
  }
  
  Uint8List _generateSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(saltSize ~/ 8, (_) => random.nextInt(256)),
    );
  }
  
  Uint8List _generateIV() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(ivSize ~/ 8, (_) => random.nextInt(256)),
    );
  }
}

// Secure storage implementation
class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.whenUnlockedThisDeviceOnly,
      authenticationPrompt: 'Please authenticate to access your data',
    ),
  );
  
  final DataEncryption _encryption = DataEncryption();
  
  Future<void> storeSecurely(String key, String value) async {
    // Get or generate user-specific encryption key
    final encryptionKey = await _getOrCreateEncryptionKey();
    
    // Encrypt the value
    final encrypted = _encryption.encrypt(value, encryptionKey);
    
    // Store encrypted value
    await _storage.write(key: key, value: encrypted);
  }
  
  Future<String?> retrieveSecurely(String key) async {
    final encrypted = await _storage.read(key: key);
    if (encrypted == null) return null;
    
    final encryptionKey = await _getOrCreateEncryptionKey();
    return _encryption.decrypt(encrypted, encryptionKey);
  }
  
  Future<String> _getOrCreateEncryptionKey() async {
    const keyName = 'master_encryption_key';
    
    var key = await _storage.read(key: keyName);
    if (key == null) {
      // Generate new key
      final random = Random.secure();
      final bytes = List.generate(32, (_) => random.nextInt(256));
      key = base64.encode(bytes);
      await _storage.write(key: keyName, value: key);
    }
    
    return key;
  }
  
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

### Database Security
```dart
class DatabaseSecurity {
  // SQLite encryption with SQLCipher
  Future<Database> openSecureDatabase(String password) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'retirement.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      password: password, // SQLCipher encryption
      singleInstance: true,
    );
  }
  
  // Firestore security rules
  static const firestoreRules = '''
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        // Helper functions
        function isAuthenticated() {
          return request.auth != null;
        }
        
        function isOwner(userId) {
          return isAuthenticated() && request.auth.uid == userId;
        }
        
        function isProjectOwner(projectId) {
          return isAuthenticated() && 
            exists(/databases/$(database)/documents/projects/$(projectId)) &&
            get(/databases/$(database)/documents/projects/$(projectId)).data.userId == request.auth.uid;
        }
        
        function hasProjectAccess(projectId) {
          return isProjectOwner(projectId) ||
            exists(/databases/$(database)/documents/projects/$(projectId)/permissions/$(request.auth.uid));
        }
        
        // Users collection
        match /users/{userId} {
          allow read: if isOwner(userId);
          allow create: if isAuthenticated() && request.auth.uid == userId;
          allow update: if isOwner(userId) && 
            request.resource.data.keys().hasAll(['email', 'name']) &&
            request.resource.data.email == resource.data.email; // Email cannot be changed
          allow delete: if false; // Soft delete only
        }
        
        // Projects collection
        match /projects/{projectId} {
          allow read: if hasProjectAccess(projectId);
          allow create: if isAuthenticated() && 
            request.resource.data.userId == request.auth.uid;
          allow update: if isProjectOwner(projectId);
          allow delete: if isProjectOwner(projectId);
          
          // Project subcollections
          match /individuals/{individualId} {
            allow read, write: if hasProjectAccess(projectId);
          }
          
          match /permissions/{userId} {
            allow read: if hasProjectAccess(projectId);
            allow write: if isProjectOwner(projectId);
          }
        }
        
        // Assets collection
        match /assets/{projectId}/{assetId} {
          allow read, write: if hasProjectAccess(projectId);
        }
        
        // Events collection
        match /events/{projectId}/{eventId} {
          allow read, write: if hasProjectAccess(projectId);
        }
        
        // Scenarios collection
        match /scenarios/{projectId}/{scenarioId} {
          allow read, write: if hasProjectAccess(projectId);
        }
        
        // Projections collection (read-only for users)
        match /projections/{projectId}/{document=**} {
          allow read: if hasProjectAccess(projectId);
          allow write: if false; // Only cloud functions can write
        }
      }
    }
  ''';
}
```

## Network Security

### TLS/SSL Implementation
```dart
class NetworkSecurity {
  // Certificate pinning
  static Dio createSecureHttpClient() {
    final dio = Dio();
    
    // Certificate pinning for production
    if (kReleaseMode) {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
        client.badCertificateCallback = (cert, host, port) {
          // Verify certificate fingerprint
          final certFingerprint = sha256.convert(cert.der).toString();
          return _allowedCertificates.contains(certFingerprint);
        };
        return client;
      };
    }
    
    // Add security headers
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-Requested-With'] = 'XMLHttpRequest';
          options.headers['X-Frame-Options'] = 'DENY';
          options.headers['X-Content-Type-Options'] = 'nosniff';
          options.headers['X-XSS-Protection'] = '1; mode=block';
          handler.next(options);
        },
      ),
    );
    
    return dio;
  }
  
  // Certificate fingerprints (update when certificates rotate)
  static const _allowedCertificates = [
    'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
    'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
  ];
  
  // API Key management
  static String getApiKey() {
    // Never hardcode API keys
    // Use environment variables or secure configuration
    return const String.fromEnvironment('API_KEY');
  }
  
  // Request signing
  static Map<String, String> signRequest(
    String method,
    String path,
    Map<String, dynamic> params,
  ) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final nonce = _generateNonce();
    
    final message = '$method|$path|$timestamp|$nonce|${jsonEncode(params)}';
    final signature = _hmacSign(message, _getSigningKey());
    
    return {
      'X-Timestamp': timestamp,
      'X-Nonce': nonce,
      'X-Signature': signature,
    };
  }
  
  static String _generateNonce() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    return base64.encode(bytes);
  }
  
  static String _hmacSign(String message, String key) {
    final hmac = Hmac(sha256, utf8.encode(key));
    final digest = hmac.convert(utf8.encode(message));
    return digest.toString();
  }
  
  static String _getSigningKey() {
    return const String.fromEnvironment('SIGNING_KEY');
  }
}
```

## Input Validation

### Sanitization and Validation
```dart
class InputValidator {
  // Email validation
  static bool isValidEmail(String email) {
    // RFC 5322 compliant email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
    );
    
    // Additional checks
    if (!emailRegex.hasMatch(email)) return false;
    if (email.length > 254) return false; // RFC 5321
    if (email.contains('..')) return false;
    if (email.startsWith('.') || email.endsWith('.')) return false;
    
    // Check for dangerous patterns
    if (_containsSQLInjection(email)) return false;
    if (_containsXSS(email)) return false;
    
    return true;
  }
  
  // Sanitize user input
  static String sanitize(String input, {InputType type = InputType.text}) {
    var sanitized = input.trim();
    
    // Remove null bytes
    sanitized = sanitized.replaceAll('\x00', '');
    
    // HTML encode special characters
    sanitized = _htmlEncode(sanitized);
    
    // Type-specific sanitization
    switch (type) {
      case InputType.name:
        // Allow only letters, spaces, hyphens, apostrophes
        sanitized = sanitized.replaceAll(RegExp(r"[^a-zA-Z\s\-']"), '');
        break;
      case InputType.phone:
        // Keep only digits, plus, parentheses, hyphens
        sanitized = sanitized.replaceAll(RegExp(r'[^\d\+\(\)\-\s]'), '');
        break;
      case InputType.number:
        // Keep only digits and decimal point
        sanitized = sanitized.replaceAll(RegExp(r'[^\d\.]'), '');
        break;
      case InputType.alphanumeric:
        // Keep only letters and numbers
        sanitized = sanitized.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
        break;
      default:
        break;
    }
    
    return sanitized;
  }
  
  // Prevent SQL injection
  static bool _containsSQLInjection(String input) {
    final sqlPatterns = [
      RegExp(r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|ALTER|CREATE)\b)', caseSensitive: false),
      RegExp(r'(--)|(;)|(\/\*)'),
      RegExp(r'(xp_)|(sp_)', caseSensitive: false),
      RegExp(r'(EXEC|EXECUTE|CAST|DECLARE)', caseSensitive: false),
    ];
    
    return sqlPatterns.any((pattern) => pattern.hasMatch(input));
  }
  
  // Prevent XSS attacks
  static bool _containsXSS(String input) {
    final xssPatterns = [
      RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false), // Event handlers
      RegExp(r'<iframe[^>]*>', caseSensitive: false),
      RegExp(r'<object[^>]*>', caseSensitive: false),
      RegExp(r'<embed[^>]*>', caseSensitive: false),
    ];
    
    return xssPatterns.any((pattern) => pattern.hasMatch(input));
  }
  
  static String _htmlEncode(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }
  
  // File upload validation
  static bool isValidFileUpload(File file, {
    List<String>? allowedExtensions,
    int? maxSizeBytes,
  }) {
    // Check file size
    if (maxSizeBytes != null) {
      final fileSize = file.lengthSync();
      if (fileSize > maxSizeBytes) return false;
    }
    
    // Check file extension
    if (allowedExtensions != null) {
      final extension = path.extension(file.path).toLowerCase();
      if (!allowedExtensions.contains(extension)) return false;
    }
    
    // Check for executable files
    final dangerousExtensions = [
      '.exe', '.dll', '.so', '.dylib', '.app',
      '.bat', '.cmd', '.sh', '.ps1',
      '.jar', '.apk', '.ipa',
    ];
    
    final fileExtension = path.extension(file.path).toLowerCase();
    if (dangerousExtensions.contains(fileExtension)) return false;
    
    // Check magic bytes (file signature)
    final bytes = file.readAsBytesSync().take(10).toList();
    if (_isExecutable(bytes)) return false;
    
    return true;
  }
  
  static bool _isExecutable(List<int> bytes) {
    // Check for common executable signatures
    if (bytes.length >= 2) {
      // PE executable (Windows)
      if (bytes[0] == 0x4D && bytes[1] == 0x5A) return true;
      // ELF executable (Linux)
      if (bytes[0] == 0x7F && bytes[1] == 0x45) return true;
      // Mach-O executable (macOS)
      if (bytes[0] == 0xCF && bytes[1] == 0xFA) return true;
    }
    return false;
  }
}

enum InputType {
  text,
  email,
  name,
  phone,
  number,
  alphanumeric,
  url,
}
```

## Session Management

### Secure Session Handling
```dart
class SessionManager {
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const Duration refreshThreshold = Duration(minutes: 5);
  static const String sessionStorageKey = 'session_token';
  
  Timer? _sessionTimer;
  Timer? _activityTimer;
  DateTime? _lastActivity;
  
  Future<void> createSession(String token, String refreshToken) async {
    // Store tokens securely
    await _secureStorage.write(
      key: sessionStorageKey,
      value: jsonEncode({
        'access_token': token,
        'refresh_token': refreshToken,
        'created_at': DateTime.now().toIso8601String(),
      }),
    );
    
    // Start session monitoring
    _startSessionTimer();
    _monitorActivity();
    
    // Log session creation
    await _auditLog.log(
      event: 'session_created',
      timestamp: DateTime.now(),
    );
  }
  
  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(sessionTimeout, () {
      _handleSessionTimeout();
    });
  }
  
  void _monitorActivity() {
    _activityTimer?.cancel();
    _activityTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkInactivity(),
    );
  }
  
  void recordActivity() {
    _lastActivity = DateTime.now();
    
    // Refresh session if near expiry
    if (_shouldRefreshSession()) {
      _refreshSession();
    }
  }
  
  bool _shouldRefreshSession() {
    final sessionData = await _getSessionData();
    if (sessionData == null) return false;
    
    final createdAt = DateTime.parse(sessionData['created_at']);
    final timeUntilExpiry = sessionTimeout - DateTime.now().difference(createdAt);
    
    return timeUntilExpiry <= refreshThreshold;
  }
  
  Future<void> _refreshSession() async {
    final sessionData = await _getSessionData();
    if (sessionData == null) return;
    
    try {
      final response = await _authApi.refreshToken(
        sessionData['refresh_token'],
      );
      
      await createSession(
        response.accessToken,
        response.refreshToken,
      );
    } catch (e) {
      // Refresh failed, force re-authentication
      await destroySession();
    }
  }
  
  void _checkInactivity() {
    if (_lastActivity == null) return;
    
    final inactivityDuration = DateTime.now().difference(_lastActivity!);
    if (inactivityDuration > const Duration(minutes: 15)) {
      _showInactivityWarning();
    }
    
    if (inactivityDuration > const Duration(minutes: 20)) {
      _handleSessionTimeout();
    }
  }
  
  void _handleSessionTimeout() {
    destroySession();
    _showSessionExpiredDialog();
  }
  
  Future<void> destroySession() async {
    // Clear timers
    _sessionTimer?.cancel();
    _activityTimer?.cancel();
    
    // Clear stored session
    await _secureStorage.delete(key: sessionStorageKey);
    
    // Clear memory
    _lastActivity = null;
    
    // Log session destruction
    await _auditLog.log(
      event: 'session_destroyed',
      timestamp: DateTime.now(),
    );
    
    // Navigate to login
    _navigator.pushReplacementNamed('/login');
  }
  
  Future<Map<String, dynamic>?> _getSessionData() async {
    final data = await _secureStorage.read(key: sessionStorageKey);
    if (data == null) return null;
    return jsonDecode(data);
  }
}
```

## Security Monitoring

### Audit Logging
```dart
class AuditLogger {
  static const List<String> sensitiveEvents = [
    'login',
    'logout',
    'password_change',
    'permission_change',
    'data_export',
    'data_deletion',
    'payment',
    'mfa_disabled',
  ];
  
  Future<void> log({
    required String event,
    String? userId,
    Map<String, dynamic>? metadata,
    String? ipAddress,
    String? userAgent,
    SecurityLevel level = SecurityLevel.info,
  }) async {
    final logEntry = {
      'event': event,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'user_id': userId ?? await _getCurrentUserId(),
      'session_id': await _getSessionId(),
      'ip_address': ipAddress ?? await _getIpAddress(),
      'user_agent': userAgent ?? await _getUserAgent(),
      'metadata': metadata,
      'level': level.toString(),
    };
    
    // Store locally first (for offline support)
    await _localDb.insert('audit_logs', logEntry);
    
    // Send to server
    try {
      await _api.sendAuditLog(logEntry);
    } catch (e) {
      // Queue for later sending
      await _queueManager.enqueue(logEntry);
    }
    
    // Alert on sensitive events
    if (sensitiveEvents.contains(event)) {
      await _sendSecurityAlert(logEntry);
    }
    
    // Check for anomalies
    _anomalyDetector.analyze(logEntry);
  }
  
  Future<void> _sendSecurityAlert(Map<String, dynamic> logEntry) async {
    if (logEntry['level'] == SecurityLevel.critical.toString()) {
      // Immediate notification
      await _notificationService.sendCriticalAlert(
        'Critical security event: ${logEntry['event']}',
        logEntry,
      );
    }
  }
}

enum SecurityLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

// Anomaly detection
class AnomalyDetector {
  void analyze(Map<String, dynamic> logEntry) {
    // Check for suspicious patterns
    _checkBruteForce(logEntry);
    _checkUnusualLocation(logEntry);
    _checkUnusualTime(logEntry);
    _checkRapidActions(logEntry);
  }
  
  void _checkBruteForce(Map<String, dynamic> logEntry) {
    if (logEntry['event'] != 'login_failed') return;
    
    final userId = logEntry['user_id'];
    final recentFailures = await _getRecentLoginFailures(userId);
    
    if (recentFailures.length >= 5) {
      await _auditLogger.log(
        event: 'brute_force_detected',
        userId: userId,
        level: SecurityLevel.warning,
        metadata: {'failure_count': recentFailures.length},
      );
      
      // Lock account
      await _accountService.lockAccount(userId);
    }
  }
  
  void _checkUnusualLocation(Map<String, dynamic> logEntry) {
    final ipAddress = logEntry['ip_address'];
    final userId = logEntry['user_id'];
    
    final location = await _geoIpService.getLocation(ipAddress);
    final userLocations = await _getUserLocationHistory(userId);
    
    if (!_isNormalLocation(location, userLocations)) {
      await _auditLogger.log(
        event: 'unusual_location_detected',
        userId: userId,
        level: SecurityLevel.warning,
        metadata: {
          'location': location.toJson(),
          'ip': ipAddress,
        },
      );
      
      // Require additional verification
      await _mfaService.requireVerification(userId);
    }
  }
}
```

## Security Headers

### HTTP Security Headers
```dart
class SecurityHeaders {
  static Map<String, String> getSecurityHeaders() {
    return {
      // Prevent clickjacking
      'X-Frame-Options': 'DENY',
      'Content-Security-Policy': "frame-ancestors 'none'",
      
      // Prevent MIME type sniffing
      'X-Content-Type-Options': 'nosniff',
      
      // Enable XSS protection
      'X-XSS-Protection': '1; mode=block',
      
      // Content Security Policy
      'Content-Security-Policy': _getCSP(),
      
      // Strict Transport Security
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains; preload',
      
      // Referrer Policy
      'Referrer-Policy': 'strict-origin-when-cross-origin',
      
      // Permissions Policy
      'Permissions-Policy': _getPermissionsPolicy(),
    };
  }
  
  static String _getCSP() {
    return [
      "default-src 'self'",
      "script-src 'self' 'unsafe-inline' https://apis.google.com",
      "style-src 'self' 'unsafe-inline'",
      "img-src 'self' data: https:",
      "font-src 'self' data:",
      "connect-src 'self' https://api.example.com wss://ws.example.com",
      "frame-src 'none'",
      "object-src 'none'",
      "media-src 'self'",
      "worker-src 'self'",
      "form-action 'self'",
      "base-uri 'self'",
      "manifest-src 'self'",
      "upgrade-insecure-requests",
    ].join('; ');
  }
  
  static String _getPermissionsPolicy() {
    return [
      'accelerometer=()',
      'camera=()',
      'geolocation=()',
      'gyroscope=()',
      'magnetometer=()',
      'microphone=()',
      'payment=()',
      'usb=()',
    ].join(', ');
  }
}
```

## Compliance

### PIPEDA Compliance (Canadian Privacy)
```dart
class PrivacyCompliance {
  // Consent management
  Future<bool> hasConsent(String userId, ConsentType type) async {
    final consent = await _db.query(
      'consents',
      where: 'user_id = ? AND type = ?',
      whereArgs: [userId, type.toString()],
    );
    
    return consent.isNotEmpty;
  }
  
  Future<void> recordConsent(
    String userId,
    ConsentType type,
    bool granted,
  ) async {
    await _db.insert('consents', {
      'user_id': userId,
      'type': type.toString(),
      'granted': granted,
      'timestamp': DateTime.now().toIso8601String(),
      'ip_address': await _getIpAddress(),
    });
  }
  
  // Data portability
  Future<File> exportUserData(String userId) async {
    final userData = await _collectUserData(userId);
    final json = jsonEncode(userData);
    
    // Encrypt the export
    final encrypted = await _encryption.encrypt(json, userId);
    
    final file = File('${await getTemporaryDirectory()}/export_$userId.json');
    await file.writeAsString(encrypted);
    
    // Log the export
    await _auditLogger.log(
      event: 'data_exported',
      userId: userId,
      level: SecurityLevel.info,
    );
    
    return file;
  }
  
  // Right to deletion
  Future<void> deleteUserData(String userId) async {
    // Soft delete first
    await _db.update(
      'users',
      {'deleted': true, 'deleted_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    // Schedule hard delete after retention period
    await _scheduler.schedule(
      DateTime.now().add(const Duration(days: 30)),
      () => _permanentlyDelete(userId),
    );
    
    // Log deletion request
    await _auditLogger.log(
      event: 'deletion_requested',
      userId: userId,
      level: SecurityLevel.warning,
    );
  }
}

enum ConsentType {
  dataCollection,
  marketing,
  analytics,
  thirdPartySharing,
}
```

## Security Checklist

### Development
- [ ] Use latest stable Flutter version
- [ ] Keep all dependencies updated
- [ ] Enable all linting rules
- [ ] Use static code analysis
- [ ] Implement proper error handling
- [ ] No hardcoded secrets
- [ ] No debug logs in production

### Authentication
- [ ] Strong password requirements
- [ ] Account lockout after failed attempts
- [ ] Multi-factor authentication
- [ ] Biometric authentication option
- [ ] Secure session management
- [ ] Token expiration and refresh

### Data Protection
- [ ] Encryption at rest
- [ ] Encryption in transit
- [ ] Secure key management
- [ ] Input validation and sanitization
- [ ] Output encoding
- [ ] SQL injection prevention
- [ ] XSS prevention

### Network
- [ ] TLS 1.3 minimum
- [ ] Certificate pinning
- [ ] API authentication
- [ ] Rate limiting
- [ ] Request signing
- [ ] Secure headers

### Privacy
- [ ] Consent management
- [ ] Data minimization
- [ ] Purpose limitation
- [ ] Data portability
- [ ] Right to deletion
- [ ] Privacy policy

### Monitoring
- [ ] Audit logging
- [ ] Security alerts
- [ ] Anomaly detection
- [ ] Incident response plan
- [ ] Regular security audits
- [ ] Penetration testing

---

*Version: 1.0*
*Last Updated: November 2024*
*Security Review: Required Quarterly*
