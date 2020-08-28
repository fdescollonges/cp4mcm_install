
oc adm policy add-scc-to-user privileged -n bookinfo -z bookinfo-details
oc adm policy add-scc-to-user privileged -n bookinfo -z default
oc adm policy add-scc-to-user privileged -n bookinfo -z bookinfo-productpage
oc adm policy add-scc-to-user privileged -n bookinfo -z bookinfo-ratings
oc adm policy add-scc-to-user privileged -n bookinfo -z bookinfo-reviews


tar -xf ibm-cloud-apm-dc-configpack.tar
cd ibm-cloud-apm-dc-configpack
kubectl -n bookinfo create secret generic icam-server-secret --from-file=keyfiles/keyfile.jks --from-file=keyfiles/keyfile.p12 --from-file=keyfiles/keyfile.kdb --from-file=keyfiles/ca.pem --from-file=keyfiles/cert.pem --from-file=keyfiles/key.pem --from-file=global.environment

#ab -n 100000000 -c 100 -v 5 http://test-bookinfo.demo-prod-a376efc1170b9b8ace6422196c51e491-0000.eu-de.containers.appdomain.cloud/productpage\?u\=normal


