#!/usr/bin/env zsh
# Unit tests for _ssh_target_from_args (parses the SSH target host from argv).
# Run: zsh zsh/tests/ssh_title.test.zsh

set -u
SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/../modules/fn_utils.zsh"

typeset -i pass=0 fail=0

check() {
  local desc="$1" expected="$2"; shift 2
  local got; got="$(_ssh_target_from_args "$@")"
  if [[ "$got" == "$expected" ]]; then
    print -r -- "  ok   $desc"
    (( pass++ ))
  else
    print -r -- "  FAIL $desc -> expected '$expected', got '$got'"
    (( fail++ ))
  fi
}

print "== _ssh_target_from_args =="
check "bare host"                 host1   host1
check "user@host"                 host2   user@host2
check "-p PORT before user@host"  host3   -p 2222 user@host3
check "-i and -o before host"     host4   -i ~/.ssh/k -o StrictHostKeyChecking=no admin@host4
check "-L forward then alias"     myalias -L 8080:localhost:80 myalias
check "host with trailing cmd"    host6   user@host6 uptime
check "stacked boolean flags"     host7   -4 -C host7
check "host:port form"            host8   user@host8:2200
check "no target (only flags)"    ""      -v

print ""
print "== summary: ${pass} passed, ${fail} failed =="
(( fail == 0 ))
