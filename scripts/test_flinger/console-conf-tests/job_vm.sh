#!/bin/bash

echo "Creating job for cconf using a vm"

HOST=localhost
PORT=8022
DEVICE_IP='$DEVICE_IP'

cat > job.yaml <<EOF
job_queue: $DEVICE_QUEUE
provision_data:
    distro: ${DEVICE_DISTRO:-bionic}
test_data:
    test_cmds: |
        #!/bin/bash
        ssh ${DEVICE_USER}@${DEVICE_IP} "sudo apt update || ps aux | grep apt"
        ssh ${DEVICE_USER}@${DEVICE_IP} "sudo apt install -y git curl jq sshpass unzip"
        ssh ${DEVICE_USER}@${DEVICE_IP} "git clone $JOBS_URL"
        ssh ${DEVICE_USER}@${DEVICE_IP} "(cd $JOBS_PROJECT && git checkout $JOBS_BRANCH)"
        ssh ${DEVICE_USER}@${DEVICE_IP} "$JOBS_PROJECT/scripts/utils/get_project.sh \"$CCONF_URL\" \"$PROJECT\" \"$BRANCH\" ''"
        $PRE_HOOK
        ssh ${DEVICE_USER}@${DEVICE_IP} "sudo $JOBS_PROJECT/scripts/utils/create_vm.sh \"$ARCH\" \"$IMAGE_URL\" \"$USER_ASSERTION_URL\" \"$BUILD_SNAPD\""
        ssh ${DEVICE_USER}@${DEVICE_IP} ". $JOBS_PROJECT/scripts/utils/add_root_key.sh \"$HOST\" \"$PORT\" \"$TEST_USER\" \"$TEST_PASS\""
        ssh ${DEVICE_USER}@${DEVICE_IP} ". $JOBS_PROJECT/scripts/utils/refresh.sh \"$HOST\" \"$PORT\" \"$TEST_USER\" \"$TEST_PASS\" \"$CHANNEL\" \"$CORE_CHANNEL\" \"$SNAPD_CHANNEL\""
        ssh ${DEVICE_USER}@${DEVICE_IP} ". $JOBS_PROJECT/scripts/utils/register_device.sh \"$HOST\" \"$PORT\" \"$TEST_USER\" \"$TEST_PASS\" \"$REGISTER_EMAIL\""
        ssh ${DEVICE_USER}@${DEVICE_IP} ". $JOBS_PROJECT/scripts/utils/run_setup.sh \"$HOST\" \"$PORT\" \"$TEST_USER\" \"$TEST_PASS\" \"$SETUP\""
        ssh ${DEVICE_USER}@${DEVICE_IP} ". $JOBS_PROJECT/scripts/utils/get_spread.sh \"$SPREAD_URL\""
        ssh ${DEVICE_USER}@${DEVICE_IP} ". $JOBS_PROJECT/scripts/utils/run_spread.sh \"$HOST\" \"$PORT\" \"$PROJECT\" \"$SPREAD_TESTS\" \"$SPREAD_ENV\" \"$SKIP_TESTS\" \"$SPREAD_PARAMS\""
        $POST_HOOK
EOF

export TF_JOB=$TF_DATA/job.yaml
sudo mv job.yaml $TF_JOB