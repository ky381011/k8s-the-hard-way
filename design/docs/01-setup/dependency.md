# Set Up 設計

## リスト
| Layer              | Role                                                       | Name      |
| ------------------ | ---------------------------------------------------------- | --------- |
| 管理用             | クラスタ構築用のコードを開発・実行するマシン               | admin     |
| クラスタ構築環境   | Ansible、Terraform、kubeadm などでクラスタを構築する仕組み | bootstrap |
| Kubernetesクラスタ | 実際に稼働するクラスタ                                     | cluster   |

## 概要図

```mermaid
%%{init: {'theme': 'default'}}%%
graph TB
    classDef Machine fill:#22FF88,fill-opacity:0.2,font-weight:bold
    classDef Tools fill:#2288FF,fill-opacity:0.2
    classDef Description fill:#FFFFFF

    subgraph admin ["クライアントセットアッパー"]
        adminTools["ansible"]
        adminDescription["クライアントセットアップを行うマシン"]
    end

    subgraph bootstrap ["クラスターセットアッパー"]
        bootstrapTools["ansible</br>kubectl</br>helm</br>CA</br>etc..."]
        bootstrapDescription["クラスタセットアップを行うマシン（CA機能搭載）"]
    end
    
    subgraph cluster ["Kubernetesクラスタ"]
        clusterTools["kubelet</br>kubeproxy</br>etcd</br>etc..."]
        clusterDescription["K8Sのマスター＋ワーカー"]
    end
    
    admin --> bootstrap --> cluster

    class bootstrap Machine
    class admin Machine
    class cluster Machine
    class adminTools Tools
    class bootstrapTools Tools
    class clusterTools Tools
    class adminDescription Description
    class bootstrapDescription Description
    class clusterDescription Description
```

## 役割
### admin
kubernetesクラスターを構築するマシンに対してセットアップを行うマシン
Ansibleのみインストールしクラスタのセットアップに必要なツールはインストールしない

### bootstrap
kubernetesクラスターを構築するマシン
クラスタには参加せずセットアップのみを行う
また、クラスタのCA（認証局）としても機能する

<details><summary>インストールするツール一覧</summary>

- マシン構築
  - Ansible
- クラスタ構築
  - kubectl
  - Helm
  - Cilium CLI
</details>
