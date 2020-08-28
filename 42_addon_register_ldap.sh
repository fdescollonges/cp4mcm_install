# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# Install Script for Open LDAP
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

headerModuleFileBegin "Register LDAP Users in CP4MCM " $0



# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# INSTALL
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
header3Begin "Register LDAP Users in CP4MCM"


        getClusterFQDN

        BASE_DN="dc="$(echo $LDAP_DOMAIN | ${SED} -e "s/\./,dc=/")
        BIND_DN="cn=admin,"$BASE_DN

        __output "---------------------------------------------------------------------------------------------------------------------------"
        __output "---------------------------------------------------------------------------------------------------------------------------"
        __output " ${BLUE}Login to PHP LDAP Admin${NC}"
        __output " ${GREEN}  GUI is here: http://openldap-admin-default.$CLUSTER_NAME"
        __output ""


        __output "   ${GREEN}LDAP Admin User: $BIND_DN"
        __output "   ${GREEN}LDAP Admin Password: $LDAP_ADMIN_PASSWORD"
        __output ""
        __output ""
        __output ""
        __output ""



        MCM_PWD=$(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d)
        export SPOKE_CONTEXT=$(kubectl config current-context)

        __output "---------------------------------------------------------------------------------------------------------------------------"
        __output "    ${CYAN}${wrench} MCM Login${NC}"
        #echo cloudctl login -a ${MCM_SERVER} --skip-ssl-validation -u ${MCM_USER} -p ${MCM_PWD} -n kube-system
        cloudctl login -a ${MCM_SERVER} --skip-ssl-validation -u ${MCM_USER} -p ${MCM_PWD} -n kube-system


        ALREADY_INSTALLED=$(cloudctl iam users | grep demo)
        if [[ $ALREADY_INSTALLED =~ "demo" ]];
        then
            __output "    ${RED}${cross}LDAP isers already registered! Skipping...${NC}"
            exit 0
        fi


        __output "---------------------------------------------------------------------------------------------------------------------------"
        __output "    ${CYAN}${wrench} Creating LDAP Connection${NC}"
        #echo         cloudctl iam ldap-create "LDAP" --basedn "$BASE_DN" --server "ldap://openldap.default:389" --binddn "$BIND_DN" --binddn-password "$LDAP_ADMIN_PASSWORD" -t "Custom" --group-filter "(&(cn=%v)(objectclass=groupOfUniqueNames))" --group-id-map "*:cn" --group-member-id-map "groupOfUniqueNames:uniqueMember" --user-filter "(&(uid=%v)(objectclass=Person))" --user-id-map "*:uid"

        cloudctl iam ldap-create "LDAP" --basedn "$BASE_DN" --server "ldap://openldap.default:389" --binddn "$BIND_DN" --binddn-password "$LDAP_ADMIN_PASSWORD" -t "Custom" --group-filter "(&(cn=%v)(objectclass=groupOfUniqueNames))" --group-id-map "*:cn" --group-member-id-map "groupOfUniqueNames:uniqueMember" --user-filter "(&(uid=%v)(objectclass=Person))" --user-id-map "*:uid"
        TEAM_ID=$(cloudctl iam teams | awk '{print $1}' | sed -n 2p)

        __output "---------------------------------------------------------------------------------------------------------------------------"
        __output "    ${CYAN}${wrench} Import Users${NC}"
        cloudctl iam user-import -u demo -f
        cloudctl iam user-import -u dev -f
        cloudctl iam user-import -u test -f
        cloudctl iam user-import -u prod -f
        cloudctl iam user-import -u boss -f
        cloudctl iam user-import -u nik -f
        cloudctl iam user-import -u sre1 -f
        cloudctl iam user-import -u sre2 -f

        __output "---------------------------------------------------------------------------------------------------------------------------"
        __output "    ${CYAN}${wrench} Assign Users to Team${NC}"
        cloudctl iam team-add-users $TEAM_ID ClusterAdministrator -u demo
        cloudctl iam team-add-users $TEAM_ID Administrator -u dev
        cloudctl iam team-add-users $TEAM_ID Administrator -u test
        cloudctl iam team-add-users $TEAM_ID Administrator -u prod
        cloudctl iam team-add-users $TEAM_ID ClusterAdministrator -u boss    
        cloudctl iam team-add-users $TEAM_ID ClusterAdministrator -u nik
        cloudctl iam team-add-users $TEAM_ID ClusterAdministrator -u sre1
        cloudctl iam team-add-users $TEAM_ID ClusterAdministrator -u sre2

        __output "---------------------------------------------------------------------------------------------------------------------------"
        __output "    ${CYAN}${wrench} Add LDAP Resource${NC}"
        cloudctl iam resource-add $TEAM_ID -r crn:v1:icp:private:iam::::Directory:LDAP

        __output "---------------------------------------------------------------------------------------------------------------------------"
        __output "    ${CYAN}${wrench} Add Namespace Resources${NC}"
        cloudctl iam resource-add $TEAM_ID -r crn:v1:icp:private:k8:mycluster:n/$MCM_IMPORT_NAME:::
        cloudctl iam resource-add $TEAM_ID -r crn:v1:icp:private:k8:mycluster:n/default:::
        cloudctl iam resource-add $TEAM_ID -r crn:v1:icp:private:k8:mycluster:n/grpcdemo-app:::
        cloudctl iam resource-add $TEAM_ID -r crn:v1:icp:private:k8:mycluster:n/grpcdemo-app-ns:::
        cloudctl iam resource-add $TEAM_ID -r crn:v1:icp:private:k8:mycluster:n/modresort-app:::
        cloudctl iam resource-add $TEAM_ID -r crn:v1:icp:private:k8:mycluster:n/modresort-app-ns:::
        cloudctl iam resource-add $TEAM_ID -r crn:v1:icp:private:k8:mycluster:n/bookinfo-source:::
        cloudctl iam resource-add $TEAM_ID -r crn:v1:icp:private:k8:mycluster:n/bookinfo:::
        cloudctl iam resource-add $TEAM_ID -r crn:v1:icp:private:k8:mycluster:n/bookinfo-project:::

        __output "---------------------------------------------------------------------------------------------------------------------------"
        __output "    ${CYAN}${wrench} Add Service Accounts${NC}"

        cloudctl iam team-add-service-ids $TEAM_ID  -s cem-service-id 
        cloudctl iam team-add-service-ids $TEAM_ID  -s icam-cp4mcm-perfmon-applicationmgmt-id

      
        __output "---------------------------------------------------------------------------------------------------------------------------"
        __output "    ${CYAN}${wrench} Restore Context${NC}"
        kubectl config use-context $SPOKE_CONTEXT
header3End

headerModuleFileEnd "Register LDAP Users in CP4MCM " $0

