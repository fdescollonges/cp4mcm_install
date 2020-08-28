

kubectl -n cp4mcm-cloud-native-monitoring create secret generic ibm-agent-https-secret --from-file=./ibm-cloud-apm-dc-configpack/keyfiles/cert.pem --from-file=./ibm-cloud-apm-dc-configpack/keyfiles/ca.pem --from-file=./ibm-cloud-apm-dc-configpack/keyfiles/key.pem

kubectl create secret docker-registry pull-secret-hub --docker-username=ekey --docker-password=<MY ENTITLEMENT KEY> --docker-email=demo@ibm.com --docker-server=cp.icr.io -n cp4mcm-cloud-native-monitoring
kubectl create secret docker-registry pull-secret-hub --docker-username=ekey --docker-password=<MY ENTITLEMENT KEY> --docker-email=demo@ibm.com --docker-server=cp.icr.io -n multicluster-endpoint

          oc patch cluster mcm-hub -n mcm-hub -p '{"metadata":{"labels":{"ibm.com/cloud-native-monitoring":"enabled"}}}'
