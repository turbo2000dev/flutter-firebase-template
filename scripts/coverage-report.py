#!/usr/bin/env python3
"""
Coverage Report Generator (Excluding Generated Files)

This script analyzes coverage/lcov.info and provides accurate coverage metrics
by excluding generated files (.g.dart, .freezed.dart).

Usage:
    python3 scripts/coverage-report.py
    python3 scripts/coverage-report.py --json  # Output as JSON
    python3 scripts/coverage-report.py --ci    # CI mode (exit code based on thresholds)
"""

import sys
import json
import os

# Coverage targets
TARGETS = {
    'overall': 80,
    'domain': 95,
    'data': 90,
    'application': 85,
    'presentation': 70,
    'services': 80,
    'core': 80,
}

def parse_lcov(filepath='coverage/lcov.info'):
    """Parse lcov.info file and calculate coverage by layer."""
    if not os.path.exists(filepath):
        print(f"Error: {filepath} not found. Run 'flutter test --coverage' first.")
        sys.exit(1)

    with open(filepath, 'r') as f:
        content = f.read()

    files = content.split('SF:')

    # Track totals
    results = {
        'total': {'lines': 0, 'hit': 0},
        'generated': {'lines': 0, 'hit': 0},
        'domain': {'lines': 0, 'hit': 0},
        'data': {'lines': 0, 'hit': 0},
        'application': {'lines': 0, 'hit': 0},
        'presentation': {'lines': 0, 'hit': 0},
        'services': {'lines': 0, 'hit': 0},
        'core': {'lines': 0, 'hit': 0},
        'other': {'lines': 0, 'hit': 0},
    }

    for file_block in files[1:]:  # Skip first empty split
        lines = file_block.split('\n')
        filename = lines[0] if lines else ''

        lf_match = [l for l in lines if l.startswith('LF:')]
        lh_match = [l for l in lines if l.startswith('LH:')]

        if lf_match and lh_match:
            lf = int(lf_match[0].split(':')[1])
            lh = int(lh_match[0].split(':')[1])

            # Check if generated file
            is_generated = '.g.dart' in filename or '.freezed.dart' in filename

            if is_generated:
                results['generated']['lines'] += lf
                results['generated']['hit'] += lh
            else:
                results['total']['lines'] += lf
                results['total']['hit'] += lh

                # Categorize by layer
                if '/domain/' in filename:
                    results['domain']['lines'] += lf
                    results['domain']['hit'] += lh
                elif '/data/' in filename:
                    results['data']['lines'] += lf
                    results['data']['hit'] += lh
                elif '/application/' in filename:
                    results['application']['lines'] += lf
                    results['application']['hit'] += lh
                elif '/presentation/' in filename:
                    results['presentation']['lines'] += lf
                    results['presentation']['hit'] += lh
                elif '/services/' in filename:
                    results['services']['lines'] += lf
                    results['services']['hit'] += lh
                elif '/core/' in filename:
                    results['core']['lines'] += lf
                    results['core']['hit'] += lh
                else:
                    results['other']['lines'] += lf
                    results['other']['hit'] += lh

    return results


def calculate_coverage(data):
    """Calculate coverage percentage."""
    if data['lines'] == 0:
        return 0.0
    return (data['hit'] / data['lines']) * 100


def print_report(results):
    """Print formatted coverage report."""
    print("=" * 70)
    print("COVERAGE REPORT (EXCLUDING GENERATED FILES)")
    print("=" * 70)
    print()
    print(f"Generated files excluded: .g.dart, .freezed.dart")
    print(f"Generated lines excluded: {results['generated']['lines']:,}")
    print()

    # Overall
    overall_cov = calculate_coverage(results['total'])
    overall_status = "PASS" if overall_cov >= TARGETS['overall'] else "FAIL"
    print("-" * 70)
    print("OVERALL COVERAGE")
    print("-" * 70)
    print(f"Lines Hit:    {results['total']['hit']:,}")
    print(f"Total Lines:  {results['total']['lines']:,}")
    print(f"Coverage:     {overall_cov:.1f}% (Target: {TARGETS['overall']}%) [{overall_status}]")
    print()

    # By layer
    print("-" * 70)
    print("COVERAGE BY LAYER")
    print("-" * 70)
    print(f"{'Layer':<15} {'Hit':>8} {'Total':>8} {'Coverage':>10} {'Target':>10} {'Status':>8}")
    print("-" * 70)

    layers = ['domain', 'data', 'application', 'presentation', 'services', 'core', 'other']

    for layer in layers:
        data = results[layer]
        if data['lines'] > 0:
            cov = calculate_coverage(data)
            target = TARGETS.get(layer, 80)
            if cov >= target:
                status = "PASS"
            elif cov >= target - 10:
                status = "WARN"
            else:
                status = "FAIL"
            print(f"{layer:<15} {data['hit']:>8,} {data['lines']:>8,} {cov:>9.1f}% {target:>9}% {status:>8}")

    print()
    print("=" * 70)

    return overall_cov


def print_json(results):
    """Print coverage results as JSON."""
    output = {
        'overall': {
            'coverage': calculate_coverage(results['total']),
            'hit': results['total']['hit'],
            'lines': results['total']['lines'],
            'target': TARGETS['overall'],
        },
        'generated_excluded': results['generated']['lines'],
        'layers': {}
    }

    for layer in ['domain', 'data', 'application', 'presentation', 'services', 'core', 'other']:
        data = results[layer]
        if data['lines'] > 0:
            output['layers'][layer] = {
                'coverage': round(calculate_coverage(data), 1),
                'hit': data['hit'],
                'lines': data['lines'],
                'target': TARGETS.get(layer, 80),
            }

    print(json.dumps(output, indent=2))
    return output['overall']['coverage']


def main():
    results = parse_lcov()

    if '--json' in sys.argv:
        overall_cov = print_json(results)
    else:
        overall_cov = print_report(results)

    # CI mode: exit with error if below threshold
    if '--ci' in sys.argv:
        if overall_cov < TARGETS['overall']:
            print(f"\nCI FAILURE: Coverage {overall_cov:.1f}% is below target {TARGETS['overall']}%")
            sys.exit(1)
        else:
            print(f"\nCI SUCCESS: Coverage {overall_cov:.1f}% meets target {TARGETS['overall']}%")
            sys.exit(0)


if __name__ == '__main__':
    main()
