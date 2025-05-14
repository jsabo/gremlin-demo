# AWS CNI with AWS Networking

This example demonstrates how to provision an EKS cluster using the AWS CNI with AWS networking.

## Prerequisites:

First, ensure that you have installed the following tools locally.

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deploy

To provision this example:

```sh
terraform init
terraform apply
```

Enter `yes` at command prompt to apply

### Validate

1. Run `update-kubeconfig` command:

```sh
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME> --alias <CLUSTER_NAME>
```

2. View the pods that were created:

```sh
kubectl get pods -A

# Output should show some pods running
NAMESPACE          NAME                                       READY   STATUS    RESTARTS   AGE
kube-system        aws-node-l5sq6                             1/1     Running   0          3m11s
kube-system        aws-node-n4xf9                             1/1     Running   0          3m9s
kube-system        coredns-55fb5d545d-w2tq8                   1/1     Running   0          10m
kube-system        coredns-55fb5d545d-x5np4                   1/1     Running   0          10m
kube-system        kube-proxy-lnlc4                           1/1     Running   0          3m11s
kube-system        kube-proxy-xjhfk                           1/1     Running   0          3m9s
```

3. View the nodes that were created:

```sh
kubectl get nodes

# Output should show some nodes running
NAME                           STATUS   ROLES    AGE   VERSION
ip-10-0-163-151.ec2.internal   Ready    <none>   11m   v1.24.10-eks-48e63af
ip-10-0-163-9.ec2.internal     Ready    <none>   10m   v1.24.10-eks-48e63af
```

### Destroy

To teardown and remove the resources created in this example:

```sh
terraform destroy --auto-approve
```
