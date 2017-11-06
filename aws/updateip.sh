#!/bin/bash


IP_ADDR=`kubectl get svc --namespace default -l "app=nginx-ingress" -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}"`
while [[ -z "$IP_ADDR" ]]; do
    IP_ADDR=`kubectl get svc --namespace default -l "app=nginx-ingress" -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}"`
    sleep 5
done
cat route53-record-set.tmplate | sed "s/IP_ADDRESS/${IP_ADDR}/" > out.tmp; aws route53 change-resource-record-sets --hosted-zone-id ZY5EM47I4DVOK --change-batch file://out.tmp; rm out.tmp
