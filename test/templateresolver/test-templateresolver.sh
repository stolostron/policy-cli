#! /bin/bash

RESOLVER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

test-templateresolver() {
  export KUBECONFIG=${TEST_DIR}/../kubeconfig_policycli_e2e
  kubectl get crd managedclusters.cluster.open-cluster-management.io &>/dev/null ||
    kubectl create -f ${RESOLVER_DIR}/crd_managedcluster.yaml
  kubectl get managedcluster local-cluster &>/dev/null ||
    kubectl create -f ${RESOLVER_DIR}/managedcluster_local-cluster.yaml
  kubectl -n default get configmap cool-car &>/dev/null ||
    kubectl -n default create configmap cool-car --from-literal=model=Shelby\ Mustang
  kubectl -n default get configmap not-cool-car &>/dev/null ||
    kubectl -n default create configmap not-cool-car --from-literal=model=Pinto

  echo "# Test: Policy with only managed cluster templates"
  testName=policy
  actual="$(
    ${TEST_DIR}/../build/_output/policytools templateresolver \
      ${RESOLVER_DIR}/${testName}-input.yaml
  )"
  testDiff "${actual}" "$(cat ${RESOLVER_DIR}/${testName}-expected.yaml)"

  echo "# Test: Policy with hub and managed cluster templates"
  testName=policywithhub
  actual="$(
    ${TEST_DIR}/../build/_output/policytools templateresolver \
      --cluster-name local-cluster --hub-kubeconfig ${TEST_DIR}/../kubeconfig_policycli_e2e \
      ${TEST_DIR}/templateresolver/${testName}-input.yaml
  )"
  testDiff "${actual}" "$(cat ${RESOLVER_DIR}/${testName}-expected.yaml)"
}
