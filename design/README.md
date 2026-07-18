# Kubernetes The Hard Way 設計書

```
provisioner
    │
    ▼
admin
    │
    ▼
bootstrap
    │
    ▼
cluster
```

| Name      | Layer              | Role                                                       |
| --------- | ------------------ | ---------------------------------------------------------- |
| provisioner |  初回実行環境  | adminを構築するためのもの |
| admin     | 管理用             | クラスタ構築用のコードを開発・実行するマシン               |
| bootstrap | クラスタ構築環境   | Ansible、Terraform、kubeadm などでクラスタを構築する仕組み |
| cluster   | Kubernetesクラスタ | 実際に稼働するクラスタ                                     |
