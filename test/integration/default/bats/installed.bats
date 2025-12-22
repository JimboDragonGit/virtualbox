#!/usr/bin/env bats

version="7.1"

@test "virtualbox-$version is installed" {
  run test "rpm -qa Virtualbox-$version || dpkg-query -s virtualbox-$version"
  [ "$status" -eq 0 ]
}
