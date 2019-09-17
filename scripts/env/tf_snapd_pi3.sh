#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export ARCH=${ARCH:-"armhf"}
export CHANNEL=${CHANNEL:-"beta"}

export SPREAD_SETUP=${SPREAD_SETUP:-"testflinger:rpi3-16-beta:tasks/setup/"}
export SPREAD_SETUP_PARAMS=${SPREAD_SETUP_PARAMS:-"-reuse"}

export PROJECT=${PROJECT:-"snapd"}
export PROJECT_URL=$SNAPD_URL
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-arm-32:tests/"}
export SPREAD_TESTS_PARAMS=${SPREAD_TESTS_PARAMS:-""}
export SPREAD_TESTS_SKIP=${SPREAD_TESTS_SKIP:-""}