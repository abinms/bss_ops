#!/bin/bash
. ~/.bashrc
#########################
# Author:               #
# Abin Sebastian        #
#Implementation Enginer #
# 6D Technologies       #
#########################


DB_IP=127.0.0.1
DB_PORT=3306
DBUSER=stsuser
DBPASS='stsuser@6Dtech'
Val=$1
ERRDESC=""
export MYSQL_PWD='stsuser@6Dtech'

if [ $# -eq 1 ];then
if [ ${#Val} -eq 14 ] && [[ ${Val} != "," ]]; then

echo -e "\e[1;31m Order Status \e[0m"

mysql -ustsuser  -h127.0.0.1 -P3306  OM_BSS -e "select REQUEST_ID,ORDER_ID,SOURCE_NODE,SERVICE_ID,SERVICE_SEQ_ID,CUSTOMER_NAME,ORDER_TYPE,ORDER_STATUS,PAYMENT_AMOUNT,PENDING_ORDER_TYPE as PENDING,FAILED_ORDER_REASON as FAILED,CREATE_DATE,UPDATE_DATE from ORDER_MASTER where ORDER_ID='$1'";
mysql -ustsuser  -h127.0.0.1 -P3306  OM_BSS -e "select seq_id,sub_order_id,ORDER_ID,order_code,sub_order_stage,sub_order_stage_status,error_desc,error_code,create_date,update_date from SUB_ORDER_STAGES where ORDER_ID='$1';"
elif [ ${#Val} -eq 13 ];then

#mysql -ustsuser  -h127.0.0.1 -P3306 OM -sse "select ORDER_INFO FROM ORDER_MASTER WHERE ORDER_INFO like '%$1%';"

echo -e "\e[1;31m Order Status \e[0m"
mysql -ustsuser  -h127.0.0.1 -P3306  OM_BSS -e "select REQUEST_ID,ORDER_ID,SERVICE_ID,SERVICE_SEQ_ID,SOURCE_NODE,CUSTOMER_NAME,ORDER_TYPE,ORDER_STATUS,PAYMENT_AMOUNT,PENDING_ORDER_TYPE as PENDING,FAILED_ORDER_REASON as FAILED,CREATE_DATE,UPDATE_DATE from ORDER_MASTER where SERVICE_ID='$1'";
elif [[ ${Val} == "," ]];then

Sample=`echo $Val|cut -d"," -f 1`

if [ ${#Sample} -eq 14 ];then

echo -e "\e[1;31m Order Status \e[0m"
mysql -ustsuser  -h127.0.0.1 -P3306  OM_BSS -e "select REQUEST_ID,ORDER_ID,SERVICE_ID,SERVICE_SEQ_ID,CUSTOMER_NAME,ORDER_TYPE,ORDER_STATUS,PENDING_ORDER_TYPE as PENDING,FAILED_ORDER_REASON as FAILED,CREATE_DATE,UPDATE_DATE from ORDER_MASTER where ORDER_ID in ($Val)";

elif [ ${#Sample} -eq 13 ];then
Msisdn=`echo $Val|sed 's/,/ /g'`
for Val in $Msisdn ;do
echo -e "\e[1;31m Order Status: $Val \e[0m"
mysql -ustsuser  -h127.0.0.1 -P3306  OM_BSS -e "select REQUEST_ID,ORDER_ID,PROFILE_ID,ACCOUNT_ID,SERVICE_ID,SERVICE_SEQ_ID,CUSTOMER_NAME,ORDER_TYPE,ORDER_STATUS,PENDING_ORDER_TYPE as PENDING,FAILED_ORDER_REASON as FAILED,CREATE_DATE,UPDATE_DATE from ORDER_MASTER where SERVICE_ID='$Val'";
done
fi

else
echo -e "Usage: \e[1;31m $0 <Order ID>\e[0m"
fi

elif [ $# -eq 2 ];then 

if [ $2 -eq 2 ];then
mysql -ustsuser  -h127.0.0.1 -P3306  OM_BSS -e "select REQUEST_ID,ORDER_ID,SOURCE_NODE,SERVICE_ID,SERVICE_SEQ_ID,CUSTOMER_NAME,ORDER_TYPE,ORDER_STATUS,PENDING_ORDER_TYPE as PENDING,FAILED_ORDER_REASON as FAILED,CREATE_DATE,UPDATE_DATE from ORDER_MASTER where REQUEST_ID='$1'";
exit 0
else
Val=$1
fi
Val=$1
ERRDESC=""
export MYSQL_PWD='stsuser@6Dtech'
tDay=`date '+%Y-%m-%d-%H'`

if [ ${#Val} -eq 14 ];then
#ORDERINFO=`mysql -ustsuser -pstsuser@6Dtech -h127.0.0.1 -P3306 OM -sse "select ORDER_INFO FROM ORDER_MASTER WHERE ORDER_ID='$1';"`
REQID=`mysql -ustsuser -h127.0.0.1 -P3306 OM_BSS -sse "select REQUEST_ID FROM ORDER_MASTER WHERE ORDER_ID='$1';"`
echo -e "\e[1;31m Initial Request (Create Order)\e[0m"
createDateInitial=`mysql -ustsuser -h127.0.0.1 -P3306 OM_BSS -sse "select LEFT(CREATE_DATE,13) FROM ORDER_MASTER WHERE ORDER_ID='$1';"|sed 's/ /-/'`

#if [ $createDateInitial = $tDay ] ; then
#grep $REQID /data/stsuser/LOGS/APIGateway_LOGS/ApiGateway.log | egrep 'Auth|OutPut from server'
#else
#grep $REQID /data/stsuser/LOGS/APIGateway_LOGS/ApiGateway.log.${createDateInitial} | egrep 'Auth|OutPut from server'
#fi

mysql -ustsuser -h127.0.0.1 -P3306 OM_BSS -sse "select ORDER_INFO FROM ORDER_MASTER WHERE ORDER_ID='$1';"

echo -e "\e[1;31m MakePayment Request (if applicable) \e[0m"

#MPOC=`mysql -ustsuser -h127.0.0.1 -P3306  OM -sse "select count(*) from ORDER_MASTER where ORDER_TYPE='MakePayment' and ORDER_INFO LIKE '%$1%'"`
#MPOrder=`mysql -ustsuser -h127.0.0.1 -P3306  OM -sse "select REQUEST_ID,ORDER_ID,LEFT(CREATE_DATE,13) from ORDER_MASTER where ORDER_TYPE='MakePayment' and ORDER_INFO LIKE '%$1%'"`

if [ $MPOC -ne 0 ];then

MPOrderID=`echo $MPOrder | awk '{print $2}'`
MPRequestID=`echo $MPOrder | awk '{print $1}'`
createDateMP=`echo $MPOrder | awk '{print $3"-"$4}'`

echo "MakePayment Order ID: $MPOrderID, Request ID: $MPRequestID"

if [ $createDateMP = $tDay ] ; then
grep $MPRequestID /data/stsuser/LOGS/APIGateway_LOGS/ApiGateway.log| egrep 'Auth|OutPut from server'|grep -v "ViewSubOrderDetails"
else
grep $MPRequestID /data/stsuser/LOGS/APIGateway_LOGS/ApiGateway.log.${createDateMP}| egrep 'Auth|OutPut from server'|grep -v "ViewSubOrderDetails"
fi

fi

echo -e "\e[1;31m Update Order Request (if applicable) \e[0m"
#updateDate=`mysql -ustsuser -pstsuser@6Dtech -h127.0.0.1 -P3306 OM_BSS -sse "select LEFT(UPDATE_DATE,13) FROM ORDER_MASTER WHERE ORDER_ID='12281261749501';"|sed 's/ /-/'`
updateDate=`mysql -ustsuser  -h127.0.0.1 -P3306 OM_BSS -sse "select LEFT(UPDATE_DATE,13) FROM SUB_ORDER_STAGES WHERE ORDER_ID='$1' and sub_order_stage in ('Sim Delivery','Asset Validation','Digicore Prepaid Validation','Payment');"|sed 's/ /-/'|sort -h|tail -1`

tDay=`date '+%Y-%m-%d-%H'`

if [ $updateDate != NULL ];then
if [ $updateDate = $tDay ] ; then
updateRequest=`grep '"action":"UpdateOrder"' /data/stsuser/LOGS/APIGateway_LOGS/ApiGateway.log|egrep 'Auth' |grep $1`
updateRequestId=`echo $updateRequest | grep -Po '"request_id": \K"[^"]"'|sed 's/"//g'`
updateRequestId=`echo $updateRequestId | sed "s/ /|/g"`
if [ ${#updateRequestId} -ne 0 ];then
egrep $updateRequestId /data/stsuser/LOGS/APIGateway_LOGS/ApiGateway.log|egrep 'Auth|OutPut from server'
fi
else
updateDate="`echo $updateDate | cut -c 1-10`*"
updateRequest=`grep '"action":"UpdateOrder"' /data/stsuser/LOGS/APIGateway_LOGS/ApiGateway.log.${updateDate}|egrep 'Auth' |grep $1`
updateRequestId=`echo $updateRequest | grep -Po '"request_id": \K"[^"]"'|sed 's/"//g'`
updateRequestId=`echo $updateRequestId | sed "s/ /|/g"`
if [ ${#updateRequestId} -ne 0 ];then
egrep $updateRequestId /data/stsuser/LOGS/APIGateway_LOGS/ApiGateway.log.${updateDate}|egrep 'Auth|OutPut from server'
fi
fi
fi

else
echo -e "\e[1;31m Invalid Order ID $Val \e[0m"
fi



else

echo -e "\e[1;31m FILTER ORDERS. \n Optional Parameters to be passed. Please Input if only applicable Else press Enter.\e[0m \n"
read -ep "1. Order Type (1-ProfileAccountService,2-MakePayment,3-AddSubscription,4-Recharge/Topup): " OType
echo ""
read -ep "2. Create Date (eg: `date "+%Y-%m-%d"`): " cDate
echo ""
read -ep "3. Update date (YYYY-MM-DD): " uDate
echo ""
read -ep "4. Status (1-completed,2-Failed,3-In Progress,4-Pending): " Stat

case $OType in 
        1)
        Type="ORDER_TYPE='ProfileAccountService' and"
        ;;
        2)
        Type="ORDER_TYPE='MakePayment' and"
        ;;
        3)
        Type="ORDER_TYPE='AddSubscription' and"
        ;;
        4)
        Type="ORDER_TYPE in ('Recharge','Topup') and"
        ;;
esac

case $Stat in
        1)
        Status="Completed"
        ;;
        2)
        Status="Failed"
        #ERRDESC="(B.error_code in (select error_code from SUB_ORDER_STAGES where sub_order_stage_status='Failed') or (B.error_code is NULL and b.sub_order_stage_status='Failed') ) and "
        ERRDESC="B.sub_order_stage_status='Failed' and" 
        ;;
        3)
        Status="In-Progress"
        ;;
        4)
        Status="Pending"
        ;;
esac

Params=`echo "$OType|$cDate|$uDate|$Status"`
#echo Parameters: $Params
if [ ${#Params} -gt 3 ];then
 echo -e "\e[1;32m\nParameters: $Params \e[0m \n"

if [ "${uDate}" ];then
if [ "$uDate" == "t" ];then
        uDate=`date "+%Y-%m-%d"`
fi
UPD="UPDATE_DATE like '$uDate%' and"
else
UPD=""
fi
if [ "${cDate}" ];then
if [ "$cDate" == "t" ];then
        cDate=`date "+%Y-%m-%d"`
fi
CPD="CREATE_DATE like '$cDate%' and"
else
CPD=""
fi


ct=`mysql -ustsuser  -h127.0.0.1 -P3306  OM_BSS -sse "select count(*) from ORDER_MASTER where $Type $CPD $UPD  ORDER_STATUS like '$Status%';"`

if [ $ct -gt 100 ];then

echo -e "\e[1;32m\nTotal Count: "$ct"\e[0m"

read -p "Press Enter to show all. (Ctrl+C to quit)"

fi

if [ $Stat ]; then
if  [ $Stat -eq 2 ];then

mysql -ustsuser  -h127.0.0.1 -P3306  OM_BSS -e "select A.REQUEST_ID,A.ORDER_ID,A.SERVICE_ID,A.source_node,CUSTOMER_NAME,A.ORDER_TYPE,A.ORDER_STATUS,A.PENDING_ORDER_TYPE as PENDING,A.FAILED_ORDER_REASON as FAILED_STAGE,B.ERROR_CODE,B.ERROR_DESC,A.CREATE_DATE,A.UPDATE_DATE from ORDER_MASTER A,SUB_ORDER_STAGES B where $ERRDESC A.ORDER_ID=B.ORDER_ID and $Type $CPD $UPD A.ORDER_STATUS like '$Status%'";
elif [ $Stat -eq 1 ];then
mysql -ustsuser  -h127.0.0.1 -P3306  OM_BSS -e "select A.REQUEST_ID as RequestID,A.ORDER_ID as OrderID,A.SERVICE_ID as Msisdn,A.source_node,CUSTOMER_NAME as Name,A.ORDER_TYPE as Type,A.ORDER_STATUS as Status,A.CREATE_DATE as CreateDate,A.UPDATE_DATE as ActivationDate from ORDER_MASTER A where $Type $CPD $UPD A.ORDER_STATUS like '$Status%';" 
fi
else
mysql -ustsuser  -h127.0.0.1 -P3306  OM_BSS -e "select A.REQUEST_ID,A.ORDER_ID,A.SERVICE_ID,A.SOURCE_NODE,CUSTOMER_NAME,A.ORDER_TYPE,A.ORDER_STATUS,A.PENDING_ORDER_TYPE as PENDING,A.FAILED_ORDER_REASON as FAILED_STAGE,A.CREATE_DATE,A.UPDATE_DATE from ORDER_MASTER A where $Type $CPD $UPD A.ORDER_STATUS like '$Status%' order by A.UPDATE_DATE";
fi
#mysql -ustsuser  -h127.0.0.1 -P3306  OM_BSS -e "select A.REQUEST_ID,A.ORDER_ID,A.SERVICE_ID,A.SERVICE_SEQ_ID,A.ORDER_TYPE,A.ORDER_STATUS,A.PENDING_ORDER_TYPE as PENDING,A.FAILED_ORDER_REASON as FAILED_STAGE,B.error_code,B.ERROR_DESC,A.CREATE_DATE,A.UPDATE_DATE from ORDER_MASTER A,SUB_ORDER_DETAILS B where  A.ORDER_ID=B.ORDER_ID and $Type CREATE_DATE like '$cDate%' and  UPDATE_DATE like '$uDate%' and ORDER_STATUS like '$Status%'";

echo -e "\e[1;32m\nTotal Count: $ct\e[0m"


else
        echo -e "\e[1;31mEnter At lease one filter. Blind Search Not allowed.\e[0m"
fi

fi
