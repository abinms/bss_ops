#!/bin/bash
##########################
# Author:                 #
# Abin Sebastian          #
# Implementation Enginner #
# 6D Technologies         #
##########################
MSISDN_PRODUCTID=41328
DB_IP=127.0.0.1
DB_PORT=3306
DBUSER=stsuser
DBPASS=stsuser@6Dtech
export MYSQL_PWD='stsuser@6Dtech'
Val=$1


if [ $# -eq 1 ];then
        if [[ $Val = *"@"* ]];then
                mysql  -ustsuser   -h127.0.0.1 -P3306 BILLING -e "select profile_id,account_id,service_id,notification_email_id,rate_plan_id as Plan_ID,service_type_id as OCS_subscriber_ID,service_name,imsi_number,status,create_date,activation_date,termination_date from BS_SERVICE where notification_email_id='${Val}';"

                exit 0
        fi
 
        if [[ $Val != *","* ]];then

                echo -e "\e[1;33m INVENTORY Status\e[0m"
                mysql  -ustsuser   -h127.0.0.1 -P3306 INVENTORY -e "select SERIAL_NUMBER,ASSET_STATUS,CREATE_DATE,STATUS_MODIFY_DATE from ASSET_DETAILS where SERIAL_NUMBER='$1'"
                asset=`mysql  -ustsuser   -h127.0.0.1 -P3306 INVENTORY -sse  "select SEQ_ID  from ASSET_DETAILS where SERIAL_NUMBER='$1'"`
                mysql  -ustsuser   -h127.0.0.1 -P3306 INVENTORY -e  "select * from ASSET_SPECIFIC_DETAILS where ASSET_ID='$asset';"
         
         
                echo -e "\e[1;33m BILLING Status\e[0m"
                mysql  -ustsuser   -h127.0.0.1 -P3306 BILLING -e "select profile_id,account_id,service_id,notification_email_id,rate_plan_id as Plan_ID,service_type_id as OCS_subscriber_ID,service_name,imsi_number,status,create_date,activation_date,termination_date from BS_SERVICE where SERVICE_ID='$1' or IMSI_NUMBER='$1';"
                mysql  -ustsuser   -h127.0.0.1 -P3306 BILLING -e "select subscription_id,order_id,service_seq_id,service_id,plan_id,plan_name,is_base_plan,external_plan_id,create_date,activation_date,expiry_date,status from BS_SERVICE_SUBSCRIPTION_MASTER where service_id='$1';"
         
         
                echo -e "\e[1;33m OM Status \e[0m"
                mysql -ustsuser  -h127.0.0.1 -P3306  OM -e "select request_timestamp,Request_ID,ORDER_ID,SERVICE_ID,ORDER_TYPE,ORDER_STATUS,PENDING_ORDER_TYPE,FAILED_ORDER_REASON,CREATE_DATE,UPDATE_DATE from ORDER_MASTER where SERVICE_ID='$1'";
         
         
                echo -e "\e[1;33m CBS Status \e[0m"
                mysql -ustsuser  -h127.0.0.1 -P3306 UPC -e "select MSISDN,IMSI,SubscriberId,planID,currentStatus,CreationDate from CBS_SUBSCRIBER_INFO where MSISDN='$1';"
                mysql -ustsuser  -h127.0.0.1 -P3306 UPC -e "select Msisdn,PlanId,ExpiryDate,Status,SubscriptionCount,SubscriptionId from CBS_SUBSCRIBER_SUBSCRIPTION_CHARGE_DETAILS where MSISDN='$1';"
         
         
        else

                echo -e "\e[1;33m INVENTORY Status\e[0m"
                mysql  -ustsuser   -h127.0.0.1 -P3306 INVENTORY -e "select SERIAL_NUMBER,ASSET_STATUS from ASSET_DETAILS where SERIAL_NUMBER in ($Val) order by SERIAL_NUMBER;"
                asset=`mysql  -ustsuser   -h127.0.0.1 -P3306 INVENTORY -sse  "select ASSET_ID  from ASSET_SPECIFIC_DETAILS where ASSET_ID='$1'"`
                mysql  -ustsuser   -h127.0.0.1 -P3306 INVENTORY -e  "select * from ASSET_SPECIFIC_DETAILS where ASSET_ID='$asset';"
         
                echo -e "\e[1;33m BILLING Status\e[0m"
                mysql  -ustsuser   -h127.0.0.1 -P3306 BILLING -e "select profile_id,account_id,service_id,notification_email_id,rate_plan_id as Plan_ID,service_type_id as OCS_subscriber_ID,service_name,imsi_number,status,create_date,activation_date,termination_date from BS_SERVICE where SERVICE_ID in ($Val) order by service_id;"
         
                echo -e "\e[1;33m CBS Status \e[0m"
                mysql -ustsuser  -h127.0.0.1 -P3306 UPC -e "select MSISDN,IMSI,SubscriberId,planID,currentStatus,CreationDate from CBS_SUBSCRIBER_INFO where MSISDN in ($Val) order by MSISDN;"
         
        fi

elif [ $# -eq 0 ];then

        echo -e "\e[1;33mUse check OR check <MSISDN> OR check <Dummy/Serial/IMSI> \"1\"\e[0m"
 
        echo -e "\e[1;33mINVENTORY STATUS\e[0m"
 
        mysql  -ustsuser   -h127.0.0.1 -P3306 INVENTORY -e "select count(*) as FREE_MSISDNs from ASSET_DETAILS where PRODUCT=$MSISDN_PRODUCTID and ASSET_STATUS=1 and BLOCKING_ID='0';"
 
        mysql  -ustsuser   -h127.0.0.1 -P3306 INVENTORY -e "select count(*) as Temporary_Blocked_MSISDNs from ASSET_DETAILS where PRODUCT=$MSISDN_PRODUCTID and ASSET_STATUS=1 and BLOCKING_ID not in ('0');"
 
        echo "Summary:"
        mysql  -ustsuser   -h127.0.0.1 -P3306 INVENTORY -e "select ASSET_STATUS,count(*) as COUNT from ASSET_DETAILS where PRODUCT=$MSISDN_PRODUCTID group by ASSET_STATUS;"
        echo -e "1 - Free\n14 - Reserved\n4 - Sold\n10 - Terminated"
        echo -e "\n"
        echo "DUMMY NUMBER Summary:"
        mysql  -ustsuser   -h127.0.0.1 -P3306 INVENTORY -e "select case when ASSET_STATUS=1 then 'FREE' when ASSET_STATUS=4 then 'SOLD' else ASSET_STATUS end as STATUS,count(*) as COUNT from ASSET_DETAILS where PRODUCT=41327 group by ASSET_STATUS;"
        echo -e "1 - Free\n4 - Sold\n"

elif [ $# -eq 2 ];then

        if [[ $Val = *","* ]]; then
                multi=`echo $1| sed 's/,/ /g'`
        else
                multi=$1
        fi

        for parval in $multi ; do
 
                asset=`mysql  -ustsuser   -h127.0.0.1 -P3306 INVENTORY -sse  "select ASSET_ID  from ASSET_SPECIFIC_DETAILS where PARAM_VALUE='$parval'"`
         
                mysql  -ustsuser   -h127.0.0.1 -P3306 INVENTORY -e  "select * from ASSET_SPECIFIC_DETAILS where ASSET_ID='$asset' and PARAM_NAME in ('IMSI','Serial_number','T_MSISDN','A4KI');"
         
                mysql  -ustsuser   -h127.0.0.1 -P3306 INVENTORY -e  "select ASSET_STATUS,SERIAL_NUMBER as ICCID,PRODUCT,STATUS_MODIFY_DATE from ASSET_DETAILS where SEQ_ID='$asset';"
         
                imsi=`mysql  -ustsuser   -h127.0.0.1 -P3306 INVENTORY -sse "select PARAM_VALUE from ASSET_SPECIFIC_DETAILS where ASSET_ID=$asset and PARAM_NAME='IMSI'"`
                mysql  -ustsuser   -h127.0.0.1 -P3306 BILLING -e "select profile_id,account_id,service_id,rate_plan_id as Plan_ID,service_type_id as OCS_subscriber_ID,migrated_subscriber_id as migrated_OCS_subscriber_id,service_name,imsi_number,status,create_date,activation_date from BS_SERVICE where  IMSI_NUMBER='$imsi';"
                echo "-------------------------------------------------------------------------------"
        done
else

        echo -e "\e[1;33mUse <scriptname> OR <scriptname> <MSISDN> OR <scriptname> <Dummy/Serial/IMSI> 1\e[0m"

fi

