#!/bin/bash
echo "🚀 Starting NIZOM GLOBAL Production Quality Cycle..."
python3 tools/static_check.py
python3 tools/targeted_regression_check.py
python3 tools/check_version.py
echo "✅ Quality Cycle Finished!"
