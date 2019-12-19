#!/usr/bin/env bash

if [[ $(virsh list | grep -Eo ' avapolos_test ') ]]; then
  virsh shutdown avapolos_test
fi

if [[ $(virsh list | grep -Eo ' avapolos_test-polo ') ]]; then
  virsh shutdown avapolos_test-polo
fi

virsh snapshot-revert avapolos_test clean && virsh snapshot-revert avapolos_test-polo clean

if [[ "$1" = "restart" ]]; then
  virsh start avapolos_test
  virsh start avapolos_test-polo
fi
