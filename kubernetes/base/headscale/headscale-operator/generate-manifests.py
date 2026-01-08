#!/usr/bin/env python3
"""
Generate and fix headscale-operator manifests from Helm chart.

This script pulls the Helm chart, generates manifests, and fixes duplicate
label keys that cause kustomize build failures.
"""

import subprocess
import sys
import re
from pathlib import Path


CHART_VERSION = "0.1.3"
CHART_REPO = "oci://ghcr.io/infradohq/headscale-operator/charts/headscale-operator"
OUTPUT_FILE = "operator-manifests.yaml"


def run_helm_template():
    """Run helm template to generate manifests."""
    print(f"Generating manifests from Helm chart version {CHART_VERSION}...")

    cmd = [
        "helm", "template", "headscale-operator",
        CHART_REPO,
        "--version", CHART_VERSION,
        "--namespace", "headscale",
        "--set", "namespace=headscale",
        "--include-crds",
    ]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error running helm template: {e}", file=sys.stderr)
        print(f"stderr: {e.stderr}", file=sys.stderr)
        sys.exit(1)


def fix_duplicate_labels(yaml_content):
    """
    Fix duplicate label keys in YAML metadata.

    The upstream Helm chart has a bug where it defines some labels twice:
    - app.kubernetes.io/managed-by: Helm
    - app.kubernetes.io/managed-by: helm (duplicate, lowercase)
    - app.kubernetes.io/name: headscale-operator (appears twice)

    This function removes duplicates by keeping only the first occurrence.
    """
    print("Fixing duplicate label keys...")

    lines = yaml_content.split('\n')
    output_lines = []
    in_labels = False
    seen_labels = set()
    indent_level = 0

    for line in lines:
        # Detect when we enter a labels section
        if re.match(r'^(\s*)labels:\s*$', line):
            in_labels = True
            seen_labels = set()
            # Get indentation level of the labels: line
            indent_level = len(line) - len(line.lstrip())
            output_lines.append(line)
            continue

        # Exit labels section when we hit a line at same or lower indentation
        if in_labels and line and not line[0].isspace():
            in_labels = False
            seen_labels = set()
        elif in_labels and line.strip():
            current_indent = len(line) - len(line.lstrip())
            if current_indent <= indent_level:
                in_labels = False
                seen_labels = set()

        # Process label lines
        if in_labels:
            # Extract label key
            match = re.match(r'\s+([^:]+):', line)
            if match:
                label_key = match.group(1).strip()

                # Skip if we've already seen this label key
                if label_key in seen_labels:
                    continue

                seen_labels.add(label_key)

        output_lines.append(line)

    return '\n'.join(output_lines)


def main():
    """Main function."""
    script_dir = Path(__file__).parent
    output_path = script_dir / OUTPUT_FILE

    # Generate manifests from Helm
    manifests = run_helm_template()

    # Fix duplicate labels
    fixed_manifests = fix_duplicate_labels(manifests)

    # Write to file
    output_path.write_text(fixed_manifests)

    # Count resources
    resource_count = fixed_manifests.count('\nkind:')

    print(f"✓ Manifests generated successfully: {OUTPUT_FILE}")
    print(f"✓ Total resources: {resource_count}")
    print(f"✓ Fixed duplicate label keys")


if __name__ == "__main__":
    main()
