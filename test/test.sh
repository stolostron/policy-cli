#! /bin/bash
# shellcheck disable=SC2016,SC2317

set -e

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
TEST_STATUS=0

testDiff() {
  if ! diff <(echo "${1}") <(echo "${2}"); then
    echo "^^^ FAIL: Expected and actual results differ."
    TEST_STATUS=1
  fi
}

validate-readme() {
  echo '# Validating content difference between README.md and `policytools --help`'
  updated_readme="$(printf '<!--BEGINHELP-->\n\n```text\n%s\n```\n\n<!--ENDHELP-->\n' "$(${TEST_DIR}/../build/_output/policytools)")"
  current_readme="$(awk '/<!--BEGINHELP-->/,/<!--ENDHELP-->/' README.md)"
  testDiff "${updated_readme}" "${current_readme}"
}

# Preflight check for binary file
if [[ ! -f ${TEST_DIR}/../build/_output/policytools ]]; then
  echo "error: Binary doesn't exist. Run 'make build' to build the binary."
  exit 1
fi

# This strips the leading "--" from the argument and runs the associated function.
# For example, this will run the "validate-readme" function:
#   ./test.sh --validate-readme
${1##--}

if [[ ${TEST_STATUS} == 0 ]]; then
  echo "PASS"
else
  echo "FAIL"
fi

exit ${TEST_STATUS}
