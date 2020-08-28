# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# Create Demo Menus
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



headerModuleFileBegin "Create MCM Demo Menus " $0


# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# INSTALL CHECKS
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
header3Begin "Install Checks"

        getClusterFQDN

        getInstallPath



header3End



# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# PREREQUISITES
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
header3Begin "Installing MCM Demo Menus" "rocket"
        
        __output " ${wrench} Create Config Directory"
          rm -r $INSTALL_PATH/* 
          mkdir -p $INSTALL_PATH 
          cd $INSTALL_PATH
        __output "    ${GREEN}  OK${NC}"
        __output "  "
        

        __output " ${wrench} Getting existing menu configuration"

        kubectl get navconfigurations.foundation.ibm.com multicluster-hub-nav -n kube-system -o yaml > navconfigurations.orginal

        cp navconfigurations.orginal navconfigurations.demo.yaml

        if grep -F "id: demo" navconfigurations.orginal;
        then
            __output "    ${RED}${cross}Demo Menus already installed! Skipping...${NC}"
            exit 0
        fi


# Add OpenLDAP to Admin
cat >> navconfigurations.demo.yaml <<EOL
  - id: id-ldap
    label: OpenLDAP Admin
    parentId: administer-mcm
    serviceId: webui-nav
    target: _blank
    url: http://openldap-admin-default.$CLUSTER_NAME/
EOL


#Add MCM Cluster to Admin
cat >> navconfigurations.demo.yaml <<EOL
  - id: id-mcm-cluster
    label: OCP MCM Hub
    parentId: administer-mcm
    serviceId: webui-nav
    target: _blank
    url: HUB_URL_REPLACE
EOL


#Add Prod Cluster to Admin
cat >> navconfigurations.demo.yaml <<EOL
  - id: id-prod-cluster
    label: OCP Prod Cluster
    parentId: administer-mcm
    serviceId: webui-nav
    target: _blank
    url: PROD_URL_REPLACE
EOL



# Add Demo Menu
cat >> navconfigurations.demo.yaml <<EOL
  - id: demo
    label: Demo Apps
    iconUrl: /common-nav/graphics/automate-infrastructure.svg
EOL


#Add Kubetoy to Demo
cat >> navconfigurations.demo.yaml <<EOL
  - id: kubetoy
    isAuthorized:
    - Administrator
    - ClusterAdministrator
    - Operator
    label: KubeToy
    parentId: demo
    serviceId: mcm-ui
    target: _blank
    url: http://kubetoy-default.$CLUSTER_NAME/home
 
EOL

#Add PacMan to Demo
cat >> navconfigurations.demo.yaml <<EOL
  - id: pacman
    isAuthorized:
    - Administrator
    - ClusterAdministrator
    - Operator
    label: PacMan
    parentId: demo
    serviceId: mcm-ui
    target: _blank
    url: pacman_URL_REPLACE
 
EOL

#Add Modresorts to Demo
cat >> navconfigurations.demo.yaml <<EOL
  - id: modresort
    isAuthorized:
    - Administrator
    - ClusterAdministrator
    - Operator
    label: ModResorts
    parentId: demo
    serviceId: mcm-ui
    target: _blank
    url: modresorts_URL_REPLACE/resorts
 
EOL


#Add Bookinfo to Demo
cat >> navconfigurations.demo.yaml <<EOL
  - id: bookinfo
    isAuthorized:
    - Administrator
    - ClusterAdministrator
    - Operator
    label: BookInfo
    parentId: demo
    serviceId: mcm-ui
    target: _blank
    url: bookinfo_URL_REPLACE
 
EOL







# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# INSTALL
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------



kubectl apply -n kube-system --validate=false -f navconfigurations.demo.yaml  

header3End

headerModuleFileEnd "Create MCM Demo Menus " $0


# KUBE_EDITOR="nano" kubectl edit navconfigurations.foundation.ibm.com multicluster-hub-nav -n kube-system

