#!/bin/bash
OCPVERSION=$1
function ocp4() {
 dpname=$(oc get deploy -n ${ROUTERNS} -L ${routerLabel}|grep -v NAME|awk '{print $1}')
 res=$(oc describe deploy $dpname -n ${ROUTERNS}|grep STATS_USERNAME|cut -d':' -f 2)
 susername=$(echo $res|cut -d"'" -f 2);suserkey=$(echo $res|cut -d"'" -f 4)
 res=$(oc describe deploy $dpname -n ${ROUTERNS}|grep STATS_PASSWORD|cut -d':' -f 2)
 spassname=$(echo $res|cut -d"'" -f 2); spasskey=$(echo $res|cut -d"'" -f 4)
 username=$(oc get secret ${suserkey} -n ${ROUTERNS} -o=jsonpath='{.data.'"$susername"' }'|base64 -d)
 password=$(oc get secret ${spasskey} -n ${ROUTERNS} -o=jsonpath='{.data.'"$spassname"' }'|base64 -d)
 port=$(oc describe deploy $dpname -n ${ROUTERNS}|grep STATS_PORT|cut -d':' -f 2|gsed -e 's/^[[:space:]]*//')
 echo "  routernamespace: $ROUTERNS"
 echo "  podcpulimit: $(oc get deploy $dpname -n ${ROUTERNS} -o=jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')"
 echo "  podmemlimit: $(oc get deploy $dpname -n ${ROUTERNS} -o=jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')"
}
function ocp3() {
 dpname=$rn
 username=$(oc describe rc $dpname -n ${ROUTERNS}|grep STATS_USERNAME|cut -d':' -f 2|gsed -e 's/^[[:space:]]*//')
 password=$(oc describe rc $dpname -n ${ROUTERNS}|grep STATS_PASSWORD|cut -d':' -f 2|gsed -e 's/^[[:space:]]*//')
 port=$(oc describe rc $dpname -n ${ROUTERNS}|grep STATS_PORT|cut -d':' -f 2|gsed -e 's/^[[:space:]]*//')
 echo "  routernamespace: $ROUTERNS"
 echo "  routercpulimit: $(oc get rc $dpname -n ${ROUTERNS} -o=jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')"
 echo "  routermemlimit: $(oc get rc $dpname -n ${ROUTERNS} -o=jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')"
}
if [[ "$OCPVERSION" == "ocp3" ]];then
  ROUTERNS=default
  ROUTERSELECTOR=router
  routerlist=$(oc get rc -n ${ROUTERNS} -l ${ROUTERSELECTOR}|grep -v NAME|awk '{print $1}')
else if [[ "$OCPVERSION" == "ocp4" ]];then
  ROUTERNS=openshift-ingress
  ROUTERSELECTOR=ingresscontroller.operator.openshift.io/owning-ingresscontroller
  routerlist=$(oc get svc -n ${ROUTERNS} -l ${ROUTERSELECTOR}|grep -v NAME|awk '{print $1}')
  else echo "not supported version: $OCPVERSION";exit;fi;fi
ocpid=`kubectl cluster-info |grep https|cut -d' ' -f 6|gsed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"`
CID=`echo -n $ocpid|md5sum|awk '{print $1}'`;echo; echo " cid: $CID";echo
for rn in $routerlist;do
 if [[ "$OCPVERSION" == "ocp3" ]];then routerLabel=$(oc describe rc ${rn} -n ${ROUTERNS} |grep "Selector:"|awk '{print $2}')
 else if [[ "$OCPVERSION" == "ocp4" ]];then routerLabel=$(oc describe svc ${rn} -n ${ROUTERNS} |grep "Selector:"|awk '{print $2}');fi;fi
 podlist=$(oc get pod -o wide -n ${ROUTERNS} -l ${routerLabel} 2>/dev/null|grep -v 'NAME'|awk '{print $1}')
 if [[ "$podlist" == "" ]]; then continue;fi
 echo "routername: $rn"
 if [[ "$OCPVERSION" == "ocp3" ]];then ocp3; else if [[ "$OCPVERSION" == "ocp4" ]];then ocp4; fi; fi
  echo "  POD list:"
  for pn in $podlist; do echo "    routerpod: $pn";echo "    MetricsURL: http://${username}:${password}@$(oc get pod $pn -o wide -n ${ROUTERNS}|grep -v 'NAME'|awk '{print $6}' 2>&1):${port}/metrics";done
done

