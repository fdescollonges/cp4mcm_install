
kubectl delete -f ./2_mcm-app/01-productpage-deployable.yaml
kubectl delete -f ./2_mcm-app/02-details-deployable.yaml
kubectl delete -f ./2_mcm-app/03-reviews-deploayble.yaml
kubectl delete -f ./2_mcm-app/04-ratings-deployable.yaml
kubectl delete -f ./2_mcm-app/05-mysqldb-deployable.yaml
kubectl delete -f ./2_mcm-app/06-bookinfo-ns-channel.yaml
kubectl delete -f ./2_mcm-app/07-bookinfo-placementrules.yaml
kubectl delete -f ./2_mcm-app/08-bookinfo-multicluster.yaml
kubectl delete -f ./2_mcm-app/09-bookinfo-addon.yaml
