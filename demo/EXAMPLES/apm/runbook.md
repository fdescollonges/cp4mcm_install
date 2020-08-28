NAMESPACE 


Handle Liveness Probe
Procedure describing how to handle Liveness Probe


Check if the Pod is still running
kubectl get pods -n  NAMESPACE  PODNAME 
If the return value is empty proceed with the next steps.

Get the name of the Pod
kubectl get pods -n  NAMESPACE  | grep <ypur-pod-name>

Check the logs
kubectl logs -n NAMESPACE  kubetoy-deployment-<your-pod-id>

Restart the pod if needed
kubectl delete pod -n NAMESPACE <your-pod-id>
















