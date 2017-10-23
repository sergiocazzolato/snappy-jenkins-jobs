#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export PROJECT=${PROJECT:-"snapd"}
export CHANNEL=${CHANNEL:-"stable"}
export DEVICE_QUEUE=${DEVICE_QUEUE:-"dragonboard"}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-arm-64:tests/"}
export TEST_PASS=${TEST_PASS:-"ubuntu"}
export SKIP_TESTS=${SKIP_TESTS:-""}
export CORE_CHANNEL=${CORE_CHANNEL:-"beta"}
export SETUP=${SETUP:-""}