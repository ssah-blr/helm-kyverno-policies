#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_DIR="$ROOT_DIR/templates"

echo "Running Kyverno policy tests..."
echo

FAILURES=0

for policy_dir in "$TEMPLATES_DIR"/*; do
  if [[ -d "$policy_dir/tests" ]]; then

    POLICY_NAME=$(basename "$policy_dir")
    TEST_SRC="$policy_dir/tests"

    echo "========================================="
    echo "Testing policy: $POLICY_NAME"
    echo "========================================="

    TMP_DIR=$(mktemp -d)

    # Render helm policy
    helm template test "$ROOT_DIR" \
      | yq "select(.kind == \"ClusterPolicy\" and .metadata.name == \"$POLICY_NAME\")" \
      > "$TMP_DIR/policy.yaml"

    cp "$TEST_SRC/resources.yaml" "$TMP_DIR/"

    # Extract results from original test
    yq '.results' "$TEST_SRC/kyverno-test.yaml" > "$TMP_DIR/results.yaml"

    # Create new test file
    cat > "$TMP_DIR/kyverno-test.yaml" <<EOF
apiVersion: cli.kyverno.io/v1alpha1
kind: Test
metadata:
  name: ${POLICY_NAME}-test
policies:
  - policy.yaml
resources:
  - resources.yaml
results:
EOF

    cat "$TMP_DIR/results.yaml" >> "$TMP_DIR/kyverno-test.yaml"

    pushd "$TMP_DIR" >/dev/null

    if kyverno test .; then
      echo "✅ $POLICY_NAME tests PASSED"
    else
      echo "❌ $POLICY_NAME tests FAILED"
      FAILURES=$((FAILURES+1))
    fi

    popd >/dev/null

    rm -rf "$TMP_DIR"

    echo
  fi
done

echo "========================================="

if [[ "$FAILURES" -eq 0 ]]; then
  echo "All policy tests PASSED 🎉"
else
  echo "$FAILURES policy test(s) FAILED ❌"
  exit 1
fi
