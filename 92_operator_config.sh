#!/bin/bash

# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# Functions for install scripts
#
# V2.0 
#
# ©2020 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"



# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# Functions for creating CP4MCM Operator Config
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"

        function initInfraBlocks() {
            
        header2Begin "Determining Config Block for CP4MCM install config" "wrench"
            
            


            if [[ $INSTALL_CP4MCM  == true ]]; 
            then
                __output "   ${GREEN}${wrench} CP4MCM Foundation will be installed${NC}"
                export DISABLE_MCM_CORE_INSTALL=false
            else
                __output "   ${RED}${wrench} CP4MCM Foundation disabled${NC}"
                export DISABLE_MCM_CORE_INSTALL=true
            fi
           
            if [[ $INSTALL_INFRA_CAM  == true || $INSTALL_INFRA_VM  == true || $INSTALL_INFRA_GRC  == true || $INSTALL_INFRA_SERVICE_LIBRARY  == true ]]; 
            then
            __output "   ${GREEN}${wrench} Some CP4MCM Infrastructure Management Modules will be installed${NC}"
                export INSTALL_BLOCK_INFRA=true
            else
                __output "   ${RED}${wrench} All CP4MCM Infrastructure Management Modules disabled${NC}"
                export INSTALL_BLOCK_INFRA=false
            fi
           

            if [[ $INSTALL_MON_MONITORING  == true ]]; 
            then
            __output "   ${GREEN}${wrench} Some CP4MCM Monitoring Modules will be installed${NC}"
                export INSTALL_BLOCK_MON=true
            else
                __output "   ${RED}${wrench} All CP4MCM Monitoring Modules disabled${NC}"
                export INSTALL_BLOCK_MON=false
            fi
           

            if [[ $INSTALL_MCMCIS  == true || $INSTALL_MCMMUT  == true || $INSTALL_MCMNOT  == true || $INSTALL_MCMIMGSEC  == true || $INSTALL_MCMVUL  == true ]]; 
            then
            __output "   ${GREEN}${wrench} Some CP4MCM Security Modules will be installed${NC}"
                export INSTALL_BLOCK_SEC=true
            else
                __output "   ${RED}${wrench} All CP4MCM Security Modules disabled${NC}"
                export INSTALL_BLOCK_SEC=false
            fi
           

            if [[ $INSTALL_OPS_CHAT  == true ]]; 
            then
            __output "   ${GREEN}${wrench} Some CP4MCM Operations Modules will be installed${NC}"
                export INSTALL_BLOCK_OPS=true
            else
                __output "   ${RED}${wrench} All CP4MCM Operations Modules disabled${NC}"
                export INSTALL_BLOCK_OPS=false
            fi
           

            if [[ $INSTALL_TP_MNG_RT  == true ]]; 
            then
            __output "   ${GREEN}${wrench} Some CP4MCM Tech Preview Modules will be installed${NC}"
                export INSTALL_BLOCK_TP=true
            else
                __output "   ${RED}${wrench} All CP4MCM Tech Preview Modules disabled${NC}"
                export INSTALL_BLOCK_TP=false
            fi
           

        header2End "Determining Config Block for CP4MCM install config" "wrench"


        }

