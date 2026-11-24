#!/bin/sh

set -eu

script_dir=$(CDPATH='' cd -P "$(dirname "$0")" && pwd)
. "$script_dir/network-common.sh"

network_field dev
