# Kubernetes The Hard Way 設計書

```
bootstrap
    │
    ▼
admin
    │
    ▼
provisioner
    │
    ▼
cluster
```

| Name      | Layer              | Role                                                       |
| --------- | ------------------ | ---------------------------------------------------------- |
| bootstrap |  初回実行環境  | adminを構築するためのもの |
| admin     | 管理用             | クラスタ構築用のコードを開発・実行するマシン               |
| provisioner | クラスタ構築環境   | Ansible、Terraform、kubeadm などでクラスタを構築する仕組み |
| cluster   | Kubernetesクラスタ | 実際に稼働するクラスタ                                     |
