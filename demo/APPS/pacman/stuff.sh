# https://github.com/ansonmez/rhacmgitopslab/blob/master/7.md


git clone https://github.com/ansonmez/rhacmgitopslab.git

cd ~/rhacmgitopslab/haproxy-yaml


oc create ns haproxy-lb

HAPROXY_LB_ROUTE=pacman-multicluster.$(oc get ingresses.config.openshift.io cluster -o jsonpath='{ .spec.domain }')
oc -n haproxy-lb create route edge haproxy-lb \
--service=haproxy-lb-service --port=8080 --insecure-policy=Allow \
--hostname=${HAPROXY_LB_ROUTE}
echo $HAPROXY_LB_ROUTE

CLUSTER1=demo-prod-a376efc1170b9b8ace6422196c51e491-0000.eu-de.containers.appdomain.cloud
CLUSTER2=demo20-a376efc1170b9b8ace6422196c51e491-0000.eu-de.containers.appdomain.cloud


# Define the variable of `PACMAN_INGRESS`
PACMAN_INGRESS=pacman-ingress.$(oc get ingresses.config.openshift.io cluster -o jsonpath='{ .spec.domain }')
# Define the variable of `PACMAN_CLUSTER1`
PACMAN_CLUSTER1=pacman.$CLUSTER1
# Define the variable of `PACMAN_CLUSTER2`
PACMAN_CLUSTER2=pacman.$CLUSTER2

# Copy the sample configmap
cp haproxy.tmpl haproxy
# Update the HAProxy configuration
gsed -i "/option httpchk GET/a \ \ \ \ http-request set-header Host ${PACMAN_INGRESS}" haproxy
# Replace the value with the variable `PACMAN_INGRESS`
gsed -i "s/<pacman_lb_hostname>/${PACMAN_INGRESS}/g" haproxy
# Replace the value with the variable `PACMAN_CLUSTER1`
gsed -i "s/<server1_name> <server1_pacman_route>:<route_port>/cluster1 ${PACMAN_CLUSTER1}:80/g" haproxy
# Replace the value with the variable `PACMAN_CLUSTER2`
gsed -i "s/<server2_name> <server2_pacman_route>:<route_port>/cluster2 ${PACMAN_CLUSTER2}:80/g" haproxy
# Replace the value with the variable `PACMAN_CLUSTER3`
gsed -i "s/<server3_name> <server3_pacman_route>:<route_port>/cluster3 ${PACMAN_CLUSTER3}:80/g" haproxy
# Create the configmap

cat haproxy

oc -n haproxy-lb create configmap haproxy --from-file=haproxy


oc -n haproxy-lb create -f haproxy-deployment.yaml


# Get the HAProxy LB Route
HAPROXY_LB_ROUTE=$(oc -n haproxy-lb get route haproxy-lb -o jsonpath='{.status.ingress[*].host}')
# Access HAProxy
curl -k https://${HAPROXY_LB_ROUTE}


oc  -n haproxy-lb get route haproxy-lb -o jsonpath="{.status.ingress[*].host}{\"\n\"}"