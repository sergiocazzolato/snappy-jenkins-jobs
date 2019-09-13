#!/bin/bash

if [ -z "$IMAGE_URL" ]; then
    echo "Nested image needed"
    exit 1
fi

git clone "$PROJECT_URL" "$PROJECT"

. "$SCRIPTS_DIR/utils/snap_info.sh"
sudo apt install -y jq
if [ "$BRANCH" = beta ]; then
	BRANCH=$(get_beta_branch "$ARCH")
elif [ "$BRANCH" = edge ]; then
	BRANCH=$(get_edge_commit "$ARCH")
fi

(cd $PROJECT && git reset --hard origin && git fetch origin && git checkout $BRANCH && git pull && git checkout $COMMIT)
. "$PROJECT_DIR"/scripts/utils/get_spread.sh
"$PROJECT_DIR"/scripts/utils/create_vm.sh "$ARCH" "$IMAGE_URL" "$USER_ASSERTION_URL"
"$PROJECT_DIR"/scripts/utils/run_setup.sh "127.0.0.1" "8022" "$SPREAD_SETUP" "$SPREAD_ENV" "$SPREAD_PARAMS"
"$PROJECT_DIR"/scripts/utils/run_tests.sh "127.0.0.1" "8022" "$PROJECT" "$SPREAD_TESTS" "$SPREAD_ENV" "$SPREAD_TESTS_SKIP" "$SPREAD_PARAMS"
"$PROJECT_DIR"/scripts/utils/destroy_vm.sh