#!/bin/bash

echo "🔍 Scanning insecure-app... (This might take a minute to download the vulnerability database)"
echo "=========================================" > trivy_report.txt
echo "   TARGET 1: INSECURE IMAGE (node:20)    " >> trivy_report.txt
echo "=========================================" >> trivy_report.txt
trivy image insecure-app >> trivy_report.txt

echo "🛡️ Scanning hardened-app..."
echo -e "\n\n=========================================" >> trivy_report.txt
echo "TARGET 2: HARDENED IMAGE (node:20-alpine)" >> trivy_report.txt
echo "=========================================" >> trivy_report.txt
trivy image hardened-app >> trivy_report.txt

echo "✅ Scans complete!"
echo "📄 Your results have been safely saved to: trivy_report.txt"