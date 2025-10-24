#!/usr/bin/env bash
set -euo pipefail
terraform validate
terraform apply -auto-approve
