#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export ARCH=${ARCH:-"arm64"}
export PROJECT=${PROJECT:-"snapd"}
export CHANNEL=${CHANNEL:-"beta"}
export DEVICE_QUEUE=${DEVICE_QUEUE:-"dragonboard"}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-arm-64:tests/"}
export SPREAD_PARAMS=${SPREAD_PARAMS:-"-v"}
export TEST_PASS=${TEST_PASS:-"ubuntu"}
export SKIP_TESTS=${SKIP_TESTS:-"tests/main/interfaces-many-snap-provided,tests/main/interfaces-many-core-provided"}

