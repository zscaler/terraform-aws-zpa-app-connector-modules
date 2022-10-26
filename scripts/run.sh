#!/usr/bin/bash

# run.sh - Run the usual pre-commit checks.

set -euo pipefail

brew install pre-commit
pre-commit install
pre-commit autoupdate
pre-commit run --all-files terraform_fmt
pre-commit run --all-files terraform_docs
pre-commit run --all-files terraform_tflint
pre-commit run --all-files check-merge-conflict
pre-commit run --all-files end-of-file-fixer
pre-commit run --all-files zscaler-iac-scanner
