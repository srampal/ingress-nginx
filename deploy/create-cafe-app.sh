sudo kubectl create namespace cafe-app
sudo kubectl create -f cafe-example/tea-rc.yaml --namespace=cafe-app
sudo kubectl create -f cafe-example/tea-svc.yaml --namespace=cafe-app
sudo kubectl create -f cafe-example/coffee-rc.yaml --namespace=cafe-app
sudo kubectl create -f cafe-example/coffee-svc.yaml --namespace=cafe-app
sudo kubectl create -f cafe-example/cafe-secret.yaml --namespace=cafe-app
sudo kubectl create -f cafe-example/cafe-ingress.yaml --namespace=cafe-app

