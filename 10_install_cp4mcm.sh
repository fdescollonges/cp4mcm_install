# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# Installing Script for all CP4MCM components
#
# V2.0 
#
# ©2020 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"

export TEMP_PATH=~/TEMP/mcm-install

# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# Do Not Edit Below
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"

set -o errexit
set -o pipefail
#set -o xtrace
source ./99_config-global.sh

export SCRIPT_PATH=$(pwd)
export LOG_PATH=""
__getClusterFQDN
__getInstallPath


__output "${GREEN}***************************************************************************************************************************************************${NC}"
__output "${GREEN}***************************************************************************************************************************************************${NC}"
__output "${GREEN}***************************************************************************************************************************************************${NC}"
__output "${GREEN}***************************************************************************************************************************************************${NC}"
__output "  "
__output " ${CYAN} CloudPack for Multicloud Management 2.0 on OpenShift${NC}"
__output "  "
__output "${GREEN}***************************************************************************************************************************************************${NC}"
__output "${GREEN}***************************************************************************************************************************************************${NC}"
__output "${GREEN}***************************************************************************************************************************************************${NC}"
__output "  "
__output "  "


# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Initialization
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
header1Begin "Initializing"




# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# GET PARAMETERS
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
header2Begin "Input Parameters" "magnifying"



        while getopts "t:d:p:s:l:c:" opt
        do
          case "$opt" in
              t ) INPUT_TOKEN="$OPTARG" ;;
              d ) INPUT_PATH="$OPTARG" ;;
              p ) INPUT_PWD="$OPTARG" ;;
              s ) INPUT_SC="$OPTARG" ;;
              l ) INPUT_LDAPPWD="$OPTARG";;
          esac
        done



        if [[ $INPUT_TOKEN == "" ]];
        then
            __output "       ${RED}ERROR${NC}: Please provide the Registry Token"
            __output "       USAGE: $0 -t <REGISTRY_TOKEN> [-s <STORAGE_CLASS> -l <LDAP_ADMIN_PASSWORD> -d <TEMP_DIRECTORY>]"
            exit 1
        else
            __output "       ${GREEN}Token    ${NC}                                  $INPUT_TOKEN"
            export ENTITLED_REGISTRY_KEY=$INPUT_TOKEN
        fi


        if [[ $INPUT_PATH == "" ]];
        then
            __output "       ${ORANGE}No Path provided, using${NC}                    $TEMP_PATH"
        else
            __output "       ${GREEN}Temp Path${NC}                                  $INPUT_PATH"
            export TEMP_PATH=$INPUT_PATH
        fi


        if [[ $INPUT_SC == "" ]];
        then
            __output "       ${ORANGE}No Storage Class provided, using${NC}           $STORAGE_CLASS_BLOCK"
        else
            __output "       ${GREEN}Storage Class    ${NC}                   $INPUT_SC"
            export STORAGE_CLASS_BLOCK=$INPUT_SC
        fi



        if [[ $INPUT_LDAPPWD == "" ]];
        then
            __output "       ${ORANGE}No LDAP admin password provided, using${NC}     $LDAP_ADMIN_PASSWORD"
        else
            __output "       ${GREEN}LDAP Password    ${NC}                   **********"
            export LDAP_ADMIN_PASSWORD=$INPUT_LDAPPWD
        fi


header2End



# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# List Components
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
header2Begin "Components to be installed"  "magnifying"
__output "     You can adapt this in the 01_config-modules.sh file${NC}"
__output "${CYAN}---------------------------------------------------------------------------------------------------------------------------${NC}"

  printComponentsInstall

header2End






# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Install Checks
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
header2Begin "Install Checks"

        getClusterFQDN
        
        #getHosts

        #check_and_install_jq
        #check_and_install_cloudctl
        #check_and_install_kubectl
        check_and_install_oc
        #check_and_install_helm
        checkHelmExecutable
        #check_and_install_yq
        dockerRunning
        checkOpenshiftReachable
        checkKubeconfigIsSet
        checkStorageClassExists
        checkDefaultStorageDefined
        checkRegistryCredentials
        

header2End

header1End "Initializing"

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Install CloudPak for MultiCloud Management (CM4MCM) for OpenShift
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
header1Begin "Install CloudPak for MultiCloud Management (CM4MCM) for OpenShift"
  

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Installing CP4MCM
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    __output "Ignore if there is an error below. This just means that CP4MCM is not installed"
    CP4MCM_INSTALLED=$(oc get installations.orchestrator.management.ibm.com -n $CP4MCM_NAMESPACE || true )

    if [[ $CP4MCM_INSTALLED == "" ]]; 
    then
        ./20_install_cp4mcm.sh
    
        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "  "
        __output " ${RED}${clock}     CloudPack for Multicloud Management has been initialized ${NC}"
        __output " ${RED}        Installation will take up to 45 Minutes, please be patient and go grab a coffee.....${NC}"
        __output " ${RED}       Waiting for CP4MCM to become ready.....${NC}"
        __output "  "
        __output " ${ORANGE}      While waiting let's install OpenLDAP.....${NC}"
        __output "  "
        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "${RED}***************************************************************************************************************************************************${NC}"

      header2Begin "Install OpenLDAP"  "rocket"    

      cd $SCRIPT_PATH

      checkComponentNotInstalled LDAP
      if [[ $MUST_INSTALL == "1" ]]; 
      then

          # --------------------------------------------------------------------------------------------------------------------------------
          #  INSTALL
          # --------------------------------------------------------------------------------------------------------------------------------
          ./41_addon_install_ldap.sh

              # Check if installation went trough
      else
        __output "     ${RED}${cross} Skipping LDAP Installation${NC}"
      fi
      header2End




        waitForCPPassword
        __output " ${GREEN}${eyes}     CP4MCM PWD : $(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d) ${NC}"

        waitForCPReady ibm-common-services 500
        waitForCPReady management-infrastructure-management 50
        waitForCPReady management-operations 50
        waitForCPReady management-security-services 50
        waitForCPReady management-monitoring 50
        waitForCPReady kube-system 500

        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "  "
        __output " ${RED}${eyes}     CP4MCM URL : $(oc get route -n ibm-common-services cp-console -o jsonpath=‘{.spec.host}’) ${NC}"
        __output " ${RED}${eyes}     CP4MCM USER: $(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}' | base64 -d && echo) ${NC}"
        __output " ${RED}${eyes}     CP4MCM PWD : $(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d) ${NC}"
        __output "  "
        __output "${RED}***************************************************************************************************************************************************${NC}"



        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "  "
        __output " ${GREEN}${check}     CP4MCM has been installed ${NC}"
        __output "  "
        __output " ${RED}     Please try to login with the above parameters and check if all components are ready. ${NC}"
        __output " ${ORANGE}${exclamation}    Then register the MCM-HUB Cluster manually. ${NC}"

        __output "  "
        __output " ${GREEN}${rocket}     Just relaunch this installation after the verification. Exiting now....${NC}"
        __output "  "
        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "${RED}***************************************************************************************************************************************************${NC}"
        __output "${RED}***************************************************************************************************************************************************${NC}"


        exit 1


    else 

        __output "${GREEN}***************************************************************************************************************************************************${NC}"
        __output "  "
        __output " ${GREEN}${clock}     CloudPack for Multicloud Management has already been installed.... ${RED}Skipping.... ${NC}"
        __output "  "
        __output "       ${ORANGE}${memo} Please use 02_update_cp4mcm.sh to update your installation ${NC}"
        __output "  "
        __output "${GREEN}***************************************************************************************************************************************************${NC}"



        waitForCPPassword
        waitForCPReady ibm-common-services 50

        __output "  "
        __output " ${GREEN}${eyes}     CP4MCM URL : $(oc get route -n ibm-common-services cp-console -o jsonpath=‘{.spec.host}’) ${NC}"
        __output " ${GREEN}${eyes}     CP4MCM USER: $(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}' | base64 -d && echo) ${NC}"
        __output " ${GREEN}${eyes}     CP4MCM PWD : $(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d) ${NC}"
        __output "  "



        __output "${GREEN}***************************************************************************************************************************************************${NC}"
        __output "  "
        __output " ${CYAN}${rocket}     Make sure the MCM-HUB has been registered with MCM ${NC}"
        __output "  "
        __output "${GREEN}***************************************************************************************************************************************************${NC}"

        checkAlreadyInstalled app=service-registry multicluster-endpoint
        #ALREADY_INSTALLED=1

        if  [[ $ALREADY_INSTALLED == 0 ]]; then 
                __output "${RED}${Cross}   MCM-HUB is not registered. Please register manually before proceeding. Aborting...."
                exit 1
        fi

  
        # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        # Install CP4MCM with the final YAML
        # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        header2Begin "Install CP4MCM with selected options" "rocket"
      
              __output " ${wrench} Deploy CP4MCM with final CR File"
              
              oc apply -n $CP4MCM_NAMESPACE -f $TEMP_PATH/$CLUSTER_NAME/20_install_cp4mcm.sh/cp4mcm-cr.yaml

        header2End

        sleep 1


    fi






header1End "Install CloudPak for MultiCloud Management (CM4MCM) for OpenShift"







# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Post Installation Actions
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
header1Begin "Post Installation Actions"



      # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # Install OpenLDAP
      # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      header2Begin "Install OpenLDAP"  "rocket"    

      MCM_PWD=$(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d)
      cd $SCRIPT_PATH

      checkComponentNotInstalled LDAP
      if [[ $MUST_INSTALL == "1" ]]; 
      then

          # --------------------------------------------------------------------------------------------------------------------------------
          #  INSTALL
          # --------------------------------------------------------------------------------------------------------------------------------
          ./41_addon_install_ldap.sh
          waitForComponentReady LDAP 50
          waitForPodsReady default

              # Check if installation went trough
              checkComponentNotInstalled LDAP
              if [[ $MUST_INSTALL == "1" ]]; 
              then
                      __output "       ${ORANGE}${explosion}OpenLDAP ${NC}${RED}has not been installed successfully${NC}"
                      __output "       ${RED}${cross} Aborting${NC}"
              fi

            


      else
        __output "     ${RED}${cross} Skipping LDAP Installation${NC}"
      fi
      header2End



      header2Begin "Register OpenLDAP Users in CP4MCM"  "rocket"   
      if [[ $INSTALL_LDAP == "true" ]]; 
      then
        checkComponentNotInstalled LDAP
        if [[ $MUST_INSTALL == "0" ]]; 
        then

            # --------------------------------------------------------------------------------------------------------------------------------
            #  REGISTER LDAP in CP4MCM
            # --------------------------------------------------------------------------------------------------------------------------------
          ./42_addon_register_ldap.sh
        else
          __output "     ${RED}${cross} OpenLDAP Not installed... Skipping${NC}"
        fi
      else
        __output "     ${RED}${cross} Skipping LDAP Registration${NC}"
      fi
      header2End





      # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # Create Configuration and Registration for Infrastructure Modules
      # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

          header2Begin "Post-Installation Configuration for Infrastructure Modules"  "rocket"

            cd $SCRIPT_PATH


            if [[ $INSTALL_INFRA_VM  == true ]]; 
            then
              ./31_post_infra_vm.sh
            else 
              __output "   ${wrench}${CYAN}Component${NC} '${ORANGE}Infrastructure VM Module${NC}' is not selected for installation"
              __output "     ${RED}${cross} Skipping Infrastructure VM Module Post-Installation${NC}"

            fi



            if [[ $INSTALL_INFRA_CAM  == true ]]; 
            then
              ./32_post_infra_cam.sh || true
            else 
              __output "   ${wrench}${CYAN}Component${NC} '${ORANGE}Infrastructure CAM Module${NC}' is not selected for installation"
              __output "     ${RED}${cross} Skipping Infrastructure CAM Module Post-Installation${NC}"
            fi

          header2End



              


      # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # Synth Pop on HUB Monitoring
      # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        header2Begin "Register Synth Pop on HUB Monitoring"  "rocket"
          if [[ $INSTALL_MON_MONITORING == "true" ]]; 
          then
              ./38_create_synth_pop_hub.sh
          else
              __output "   ${wrench}${CYAN}Component${NC} '${ORANGE}Monitoring Module${NC}' is not selected for installation"
              __output "     ${RED}${cross} Skipping Register Synth Pop on HUB Monitoring${NC}"
          fi

        header2End

      # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # Register MCM HUB with Monitoring
      # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        header2Begin "Register MCM HUB with Monitoring"  "rocket"
          if [[ $INSTALL_MON_REG_HUB == "true" ]]; 
          then
              ./37_post_register_k8_monitor_HUB.sh
          else
              __output "   ${wrench}${CYAN}Component${NC} '${ORANGE}Register MCM Hub with Monitoring${NC}' is not selected for installation"
              __output "     ${RED}${cross} Skipping Registering MCM HUB with Monitoring${NC}"
          fi

        header2End


header1End "Post Installation Actions"











# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Installing Addons
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
header1Begin "Installing Addons"




    # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    # Install ANSIBLE TOWER
    # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    header2Begin "Install Ansible Tower"  "rocket"    
    
      checkComponentNotInstalled ANSIBLE
      if [[ $MUST_INSTALL == "1" ]]; 
      then
        OCP_ANSIBLE_API=$(oc config view --minify -o jsonpath='{.clusters[*].cluster.server}')
        __output $OCP_ANSIBLE_API
        ./45_addon_addon_install_ansible.sh

        waitForComponentReady ANSIBLE 50
        waitForPodsReady ansible-tower


            # Check if installation went trough
            checkComponentNotInstalled ANSIBLE
            if [[ $MUST_INSTALL == "1" ]]; 
            then
                    __output "       ${ORANGE}${explosion}Ansible Tower ${NC}${RED}has not been installed successfully${NC}"
                    __output "       ${RED}${cross} Aborting${NC}"
            fi



      else
        __output "     ${RED}${cross} Skipping Ansible Tower Installation${NC}"
        __output "  "
      fi

    header2End








    # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    # Install Turbonomics
    # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    header2Begin "Install Turbonomics"  "rocket"    

    checkComponentNotInstalled TURBO
    if [[ $MUST_INSTALL == "1" ]]; 
    then
         # --------------------------------------------------------------------------------------------------------------------------------
        #  INSTALL
        # --------------------------------------------------------------------------------------------------------------------------------
        ./46_addon_install_turbonomic.sh
        waitForComponentReady TURBO 50
        waitForPodsReady turbonomic

            # Check if installation went trough
            checkComponentNotInstalled TURBO
            if [[ $MUST_INSTALL == "1" ]]; 
            then
                    __output "       ${ORANGE}${explosion}Turbonomic ${NC}${RED}has not been installed successfully${NC}"
                    __output "       ${RED}${cross} Aborting${NC}"
            fi



    else
      __output "     ${RED}${cross} Skipping Turbonomic Installation${NC}"
    fi 


    header2End






    # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    # Install Demo Assets
    # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    header2Begin "Install Demo Assets"  "rocket"    

    if [[ $INSTALL_DEMO == true ]]; 
    then

        ./43_addon_install_demo_assets.sh

        ./49_addon_demo_menu.sh

    else
        __output "${wrench}   ${CYAN}Component${NC} '${ORANGE}Demo Assets${NC}' is not selected for installation"
        __output "     ${RED}${cross} Skipping Demo Assets Installation${NC}"
    fi


    header2End



   # HACK
    oc create clusterrolebinding demo --clusterrole=cluster-admin --user=demo || true
    oc create clusterrolebinding prod --clusterrole=cluster-admin --user=prod  || true
    oc create clusterrolebinding test --clusterrole=cluster-admin --user=test  || true
    oc create clusterrolebinding dev --clusterrole=cluster-admin --user=dev  || true
    oc create clusterrolebinding nik --clusterrole=cluster-admin --user=dev  || true
    oc create clusterrolebinding boss --clusterrole=cluster-admin --user=dev  || true

    oc create clusterrolebinding manageiq-orchestrator-binding --clusterrole=cluster-admin --serviceaccount=system:serviceaccount:kube-system:default || true

    oc create clusterrolebinding cam-binding --clusterrole=cluster-admin --serviceaccount=management-infrastructure-management:default || true


header1End "Installing Addons"











__output "${GREEN}----------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
__output "${GREEN}----------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
__output " ${GREEN}${healthy} Cloud Pak for Multicloud Management (CP4MCM) 2.0 Installed${NC}"
__output "${GREEN}----------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
__output "${GREEN}----------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
__output "${GREEN}----------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
__output "${GREEN}----------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
__output "${GREEN}----------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
__output "${GREEN}${explosion}  To remove Components:${NC}"
__output "${ORANGE}./demo/delete-apps.sh"
__output "${ORANGE}./demo/delete-policies.sh"
__output "${ORANGE}$HELM_BIN delete openldap"
__output "${GREEN}----------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
__output "${GREEN}***************************************************************************************************************************************************${NC}"
__output "${GREEN}***************************************************************************************************************************************************${NC}"


