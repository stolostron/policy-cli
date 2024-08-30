#! /bin/bash
# shellcheck disable=SC2016,SC2317

set -e

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
TEST_STATUS=0

# Import test scripts
source ${TEST_DIR}/templateresolver/test-templateresolver.sh

testDiff() {
  if ! diff <(echo "${1}") <(echo "${2}"); then
    echo "^^^ FAIL: Expected and actual results differ."
    TEST_STATUS=1
  fi
}

validate-readme() {
  echo '# Validating content difference between README.md and `policytools --help`'
  updated_readme="$(printf '<!--BEGINHELP-->\n\n```\n%s\n```\n\n<!--ENDHELP-->\n' "$(${TEST_DIR}/../build/_output/policytools)")"
  current_readme="$(awk '/<!--BEGINHELP-->/,/<!--ENDHELP-->/' README.md)"
  testDiff "${updated_readme}" "${current_readme}"
}

# This strips the leading "--" from the argument and runs the associated function.
# For example, this will run the "test-this-thing" function:
#   ./test.sh --test-this-thing
${1##--}

if [[ ${TEST_STATUS} == 0 ]]; then
  echo "PASS"
else
  echo "FAIL"
fi

exit ${TEST_STATUS}
