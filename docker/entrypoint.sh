#!/bin/bash

set -e

/scripts/init-cacti.sh

echo "Starting Apache..."

exec apache2-foreground

