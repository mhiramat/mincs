#!/bin/sh
# runtest.sh: Test Running Framework
# Inspired by ftracetest :)
#
# Copyright (C) 2017 Masami Hiramatsu <masami.hiramatsu@gmail.com>
# This program is released under the MIT License, see LICENSE.

set -e

usage() {
  cat << EOF
Usage: runtest [--debug] [-v] [TESTDIR] [TESTCASE]
EOF
  exit 1
}

err_exit() { # @message
  echo "ERROR: $1"
  exit 1
}

abs_path() { # @path
  echo $(cd $(dirname $1); pwd)/$(basename $1)
}

find_tests() { # @dir
  find $1 -name \*.sh | sort
}

TEST_DIR=
TEST_FILE=
TOP_DIR=$(cd $(dirname $0); pwd)
LOG_DIR=$TOP_DIR/logs/$(date +%F.%T)/
VERBOSE=0

:;: "Parsing options" ;:
while [ -n "$1" ]; do
  case $1 in
  -v)
    VERBOSE=$((VERBOSE + 1))
    shift 1;;
  -vv)
    VERBOSE=$((VERBOSE + 2))
    shift 1;;
  --debug)
    set -x
    shift 1;;
  --help|-h|--usage)
    usage ;;
  *)
    break;;
  esac
done

:;: "Parsing test dirs and files" ;:
while [ -n "$1" ]; do
  if [ -d "$1" ]; then
    TEST_DIR="$TEST_DIR $(abs_path $1)"
  elif [ -f "$1" ]; then
    TEST_FILE="$TEST_FILE $(abs_path $1)"
  else
    err_exit "$1 is not a file or directory"
  fi
  shift 1
done

if [ -z "$TEST_DIR" -a -z "$TEST_FILE" ]; then
  TEST_DIR=$(abs_path "./test.d")
fi

:;: "Expand test directory to test case list" ;:
for d in $TEST_DIR; do
  TEST_FILE="$TEST_FILE $(find_tests $d)"
done


:;: "Setup log directory" ;:
mkdir -p $LOG_DIR || err_exit "Failed to mkdir $LOG_DIR."
LOG_FILE=$LOG_DIR/runtest.log

log_echo() { #@message
  echo "$@" | tee -a $LOG_FILE
}

log_cat() { # @file
  cat $1 | tee -a $LOG_FILE
}


TEST_RESULT=

# Use realtime signals for sending result
SIG_PASS=36 # Test passed
SIG_FAIL=37 # Test failure
SIG_UNRESOLVED=38 # Can not run test because lack of tools etc.
SIG_UNSUPPORTED=39 # Feature is unsupported
SIG_PID=$$

send_result() { # @result-signal
  kill -s $1 $SIG_PID
}

test_succeed() {
  exit 0
}
test_fail() {
  send_result $SIG_FAIL
  exit 0
}
trap "TEST_RESULT=$SIG_FAIL" $SIG_FAIL

test_unsupported() {
  send_result $SIG_UNSUPPORTED
  exit 0
}
trap "TEST_RESULT=$SIG_UNSUPPORTED" $SIG_UNSUPPORTED

test_unresolved() {
  send_result $SIG_UNRESOLVED
  exit 0
}
trap "TEST_RESULT=$SIG_UNRESOLVED" $SIG_UNRESOLVED

CASE_NO=0

log_desc() { # @testfile
  DESC=$(grep "^#[ \t]*description:" $1 | cut -f2 -d:)
  log_echo -n "[$CASE_NO] $DESC"
}

NR_PASS=0
NR_FAIL=0
NR_UNRE=0
NR_UNSU=0
NR_BUGS=0

init_result() {
  TEST_RESULT=$SIG_PASS
}

count_result() {
  case $TEST_RESULT in
  $SIG_PASS)
    log_echo "   [PASS]"
    NR_PASS=$((NR_PASS + 1))
    return 0 ;;
  $SIG_FAIL)
    log_echo "   [FAIL]"
    NR_FAIL=$((NR_FAIL + 1))
    return 1 ;;
  $SIG_UNRESOLVED)
    log_echo "   [UNRESOLVED]"
    NR_UNRE=$((NR_UNRE + 1))
    return 1 ;;
  $SIG_UNSUPPORTED)
    log_echo "   [UNSUPPORTED]"
    NR_UNSU=$((NR_UNSU + 1))
    return 0 ;;
  *)
    log_echo "   [BUG] ($TEST_RESULT)"
    NR_BUGS=$((NR_BUGS + 1))
    return 1 ;;
  esac
}

exec_test() { # @testfile
  (cd $TOP_DIR
   read PID _ < /proc/self/stat # Note: we can not use $$ in subshell
   set -ex
   . $1
  ) || send_result $SIG_FAIL
}

run_test() { # @testfile
  CASE_NO=$((CASE_NO + 1))
  TEST_NAME=$(basename $1)
  TEST_LOG=$(mktemp ${LOG_DIR}/${CASE_NO}_${TEST_NAME}.log.XXXXXX)
  log_desc $1
  init_result
  case $VERBOSE in
  0)
    exec_test $1 >> $TEST_LOG 2>&1 ;;
  1)
    (exec_test $1 | tee -a /proc/$$/fd/1) > $TEST_LOG 2>&1 ;;
  *)
    exec_test $1 | tee -a $TEST_LOG 2>&1 ;;
  esac
  if count_result ; then
    rm $TEST_LOG
    return 0
  else
    log_cat $TEST_LOG
    return 1
  fi
}

# Shared among tests
SHARED_DIR=$TOP_DIR/shared
mkdir -p $SHARED_DIR

log_echo "===== Test Start ====="
RUNTEST_FAIL=0
for t in $TEST_FILE; do
  run_test $t || RUNTEST_FAIL=1
done

log_echo "===== Test Results ====="
log_echo "# of passed: $NR_PASS"
log_echo "# of failed: $NR_FAIL"
log_echo "# of unresolved: $NR_UNRE"
log_echo "# of unsupported: $NR_UNSU"
log_echo "# of test bugs: $NR_BUGS"

exit $RESULT_FAIL
