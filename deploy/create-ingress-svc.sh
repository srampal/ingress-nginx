sudo kubectl create -f namespace.yaml
sudo kubectl create -f default-backend.yaml
sudo kubectl create -f configmap.yaml
sudo kubectl create -f tcp-services-configmap.yaml
sudo kubectl create -f udp-services-configmap.yaml
sudo kubectl create -f ./provider/baremetal/default-server-secret.yaml --namespace=ingress-nginx
sudo kubectl create -f ./provider/baremetal/nginx-ingress-rc.yaml --namespace=ingress-nginx

