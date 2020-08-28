# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# Install Script for CP4MCM
#
# V1.0 
#
# ©2020 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"

source ./99_config-global.sh

# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# Do Not Edit Below
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"

headerModuleFileBegin "Install CP4MCM " $0

# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# Install Checks
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
header3Begin "Install Checks"


__output "${CYAN}---------------------------------------------------------------------------------------------------------------------------${NC}"
__output " ${PURPLE}${memo} Define some Stuff${NC}"
__output "${CYAN}---------------------------------------------------------------------------------------------------------------------------${NC}"
        
        getInstallPath
        #assignHosts

__output "${CYAN}---------------------------------------------------------------------------------------------------------------------------${NC}"
__output "  "
__output "  "
__output "  "
__output "  "

header3End





# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# CONFIG SUMMARY
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
__output "${GREEN}---------------------------------------------------------------------------------------------------------------------------${NC}"
__output " ${GREEN}${healthy} Cloud Pak for MultiCloud Management 2.0 (CP4MCM) will be installed in Cluster ${ORANGE}'$CLUSTER_NAME'${NC}"
__output "${GREEN}---------------------------------------------------------------------------------------------------------------------------${NC}"
__output "    ---------------------------------------------------------------------------------------------------------------------"
__output " ${CYAN} ${magnifying} Your configuration${NC}"
__output "    ---------------------------------------------------------------------------------------------------------------------"
__output "    ${GREEN}CLUSTER :${NC}               $CLUSTER_NAME"
__output "    ${GREEN}REGISTRY TOKEN:${NC}         $ENTITLED_REGISTRY_KEY"
__output "    ${GREEN}INSTALL NAMESPACE:${NC}      $CP4MCM_NAMESPACE"
__output "    ---------------------------------------------------------------------------------------------------------------------"
__output "    ${GREEN}MCM User Name:${NC}          $MCM_USER"
__output "    ${GREEN}MCM User Password:${NC}      will be automatically generated"
__output "    ---------------------------------------------------------------------------------------------------------------------"
__output "    ${GREEN}STORAGE CLASS:${NC}          $STORAGE_CLASS_BLOCK"
__output "    ---------------------------------------------------------------------------------------------------------------------"
__output "    ${GREEN}INSTALL PATH:${NC}           $INSTALL_PATH"
__output "${GREEN}---------------------------------------------------------------------------------------------------------------------------${NC}"
__output "  "
__output "  "
__output "  "
__output "  "



# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# PREREQUISITES
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
header3Begin "Running Prerequisites" "rocket"


        __output " ${wrench} Create Namespace"
          oc create ns $CP4MCM_NAMESPACE 2>&1
        __output "    ${GREEN}  OK${NC}"
        __output "  "
        
        __output " ${wrench} Patching Service Account"
          oc patch sa default -n openshift-marketplace --type=json -p '[{"op":"add","path":"/imagePullSecrets/-","value":{"name":"ibm-management-pull-secret"}}]' 2>&1
        __output "    ${GREEN}  OK${NC}"
        __output "  "


        __output " ${wrench} Create CP4MCM service catalog"
          oc create -f ./tools/0_prepare/cp4mcm-catalogsource.yaml 2>&1
        __output "    ${GREEN}  OK${NC}"
        __output "  "


        __output " ${wrench} Create CommonServices service catalog"
          oc create -f ./tools/0_prepare/cs-catalogsource.yaml 2>&1
        __output "    ${GREEN}  OK${NC}"
        __output "  "



        __output " ${wrench} Restart Marketplace (HACK)"
          oc delete pod -n openshift-marketplace -l name=marketplace-operator 2>&1
        __output "    ${GREEN}  OK${NC}"
        __output "  "




        __output " ${wrench} Create secret"
          oc create secret docker-registry ibm-management-pull-secret --docker-username=$ENTITLED_REGISTRY_USER --docker-password=$ENTITLED_REGISTRY_KEY --docker-email=demo@ibm.com --docker-server=$ENTITLED_REGISTRY -n $CP4MCM_NAMESPACE

          #oc create -n openshift-marketplace -f ./tools/0_prepare/secret.yaml 2>&1
          #oc create -n openshift-operators -f ./tools/0_prepare/secret.yaml 2>&1
          #oc create -n $CP4MCM_NAMESPACE -f ./tools/0_prepare/secret.yaml 2>&1
          #oc create -n kube-system -f ./tools/0_prepare/secret.yaml 2>&1
        __output "    ${GREEN}  OK${NC}"
        __output "  "


  

        __output " ${wrench} Create Secrets for Registry"
          docker login "$ENTITLED_REGISTRY" -u "$ENTITLED_REGISTRY_USER" -p "$ENTITLED_REGISTRY_KEY"
          oc create secret docker-registry entitled-registry --docker-server=$ENTITLED_REGISTRY --docker-username=$ENTITLED_REGISTRY_USER --docker-password=$ENTITLED_REGISTRY_KEY --docker-email=nikh@ch.ibm.com
        __output "    ${GREEN}  OK${NC}"
        __output "  "
        

        __output " ${wrench} Create Config Directory"
          export SCRIPT_PATH=$(pwd)
          rm -r -f $INSTALL_PATH/* 
          mkdir -p $INSTALL_PATH 
        __output "    ${GREEN}  OK${NC}"
        __output "  "
        

        __output " ${wrench} Patching Route"
          oc patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"defaultRoute":true}}' 2>&1
        __output "    ${GREEN}  OK${NC}"
        __output "  "
        
        
header3End



        
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Adapt Config Files
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
header3Begin "Adapt Config Files" "magnifying"


        cd $INSTALL_PATH
        # ---------------------------------------------------------------------------------------------------------------------------------------------------"
        # Backup vanilla config
        cp $SCRIPT_PATH/tools/0_prepare/CR/cp4mcm-cr.yaml ./cp4mcm-cr.yaml
        cp $SCRIPT_PATH/tools/0_prepare/CR/cp4mcm-cr-vanilla.yaml ./cp4mcm-cr-vanilla.yaml


        # ---------------------------------------------------------------------------------------------------------------------------------------------------"
        # Adapt Config FIle
        # ---------------------------------------------------------------------------------------------------------------------------------------------------"
        ${SED} -i "s/<STORAGE_CLASS>/$STORAGE_CLASS_BLOCK/" ./cp4mcm-cr.yaml
        ${SED} -i "s/<NAMESPACE>/$CP4MCM_NAMESPACE/" ./cp4mcm-cr.yaml

        ${SED} -i "s/<STORAGE_CLASS>/$STORAGE_CLASS_BLOCK/" ./cp4mcm-cr-vanilla.yaml
        ${SED} -i "s/<NAMESPACE>/$CP4MCM_NAMESPACE/" ./cp4mcm-cr-vanilla.yaml


        ${SED} -i "s/<INSTALL_INFRA_CAM>/$INSTALL_INFRA_CAM/" ./cp4mcm-cr.yaml
        ${SED} -i "s/<INSTALL_INFRA_VM>/$INSTALL_INFRA_VM/" ./cp4mcm-cr.yaml
        ${SED} -i "s/<INSTALL_INFRA_GRC>/$INSTALL_INFRA_GRC/" ./cp4mcm-cr.yaml
        ${SED} -i "s/<INSTALL_INFRA_SERVICE_LIBRARY>/$INSTALL_INFRA_SERVICE_LIBRARY/" ./cp4mcm-cr.yaml
        ${SED} -i "s/<INSTALL_MON_MONITORING>/$INSTALL_MON_MONITORING/" ./cp4mcm-cr.yaml
        ${SED} -i "s/<INSTALL_MCMNOT>/$INSTALL_MCMNOT/" ./cp4mcm-cr.yaml
        ${SED} -i "s/<INSTALL_MCMIMGSEC>/$INSTALL_MCMIMGSEC/" ./cp4mcm-cr.yaml
        ${SED} -i "s/<INSTALL_MCMMUT>/$INSTALL_MCMMUT/" ./cp4mcm-cr.yaml
        ${SED} -i "s/<INSTALL_MCMVUL>/$INSTALL_MCMVUL/" ./cp4mcm-cr.yaml
        ${SED} -i "s/<INSTALL_OPS_CHAT>/$INSTALL_OPS_CHAT/" ./cp4mcm-cr.yaml
        ${SED} -i "s/<INSTALL_TP_MNG_RT>/$INSTALL_TP_MNG_RT/" ./cp4mcm-cr.yaml


        initInfraBlocks

        ${SED} -i "s/<INSTALL_BLOCK_INFRA>/$INSTALL_BLOCK_INFRA/" ./cp4mcm-cr.yaml
        ${SED} -i "s/<INSTALL_BLOCK_MON>/$INSTALL_BLOCK_MON/" ./cp4mcm-cr.yaml
        ${SED} -i "s/<INSTALL_BLOCK_SEC>/$INSTALL_BLOCK_SEC/" ./cp4mcm-cr.yaml
        ${SED} -i "s/<INSTALL_BLOCK_OPS>/$INSTALL_BLOCK_OPS/" ./cp4mcm-cr.yaml
        ${SED} -i "s/<INSTALL_BLOCK_TP>/$INSTALL_BLOCK_TP/" ./cp4mcm-cr.yaml
        ${SED} -i "s/<DISABLE_MCM_CORE_INSTALL>/$DISABLE_MCM_CORE_INSTALL/" ./cp4mcm-cr.yaml
        ${SED} -i "s/<DISABLE_MCM_CORE_INSTALL>/$DISABLE_MCM_CORE_INSTALL/" ./cp4mcm-cr-vanilla.yaml


        __output ""
        __output " ${GREEN}DONE${NC}"
        
header3End



__output "${GREEN}---------------------------------------------------------------------------------------------------------------------------${NC}"
__output " ${GREEN}Current config file for installation${NC}"
__output " ${GREEN}Please Check if it looks OK${NC}"
__output " ${ORANGE}vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv${NC}"
__output "  "
        cat ./cp4mcm-cr.yaml

__output "  "
__output " ${ORANGE}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${NC}"
__output " ${GREEN}Current config file for installation${NC}"
__output " ${GREEN}Please Check if it looks OK${NC}"
__output "${GREEN}---------------------------------------------------------------------------------------------------------------------------${NC}"
__output "  "
__output "  "
__output "  "
__output "  "


        
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Do some Stuff
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
header3Begin "Do some Stuff" "rocket"
      __output "${clock}   Waiting for  ${CYAN}OpenShift Marketplace${NC} being ready ($ACTCOUNT/$MAXCOUNT). Waiting for 30 seconds...."
      sleep 30
      waitForCPReady openshift-marketplace 50
header3End



        
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Install CP4MCM
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
header3Begin "Install CP4MCM Base Configuration (only Foundation)" "rocket"
      __output " ${wrench} Create Common Services Operator Subscription"
      oc apply -n openshift-operators -f $SCRIPT_PATH/tools/0_prepare/cs-catalog-subscription.yaml

      __output " ${wrench} Waiting 30 seconds for Operator to settle"
      sleep 30

      __output " ${wrench} Create CP4MCM Operator Subscription"
      oc apply -n openshift-operators -f $SCRIPT_PATH/tools/0_prepare/cp4mcm-catalog-subscription.yaml

      __output " ${wrench} Waiting 60 seconds for Operator to settle"
      sleep 60


      __output " ${wrench} Deploy CP4MCM with CR File"
       
      oc apply -n $CP4MCM_NAMESPACE -f ./cp4mcm-cr-vanilla.yaml

      INSTALL_RESULT=$(oc get installations.orchestrator.management.ibm.com -n $CP4MCM_NAMESPACE)
      
      while [[ ! $INSTALL_RESULT =~ "management-installation" ]]
      do
        __output " ${wrench} Operators not ready... Waiting 15 seconds.."
        INSTALL_RESULT=$(oc get installations.orchestrator.management.ibm.com -n $CP4MCM_NAMESPACE)
        sleep 15
      done


header3End


headerModuleFileEnd "Install CP4MCM " $0
  