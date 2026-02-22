#!/usr/bin/bash
set -eo pipefail

main (){
    local problem
    problem="$*"
    problem="${problem//[[:space:]]/_}"
    cp -r  templates "$problem"
}
main "$@"
