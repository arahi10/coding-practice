#!/usr/bin/bash
set -eo pipefail

main (){
    local problem
    problem="$*"
    problem="${problem//[[:space:]]/_}"
    cp -r templates "$problem"
    git fetch origin
    git switch -c "$problem" main
}
main "$@"
