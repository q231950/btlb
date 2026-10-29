#!/bin/sh

# Diagnostics for the Paper Swift Package when xcodebuild failed, e.g. when Paper.swift cannot
# find RustBuffer
if [ "$CI_XCODEBUILD_EXIT_CODE" = "0" ]; then
    exit 0
fi

derived_data="${CI_DERIVED_DATA_PATH:-/Volumes/workspace/DerivedData}"

echo "=== Paper build diagnostics ==="
echo "--- XCFramework headers copied to include"
find "$derived_data" -path "*/include/*" \( -iname "*.modulemap" -o -iname "*FFI.h" \) -print

echo "--- Build issues"
build_results=$(mktemp)
xcrun xcresulttool get build-results --path "$CI_RESULT_BUNDLE_PATH" > "$build_results"
python3 - "$build_results" <<'EOF'
import json
import sys

with open(sys.argv[1]) as file:
    results = json.load(file)

print(f"errors: {results.get('errorCount')}, warnings: {results.get('warningCount')}")
for error in results.get("errors", [])[:200]:
    print("error:", error.get("message"), error.get("sourceURL", ""))
for warning in results.get("warnings", []):
    text = f"{warning.get('message')} {warning.get('sourceURL', '')}"
    if any(key in text for key in ("PaperFFI", "RustFramework", "module", "Paper.swift")):
        print("warning:", text)
EOF

echo "--- Swift compiler flags for modules and include paths"
find "$derived_data/Logs/Build" -name "*.xcactivitylog" | while read -r log; do
    gunzip -c "$log" | strings | grep -E -o "(-explicit-module-build|-I [^ ]*include[^ ]*|-fmodule-map-file=[^ ]*)" | sort | uniq -c
done
echo "=== End of Paper build diagnostics ==="
