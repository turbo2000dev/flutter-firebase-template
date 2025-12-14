# Performance Optimization

**Description:** Analyze and optimize application performance using the Performance agent to ensure smooth 60fps, fast load times, and efficient resource usage.

---

You are analyzing and optimizing application performance to deliver excellent user experience.

## Usage

```bash
/optimize [optional: specific feature or aspect to optimize]
```

## Workflow

### Phase 1: Scope Definition

Determine optimization scope:

**Full Application:**
- Overall app performance
- Startup time
- Memory usage
- All screens and features

**Feature-Specific:**
- Specific feature or screen
- Targeted optimization
- Known performance issue

**Aspect-Specific:**
- Rendering performance (frame rate)
- Memory optimization
- Network efficiency
- Database performance

Ask user for scope and any known issues.

---

### Phase 2: Performance Analysis

Launch the **Performance Agent** to analyze performance:

1. First, read the performance agent definition:
```
Read .claude/agents/performance.md
```

2. Then launch the agent with the full context:
```
Use the Task tool:
- Description: "Performance optimization of [SCOPE]"
- Subagent: "general-purpose"
- Prompt: Include the FULL content from .claude/agents/performance.md, then add:
  "Now analyze and optimize performance for [SCOPE].
  Measure against targets: 60fps frame rate, <100MB memory, <3s initial load.
  Provide your detailed performance report following the format specified in your agent definition.
  Scope: [SCOPE_DESCRIPTION]"
```

**Wait for performance agent to complete** and review the performance report.

---

### Phase 3: Automated Performance Checks

Run automated performance analysis:

```bash
echo "=== Automated Performance Checks ==="

# 1. Check for missed const opportunities
echo -e "\n1. Checking for missed const optimizations..."
grep -r "class.*extends StatelessWidget" --include="*.dart" lib/ -A 3 | grep -v "const.*({super.key})" | wc -l | xargs echo "StatelessWidgets without const constructor:"

# 2. Find potential large build methods
echo -e "\n2. Checking for large build methods..."
echo "(Checking for build methods > 100 lines...)"
for file in $(find lib -name "*.dart"); do
  awk '/Widget build\(/ {start=NR} start && NR-start>100 {print FILENAME":"start" - Large build method"; exit}' "$file"
done

# 3. Check for missing RepaintBoundary in lists
echo -e "\n3. Checking for RepaintBoundary in lists..."
grep -r "ListView.builder" --include="*.dart" lib/ | wc -l | xargs echo "ListView.builder instances found:"
grep -r "RepaintBoundary" --include="*.dart" lib/ | wc -l | xargs echo "RepaintBoundary instances found:"

# 4. Check for missing disposal
echo -e "\n4. Checking for missing disposal..."
grep -r "Controller()" --include="*.dart" lib/ | wc -l | xargs echo "Controllers created:"
grep -r "dispose()" --include="*.dart" lib/ | wc -l | xargs echo "Dispose calls found:"

# 5. Check for unoptimized images
echo -e "\n5. Checking for unoptimized images..."
grep -r "Image.network" --include="*.dart" lib/ | grep -v "cacheWidth" | wc -l | xargs echo "Unoptimized network images:"

# 6. Check for missing pagination
echo -e "\n6. Checking for pagination..."
grep -r "\.query\(" --include="*.dart" lib/ | grep -v "limit:" | wc -l | xargs echo "Queries without limit:"

# 7. Check asset sizes
echo -e "\n7. Checking asset sizes..."
find assets -type f -size +500k -exec ls -lh {} \; | awk '{print $5, $9}' || echo "No large assets found"

echo -e "\n=== Performance Checks Complete ===\n"
```

---

### Phase 4: Build Size Analysis

Analyze application bundle size:

```bash
echo "=== Build Size Analysis ==="

# Build and analyze APK size
echo "Building and analyzing APK size..."
flutter build apk --release --analyze-size --target-platform android-arm64

# Show largest contributors
echo -e "\nLargest code contributors:"
# (Analysis output will show)

echo -e "\n=== Build Size Analysis Complete ===\n"
```

---

### Phase 5: Performance Report

Provide comprehensive performance report to user:

```markdown
# Performance Optimization Report

## Performance Summary

**Overall Performance:** 🔴 Needs Improvement / 🟡 Acceptable / 🟢 Good / ✅ Excellent

**Metrics Against Targets:**

| Metric                  | Current | Target    | Status |
|------------------------|---------|-----------|--------|
| Frame Rate             | X fps   | 60 fps    | 🟢/🟡/🔴 |
| Initial Load Time      | X.Xs    | <3s       | 🟢/🟡/🔴 |
| Time to Interactive    | X.Xs    | <5s       | 🟢/🟡/🔴 |
| Memory (Active)        | XMB     | <100MB    | 🟢/🟡/🔴 |
| Memory (Idle)          | XMB     | <50MB     | 🟢/🟡/🔴 |
| APK Size               | XMB     | <15MB     | 🟢/🟡/🔴 |

**Issues Found:**
- 🔴 Critical: X (Severe performance impact)
- 🟡 High Priority: X (Noticeable impact)
- 🟢 Medium Priority: X (Minor impact)
- ℹ️ Optimizations: X (Nice to have)

---

## Critical Performance Issues 🔴

### 1. [Issue Title]

**Severity:** Critical
**Location:** `file.dart:line`
**Category:** Rendering / Memory / Network / Database

**Issue Description:**
[What the performance problem is]

**Impact:**
- User Experience: [Description of UX impact]
- Frame Time: Xms (target: <16.67ms)
- Memory: +XMB overhead
- Jank: X frames dropped

**Measurements:**
```
Before Optimization:
- Frame rendering: Xms
- Memory usage: XMB
- User-perceived lag: Xms

Performance Budget:
- Target frame time: 16.67ms
- Frames dropped: X
```

**Root Cause:**
[Why this performance issue exists]

**Optimization Applied:**

**Priority:** Immediate

```dart
// Before (slow)
[problematic code]

// After (optimized)
[optimized code]
```

**Expected Improvement:**
- Frame time: -Xms
- Memory: -XMB
- User experience: [improvement description]

**Verification:**
[How to measure the improvement]

---

## High Priority Issues 🟡

[List high-impact performance issues]

---

## Medium Priority Optimizations 🟢

[List moderate performance improvements]

---

## Applied Optimizations ✅

### 1. Added Const Constructors (X widgets)
```
Impact:
- Reduced rebuild time: -X%
- Memory savings: -XMB
- Improved frame rate: +X fps
```

### 2. Implemented RepaintBoundary (X locations)
```
Impact:
- Reduced repaint cost: -X%
- Smoother scrolling: +X fps
- Better list performance
```

### 3. Optimized Image Loading (X images)
```
Impact:
- Memory usage: -XMB
- Faster loading: -X%
- Better caching
```

### 4. Added Pagination (X queries)
```
Impact:
- Reduced query time: -Xms
- Lower memory: -XMB
- Better UX for large datasets
```

### 5. State Management Optimization
```
Impact:
- Reduced rebuilds: -X%
- Improved responsiveness
- Lower CPU usage
```

---

## Performance Profiling Results

### Rendering Performance
```
Frame Statistics:
- Average frame time: Xms
- 99th percentile: Xms
- Frames dropped: X
- Build time: Xms
- Layout time: Xms
- Paint time: Xms

Widget Stats:
- Total widgets: X
- Rebuilt per frame: X
- Const widgets: X (X%)
```

### Memory Performance
```
Memory Usage:
- Active memory: XMB
- Idle memory: XMB
- Heap size: XMB
- Image cache: XMB (X images)
- GC frequency: X/second
- GC pause time: Xms avg
```

### Network Performance
```
API Calls:
- Average latency: Xms
- Cached responses: X%
- Failed requests: X
- Concurrent requests: X
- Total data transferred: XMB
```

### Database Performance
```
Query Performance:
- Average query time: Xms
- Slowest query: Xms
- Queries per second: X
- Cache hit rate: X%
```

### Startup Performance
```
App Initialization:
- Time to first frame: Xms
- Time to interactive: Xms
- Dependencies loaded: X
- Assets loaded: X
```

---

## Hot Spots Identified

**Top 5 Performance Bottlenecks:**

1. **[Method/Widget Name]** - Xms per call
   - Location: `file.dart:line`
   - Issue: [Description]
   - Optimization: [What was done]

2. **[Method/Widget Name]** - Xms per call
   - Location: `file.dart:line`
   - Issue: [Description]
   - Optimization: [What was done]

[Continue for top 5]

---

## Bundle Size Analysis

```
Total APK Size: XMB

Size Breakdown:
- Code: XMB (X%)
- Assets: XMB (X%)
- Native libraries: XMB (X%)
- Resources: XMB (X%)

Largest Contributors:
1. [Package/Asset]: XMB
2. [Package/Asset]: XMB
3. [Package/Asset]: XMB

Optimization Opportunities:
- [Recommendation for size reduction]
```

---

## Recommendations

### Immediate Actions (Critical)
1. [Action to fix critical performance issue]
2. [Action to fix critical performance issue]

### Short-term Improvements (High Priority)
1. [Performance optimization task]
2. [Performance optimization task]

### Long-term Optimizations (Medium Priority)
1. [Architectural improvement for performance]
2. [Infrastructure improvement]

### Best Practices Going Forward
1. [Practice to maintain performance]
2. [Practice to prevent regressions]

---

## Performance Monitoring Setup

### Recommended Monitoring
```dart
// Add to app initialization
void setupPerformanceMonitoring() {
  // Track frame rendering
  WidgetsBinding.instance.addPersistentFrameCallback((_) {
    // Monitor frame times
  });

  // Track memory usage
  Timer.periodic(Duration(minutes: 1), (_) {
    final memory = ProcessInfo.currentRss;
    analytics.logPerformance('memory_usage', memory);
  });

  // Track slow operations
  Future<T> trackOperation<T>(String name, Future<T> Function() op) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await op();
    } finally {
      stopwatch.stop();
      if (stopwatch.elapsedMilliseconds > 100) {
        analytics.logPerformance('slow_operation', {
          'name': name,
          'duration': stopwatch.elapsedMilliseconds,
        });
      }
    }
  }
}
```

---

## Before/After Comparison

### Key Metrics Improvement

| Metric              | Before  | After   | Change |
|--------------------|---------|---------|--------|
| Frame Rate         | X fps   | X fps   | +X%    |
| Memory Usage       | XMB     | XMB     | -X%    |
| Initial Load       | X.Xs    | X.Xs    | -X%    |
| Bundle Size        | XMB     | XMB     | -X%    |

### User Experience Impact
- Smoother scrolling: [improvement description]
- Faster loading: [improvement description]
- Better responsiveness: [improvement description]
- Reduced battery drain: [improvement description]

---

## Testing Performed

- [ ] Manual testing on low-end device
- [ ] Manual testing on high-end device
- [ ] Performance profiling with DevTools
- [ ] Memory leak testing
- [ ] Network throttling testing (3G simulation)
- [ ] Battery usage testing

---

## Next Steps

1. **Verify Improvements**
   - Test optimized code manually
   - Run performance profiling again
   - Measure metrics on real devices

2. **Deploy Gradually**
   - Test in development environment
   - Deploy to staging
   - Monitor performance metrics
   - Roll out to production

3. **Continuous Monitoring**
   - Set up performance alerts
   - Track metrics over time
   - Watch for regressions
   - Regular performance audits

```

---

### Phase 6: Verification

After optimizations applied, verify improvements:

```bash
# Run app in profile mode for testing
flutter run --profile

# Open DevTools for verification
# Check Performance, Memory, and Network tabs
echo "Open DevTools to verify performance improvements"
echo "flutter pub global run devtools"
```

---

## When to Use

Use `/optimize` for:
- Reported performance issues
- Before major releases
- After implementing complex features
- When adding heavy UI/animations
- Periodically (monthly) for maintenance
- After user complaints about lag
- Before performance benchmarking

---

## Optimization Scope Options

```bash
# Full application optimization
/optimize

# Feature-specific optimization
/optimize features/projections

# Aspect-specific optimization
/optimize --rendering
/optimize --memory
/optimize --network
/optimize --startup

# Quick optimization pass
/optimize --quick
```

---

## Performance Targets

Always optimize toward these targets:
- **60fps** frame rate (16.67ms per frame)
- **<3s** initial load time
- **<5s** time to interactive
- **<100MB** active memory
- **<50MB** idle memory
- **<15MB** APK size

---

This command ensures the application delivers excellent performance and smooth user experience across all devices.
