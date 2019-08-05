docker build -t tienvv1234/multi-client:latest -t tienvv1234/multi-client:$SHA -f ./client/Dockerfile ./client
docker build -t tienvv1234/multi-server:latest -t tienvv1234/multi-server:$SHA -f ./server/Dockerfile ./server
docker build -t tienvv1234/multi-worker:latest -t tienvv1234/multi-worker:$SHA -f ./worker/Dockerfile ./worker
docker push tienvv1234/multi-client:latest
docker push tienvv1234/multi-server:latest
docker push tienvv1234/multi-worker:latest

docker push tienvv1234/multi-client:$SHA
docker push tienvv1234/multi-server:$SHA
docker push tienvv1234/multi-worker:$SHA

kubectl apply -f k8s
kubectl set image deployments/server-deployment server=tienvv1234/multi-server:$SHA
kubectl set image deployments/client-deployment client=tienvv1234/multi-client:$SHA
kubectl set image deployments/worker-deployment worker=tienvv1234/multi-worker:$SHA