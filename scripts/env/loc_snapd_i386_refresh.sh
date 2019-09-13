#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export ARCH=${ARCH:-"i386"}
export CHANNEL=${CHANNEL:-"stable"}
export CORE_CHANNEL=${CORE_CHANNEL:-"beta"}
export REGISTER_EMAIL=${REGISTER_EMAIL:-"sergio.cazzolato@canonical.com"}

export SPREAD_SETUP=${SPREAD_SETUP:-"external:ubuntu-core-16-32:tasks/setup/"}
export SPREAD_SETUP_PARAMS=${SPREAD_SETUP_PARAMS:-"-reuse"}

export PROJECT=${PROJECT:-"snapd"}
export PROJECT_URL=${PROJECT_URL:-$SNAPD_URL}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-32:tests/"}
export SPREAD_TESTS_PARAMS=${SPREAD_TESTS_PARAMS:-""}
export SPREAD_TESTS_SKIP=${SPREAD_TESTS_SKIP:-"tests/main/auto-refresh,tests/main/auto-refresh-retry"}

export IMAGE_URL=${IMAGE_URL:-"https://cachio.s3.amazonaws.com/images/pc-i386-16-stable-core_beta/pc.img.xz"}
export USER_ASSERTION_URL=https://cachio.s3.amazonaws.com/images/assertions/auto-import.assert
export VM_PORT=${VM_PORT:-8025}