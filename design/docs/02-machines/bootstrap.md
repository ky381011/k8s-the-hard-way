# bootstrap

## 用途
Kubernetesクラスターを構築するマシン
クラスタには参加せずセットアップのみを行う

## 要件
<details>
<summary>詳細</summary>

- 当マシンのみでクラスターのセットアップが可能
  - クラスターの操作を行うことができるツールがそろっている
- ターゲットノードへの公開鍵認証による接続
- クラスター内の全ノードと通信可能なネットワーク環境

</details>

## 基本設計

<details>
<summary>詳細</summary>

### コンテナ構成
```
Proxmox LXC コンテナ
├─ OS: Ubuntu 22.04 LTS
├─ インストール: kubectl, Ansible, cfssl, etcdctl
├─ セットアップツール (管理対象)
│  └─ Ansible により adminから制御
└─ 設定ファイル (ボリュームマウント)
```

### リソース仕様
| 項目 | 仕様 |
|------|------|
| CPU | 2 core |
| メモリ | 4GB |
| ストレージ | 50GB |
| ベースイメージ | Ubuntu 22.04 LTS |

### ランタイム構成

#### インストール内容
- **kubectl**: Kubernetes クラスター操作
- **Ansible**: クラスタノード管理
- **cfssl**: 証明書生成ツール
- **etcdctl**: etcd 管理ツール
- **ランタイム依存**: containerd, Python 3, OpenSSH

#### 永続ストレージ構成
| パス | マウント元 | 用途 |
|-----|---------|------|
| `/mnt/playbooks` | ホスト playbook リポジトリ | Ansible プレイブック |
| `/mnt/ssh-keys` | ホスト秘密鍵ディレクトリ | SSH 認証用秘密鍵 |
| `/var/log/setup` | コンテナ内ストレージ | セットアップログ保存 |

#### 実行環境
```
bootstrap コンテナ (起動時の状態)
├─ Kubernetes ツール: 設定済みで即実行可能
├─ SSH Agent: playbooks ディレクトリの鍵を自動ロード
├─ 作業用ユーザー: setupper (uid:1000)
└─ 初期状態: admin 側から Ansible で制御可能
```

### ネットワーク仕様
- **IP アドレス**: 10.0.0.11 (固定割り当て)
- **接続方式**: Proxmox Linux ブリッジ (vmbr0)
- **到達可能性**: プライベートネットワーク内のすべてのノード
- **インバウンド SSH**: admin からのポート 22 接続受け入れ

### 動作仕様

#### 初期化フロー (コンテナ起動時)
```
1. Proxmox LXC コンテナ起動
   ↓
2. マウントポイント確認 (/mnt/playbooks, /mnt/ssh-keys)
   ↓
3. SSH Agent 起動と鍵ロード
   ↓
4. Kubernetes ツール初期化
   ↓
5. 準備完了 (admin からの Ansible 実行待機)
```

#### 実行パターン
- **admin 経由の実行**: Ansible により admin から自動実行
- **手動メンテナンス**: コンテナにログインして対話的に実行
- **クラスター検証**: kubectl で動作確認

### 制約事項
- クラスターノードとしては機能しない (単なるセットアップツール)
- 外部インターネット接続不可 (プライベートネットワークのみ)
- 複数セットアップの並行実行は非推奨 (順次実行を想定)

### 再利用・運用仕様
- **テンプレート化**: 基本セットアップ完了後にスナップショット化
- **複製**: 新規構築時は複製した新規コンテナを起動
- **状態管理**: マウント先ホスト側でバージョン管理
- **ログ保持**: `/var/log/setup` を定期バックアップ

</details>

## 詳細設計

<details>
<summary>詳細</summary>

### ファイルシステム構造

#### ディレクトリ階層
```
bootstrap コンテナ
├── /root
│   ├── .ssh/
│   │   ├── config            # SSH クライアント設定
│   │   ├── authorized_keys   # Ansible リモート実行用公開鍵
│   │   └── known_hosts       # 既知ホスト情報キャッシュ
│   ├── .ansible/
│   │   ├── plugins/          # Ansible 拡張プラグイン
│   │   └── roles/            # ローカルロール (リンク)
│   └── .kube/
│       └── config            # kubectl 設定ファイル
├── /home/setupper/           # 作業用ユーザーホームディレクトリ
│   ├── .ssh/                 # SSH エージェント実行用
│   ├── .kube/                # kubeconfig (読取専用レプリカ)
│   └── work/                 # 作業ディレクトリ
├── /mnt/playbooks            # 外部マウント: Ansible プレイブック
│   ├── group_vars/           # グループ変数
│   ├── host_vars/            # ホスト変数
│   ├── roles/                # Ansible ロール
│   ├── common.yml            # 共通タスク
│   ├── cluster-setup.yml     # クラスター構築プレイブック
│   └── nodes.ini             # インベントリ
├── /mnt/ssh-keys             # 外部マウント: SSH 秘密鍵
│   ├── bootstrap.key         # bootstrap 用秘密鍵
│   ├── cluster-setup.key     # クラスター構築用秘密鍵
│   └── ca/                   # CA 秘密鍵 (不揮発)
├── /var/log/setup            # セットアップログ
│   ├── init.log              # 初期化ログ
│   ├── ansible.log           # Ansible 実行ログ
│   └── errors.log            # エラーログ
├── /opt/kubernetes/          # Kubernetes ツール
│   ├── bin/                  # バイナリ配置
│   └── config/               # デフォルト設定
└── /etc/bootstrap/           # bootstrap 固有設定
    ├── ssh-agent.conf        # SSH Agent 設定
    ├── ansible.cfg           # Ansible 設定ファイル
    └── init-hooks.d/         # 起動時実行スクリプト
```

#### マウント詳細
| パス | タイプ | 権限 | 説明 |
|-----|------|------|------|
| `/mnt/playbooks` | bind | r/w | Ansible プレイブックリポジトリ (ホスト側で管理) |
| `/mnt/ssh-keys` | bind | r/w | SSH 秘密鍵ディレクトリ (ホスト側で管理) |
| `/var/log/setup` | ローカル | r/w | ログ保存先 (コンテナ内ストレージ) |

### パッケージ・ツールのインストール詳細

#### インストール順序とバージョン管理
```
Phase 1: OS 基盤 (Ubuntu 22.04 LTS デフォルト)
  ├─ apt update && apt upgrade
  ├─ base-files, util-linux, coreutils
  └─ build-essential (C++ コンパイラ依存)

Phase 2: 実行環境
  ├─ Python 3.10+
  │   ├─ python3-venv
  │   ├─ python3-pip
  │   └─ python3-dev (ライブラリコンパイル用)
  └─ OpenSSH サーバー
      ├─ openssh-server
      └─ openssh-client

Phase 3: クラスター管理ツール
  ├─ Kubernetes (v1.28+)
  │   ├─ kubectl
  │   └─ kubelet
  ├─ cfssl / cfssljson (証明書生成)
  ├─ etcdctl (etcd 管理)
  ├─ Helm (パッケージマネージャー)
  └─ Container runtime
      └─ containerd (プロビジョニング用)

Phase 4: Ansible と依存関係
  ├─ ansible (メインツール)
  ├─ ansible-core (v2.14+)
  ├─ jinja2, pyyaml (テンプレート・シリアライズ)
  └─ paramiko, cryptography (SSH・暗号化)

Phase 5: 補助ツール
  ├─ git (バージョン管理)
  ├─ curl, wget (ダウンロード)
  ├─ jq (JSON パース)
  └─ htop, tmux (デバッグ・管理)
```

#### バージョン固定戦略
```
/opt/kubernetes/.versions
├─ kubernetes-version.txt     # v1.28.x
├─ ansible-version.txt        # 2.14.x
├─ helm-version.txt           # 3.x
└─ cfssl-version.txt          # 1.6.x
```

### SSH 設定の詳細

#### SSH Agent 自動起動スクリプト
**ファイル**: `/etc/bootstrap/init-hooks.d/01-ssh-agent.sh`
```bash
#!/bin/bash
set -e

# SSH Agent の起動
eval $(ssh-agent -s) || exit 1

# 秘密鍵のロード
ssh-add /mnt/ssh-keys/bootstrap.key 2>/dev/null || true
ssh-add /mnt/ssh-keys/cluster-setup.key 2>/dev/null || true

# Agent PID をファイルに保存 (setupper で再利用可能)
echo $SSH_AGENT_PID > /var/run/ssh-agent.pid
echo $SSH_AUTH_SOCK > /var/run/ssh-auth-sock

# setupper ユーザーがアクセス可能に
chmod 666 /var/run/ssh-auth-sock 2>/dev/null || true
chown setupper:setupper /var/run/ssh-auth-sock 2>/dev/null || true
```

#### SSH クライアント設定
**ファイル**: `/root/.ssh/config`
```
Host cluster-*
    User k8s-admin
    StrictHostKeyChecking accept-new
    UserKnownHostsFile /root/.ssh/known_hosts
    IdentityFile /mnt/ssh-keys/cluster-setup.key
    ConnectTimeout 10
    ServerAliveInterval 60

Host *
    AddKeysToAgent yes
    IdentityAgent /var/run/ssh-auth-sock
```

#### 秘密鍵パーミッション管理
```
/mnt/ssh-keys/
├─ bootstrap.key       (chmod 600)
├─ cluster-setup.key   (chmod 600)
└─ ca/
    ├─ ca-key.pem      (chmod 400, root 所有)
    └─ ca-cert.pem     (chmod 644)
```

### ユーザー・権限管理

#### ユーザー定義
| ユーザー | UID | GID | ホーム | 権限 | 用途 |
|---------|-----|-----|-------|------|------|
| root | 0 | 0 | /root | sudo | システム管理、秘密鍵管理 |
| setupper | 1000 | 1000 | /home/setupper | 一般 | Ansible 実行、kubectl 操作 |

#### Sudo ルール
**ファイル**: `/etc/sudoers.d/50-setupper`
```
setupper ALL=(ALL) NOPASSWD: /usr/bin/ansible-playbook
setupper ALL=(ALL) NOPASSWD: /usr/bin/kubectl
setupper ALL=(ALL) NOPASSWD: /bin/systemctl
setupper ALL=(ALL) NOPASSWD: /bin/journalctl
```

### Ansible 設定の詳細

#### Ansible Config
**ファイル**: `/etc/bootstrap/ansible.cfg`
```ini
[defaults]
inventory           = /mnt/playbooks/nodes.ini
host_key_checking   = False
private_key_file    = /mnt/ssh-keys/cluster-setup.key
remote_user         = k8s-admin
log_path            = /var/log/setup/ansible.log
callback_whitelist  = profile_tasks, timer
forks               = 5
timeout             = 30
gather_timeout      = 20

[privilege_escalation]
become              = True
become_method       = sudo
become_user         = root
become_ask_pass     = False
```

#### インベントリ管理
**ファイル**: `/mnt/playbooks/nodes.ini`
```ini
[control_plane]
master-01 ansible_host=10.0.1.10
master-02 ansible_host=10.0.1.11
master-03 ansible_host=10.0.1.12

[workers]
worker-01 ansible_host=10.0.1.20
worker-02 ansible_host=10.0.1.21

[all:vars]
ansible_user=k8s-admin
ansible_ssh_private_key_file=/mnt/ssh-keys/cluster-setup.key
cluster_name=production-k8s
```

### ログ・監視の詳細

#### ログ出力構造
```
/var/log/setup/
├─ init.log                   # 起動時ログ (Systemd からのリダイレクト)
├─ ansible/
│   ├─ 2024-07-17-cluster.log # クラスター構築ログ
│   ├─ 2024-07-17-addons.log  # アドオン構築ログ
│   └─ playbook-summary.json  # 実行統計 (JSON)
├─ kubernetes/
│   ├─ kubectl-errors.log     # kubectl エラー
│   └─ access.log             # アクセスログ
└─ errors.log                 # 統合エラーログ
```

#### ログローテーション設定
**ファイル**: `/etc/logrotate.d/bootstrap-setup`
```
/var/log/setup/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0600 root root
}
```

#### ログ監視スクリプト
**ファイル**: `/opt/kubernetes/scripts/monitor-setup.sh`
```bash
#!/bin/bash
# リアルタイムログ監視

tail -f /var/log/setup/ansible.log | \
    grep -E "FAILED|ERROR|WARNING" | \
    while read line; do
        logger -t bootstrap-monitor "ALERT: $line"
    done
```

### セキュリティ設定の詳細

#### ファイアウォール・ネットワークセキュリティ
```
Ingress ルール:
  ├─ SSH (port 22)    → admin (10.0.0.10)
  ├─ API (port 6443)  → cluster nodes のみ
  └─ その他           → DENY

Egress ルール:
  ├─ SSH (port 22)    → cluster nodes
  ├─ DNS (port 53)    → システムDNS
  ├─ NTP (port 123)   → 時刻同期サーバー
  └─ その他           → DENY
```

#### SELinux・AppArmor 設定
```
AppArmor プロファイル: bootstrap-container
  ├─ /mnt/playbooks  → r
  ├─ /mnt/ssh-keys   → r (秘密鍵), deny write
  ├─ /var/log/setup  → rw
  ├─ /root/.ssh/     → r
  └─ Network: restricted
```

#### 秘密鍵管理ポリシー
- 秘密鍵は `/mnt/ssh-keys` に集約 (コンテナ内非保持)
- 読み取り時のアクセスログ記録 (auditd)
- 定期的なキーローテーション (Ansible タスク)
- キーのバージョニング

#### 監査ログ設定
**ファイル**: `/etc/audit/rules.d/bootstrap.rules`
```
-w /mnt/ssh-keys/ -p wa -k ssh-keys-access
-w /etc/bootstrap/ -p wa -k config-changes
-a always,exit -F arch=b64 -S execve -F exe=/usr/bin/ansible-playbook -k ansible-execution
```

### エラーハンドリングと復旧手順

#### 起動失敗の自動復旧
**ファイル**: `/opt/kubernetes/scripts/startup-recovery.sh`
```bash
#!/bin/bash

LOG="/var/log/setup/startup-recovery.log"

# マウントポイント確認
if ! mountpoint -q /mnt/playbooks; then
    echo "[$(date)] マウント失敗: /mnt/playbooks" >> $LOG
    # ホスト側での手動マウント後に再起動指示
    systemctl halt
fi

# SSH Agent 起動失敗
if ! pgrep ssh-agent > /dev/null; then
    echo "[$(date)] SSH Agent 起動失敗、再試行..." >> $LOG
    eval $(ssh-agent -s) || {
        echo "[$(date)] SSH Agent 起動失敗 (致命的)" >> $LOG
        exit 1
    }
fi

# Ansible インベントリ検証
if ! ansible -i /mnt/playbooks/nodes.ini all -m ping > /dev/null 2>&1; then
    echo "[$(date)] ノード疎通確認失敗" >> $LOG
    # ネットワーク設定を確認
    ip addr show | grep -E "10\.0\." >> $LOG
fi

echo "[$(date)] 起動シーケンス完了" >> $LOG
```

#### よくあるエラーと対応

**エラー1: SSH キー読み込み失敗**
```
症状: "Permission denied (publickey)"
原因: /mnt/ssh-keys マウント未実施
対応: 
  1. ホスト側で pct mount コマンド確認
  2. コンテナ内で `ls -la /mnt/ssh-keys/` で確認
  3. キーのパーミッション: chmod 600
```

**エラー2: Ansible インベントリ読み込み失敗**
```
症状: "Unable to parse inventory"
原因: nodes.ini の YAML/INI 形式エラー
対応:
  1. ansible-inventory -i /mnt/playbooks/nodes.ini --list
  2. /mnt/playbooks/nodes.ini を構文チェック
  3. ホスト側でファイル更新 → コンテナで再読み込み
```

**エラー3: kubectl クラスター未検出**
```
症状: "Unable to connect to server"
原因: kubeconfig 未設定またはクラスター未起動
対応:
  1. kubectl config view で設定確認
  2. クラスター起動完了まで待機
  3. Ansible プレイブックで kubeconfig 生成を確認
```

### パフォーマンス・チューニング

#### リソース制限設定
```
LXC コンテナ制限:
  ├─ CPU: 2 cores (cgroup: cpuset.cpus=0-1)
  ├─ メモリ: 4GB (memory.limit_in_bytes=4294967296)
  ├─ I/O: 50GB (disk limit)
  └─ ネットワーク: 1Gbps (制限なし)
```

#### パフォーマンス最適化
```
Ansible 最適化:
  ├─ forks = 5 (並行実行タスク数)
  ├─ pipelining = True (SSH ラウンドトリップ削減)
  ├─ fact_caching = jsonfile (fact キャッシュ)
  └─ gathering = smart (必要時のみ fact 収集)

ネットワーク最適化:
  ├─ TCP バッファ: net.ipv4.tcp_rmem = "4096 65536 33554432"
  └─ コネクションプーリング: OpenSSH Multiplexing
```

### 運用・メンテナンス

#### 定期メンテナンスタスク
```
Daily:
  └─ ログローテーション確認

Weekly:
  ├─ SSH キーローテーション (Ansible タスク)
  ├─ ディスク使用量チェック (df -h)
  └─ ネットワーク疎通テスト (ping + traceroute)

Monthly:
  ├─ Ansible プレイブック動作確認 (dry-run)
  ├─ パッケージ更新確認 (apt list --upgradable)
  └─ セキュリティパッチ適用
```

#### バックアップ・リカバリ戦略
```
バックアップ対象:
  ├─ /mnt/playbooks/           (ホスト側で Git 管理)
  ├─ /mnt/ssh-keys/            (ホスト側で暗号化保管)
  ├─ /var/log/setup/           (日次アーカイブ)
  └─ /etc/bootstrap/           (設定ファイル)

リカバリ手順:
  1. コンテナ削除
  2. ホスト側バックアップからマウント内容復元
  3. コンテナ新規作成 (スナップショットから)
  4. 自動初期化スクリプト実行
  5. Ansible 検証タスク実行
```

</details>


