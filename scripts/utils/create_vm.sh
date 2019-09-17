#!/bin/bash
set -x

echo "Creating vm"

if [ "$#" -lt 4 ]; then
    echo "Illegal number of parameters: $#"
    i=1
    for param in $*; do
        echo "param $i: $param"
        i=$(( i + 1 ))
    done
    exit 1
fi

ARCHITECTURE=$1
IMAGE_URL=$2
USER_ASSERTION_URL=$3
PORT=$4

execute_remote(){
    sshpass -p ubuntu ssh -p $PORT -q -o ConnectTimeout=10 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no user1@localhost "$*"
}

wait_for_ssh(){
    retry=150
    while ! execute_remote true; do
        retry=$(( retry - 1 ))
        if [ $retry -le 0 ]; then
            echo "Timed out waiting for ssh. Aborting!"
            return 1
        fi
        sleep 1
    done
}

wait_for_no_ssh(){
    retry=150
    while execute_remote true; do
        retry=$(( retry - 1 ))
        if [ $retry -le 0 ]; then
            echo "Timed out waiting for no ssh. Aborting!"
            return 1
        fi
        sleep 1
    done
}

prepare_ssh(){
    execute_remote "sudo adduser --extrausers --quiet --disabled-password --gecos '' test"
    execute_remote "echo test:ubuntu | sudo chpasswd"
    execute_remote "echo 'test ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/test-user"
}

create_assertions_disk() {
    dd if=/dev/null of="$WORK_DIR/assertions.disk" bs=1M seek=1
    mkfs.ext4 -F "$WORK_DIR/assertions.disk"
    curl -L -o "$WORK_DIR/auto-import.assert" "$USER_ASSERTION_URL"
    debugfs -w -R "write $WORK_DIR/auto-import.assert auto-import.assert" "$WORK_DIR/assertions.disk"    
}

systemd_create_and_start_unit() {
    printf "[Unit]\nDescription=For testing purposes\n[Service]\nType=simple\nExecStart=%s\n" "$2" > "/run/systemd/system/$1.service"
    if [ -n "${3:-}" ]; then
        echo "Environment=$3" >> "/run/systemd/system/$1.service"
    fi
    systemctl daemon-reload
    systemctl start "$1"
}

get_qemu_for_nested_vm(){
    case "$ARCHITECTURE" in
    amd64)
        command -v qemu-system-x86_64
        ;;
    i386)
        command -v qemu-system-i386
        ;;
    *)
        echo "unsupported architecture"
        exit 1
        ;;
    esac
}

echo "installing dependencies"
sudo apt update
sudo apt install -y snapd qemu sshpass

export WORK_DIR=/tmp/work-dir
export QEMU=$(get_qemu_for_nested_vm)

# create ubuntu-core image
mkdir -p "$WORK_DIR"

if [[ "$IMAGE_URL" == *.img.xz ]]; then
    curl -L -o "$WORK_DIR/ubuntu-core.img.xz" "$IMAGE_URL"
    unxz "$WORK_DIR/ubuntu-core.img.xz"
elif [[ "$IMAGE_URL" == *.img ]]; then
    curl -L -o "$WORK_DIR/ubuntu-core.img" "$IMAGE_URL"
else
    echo "Image extension not supported, exiting..."
    exit 1
fi

create_assertions_disk

systemd_create_and_start_unit nested-vm "${QEMU} -m 2048 -nographic \
    -net nic,model=virtio -net user,hostfwd=tcp::$PORT-:22 \
    -drive file=$WORK_DIR/ubuntu-core.img,cache=none,format=raw \
    -drive file=$WORK_DIR/assertions.disk,cache=none,format=raw \
    -machine accel=kvm"

if ! wait_for_ssh; then
    systemctl restart nested-vm
fi

if wait_for_ssh; then
    prepare_ssh
else
    echo "ssh not established, exiting..."
    journalctl -u nested-vm
    exit 1
fi

echo "Wait for first boot to be done"
while ! execute_remote "snap changes" | grep -q -E "Done.*Initialize system state"; do
    sleep 1
done

echo "VM Ready"
