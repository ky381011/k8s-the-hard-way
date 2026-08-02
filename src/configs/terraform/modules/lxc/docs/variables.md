# Variables

LXC モジュールで使用する入力変数の一覧です。

---

## `node_name`

| 項目 | 値 |
|------|-----|
| 型 | `string` |
| 必須 | はい |
| デフォルト | なし |

Proxmox クラスタ内のノード名。LXC コンテナを作成するターゲットノードを指定します。

---

## `initialization`

| 項目 | 値 |
|------|-----|
| 型 | `object` |
| 必須 | はい |
| デフォルト | なし |

LXC コンテナの初期化設定。

### フィールド

| フィールド | 型 | 説明 |
|------------|-----|------|
| `hostname` | `string` | コンテナのホスト名（空文字・空白不可） |
| `ip_config` | `list(object)` | IP 設定のリスト（1 件以上必須） |
| `ip_config[].address` | `string` | IPv4 アドレス（CIDR 形式、例: `192.168.1.10/24`） |
| `ip_config[].gateway` | `string` | デフォルトゲートウェイ（例: `192.168.1.1`） |

### バリデーション

- `initialization` は `null` 不可
- `hostname` は空文字・空白のみ不可
- `ip_config` は 1 件以上必要
- 各 `ip_config` エントリの `address` と `gateway` は空文字不可

---

## `operating_system`

| 項目 | 値 |
|------|-----|
| 型 | `object` |
| 必須 | はい |
| デフォルト | なし |

LXC コンテナの OS 設定。

### フィールド

| フィールド | 型 | 説明 |
|------------|-----|------|
| `template_file_id` | `string` | OS テンプレートのファイル ID |
| `type` | `string` | OS の種別（例: `ubuntu`, `debian`） |

---

## `disk`

| 項目 | 値 |
|------|-----|
| 型 | `object` |
| 必須 | はい |
| デフォルト | なし |

コンテナのルートファイルシステム（rootfs）設定。追加ボリュームが必要な場合は `mount_point` ブロックを使用してください。

### フィールド

| フィールド | 型 | 説明 |
|------------|-----|------|
| `datastore_id` | `string` | 使用するデータストアの ID（空文字不可） |
| `size` | `number` | ディスクサイズ（GiB、1 以上必須） |

---

## `memory`

| 項目 | 値 |
|------|-----|
| 型 | `object` |
| 必須 | いいえ |
| デフォルト | `null` |

コンテナのメモリ設定。省略した場合は Proxmox のデフォルト値が適用されます。

### フィールド

| フィールド | 型 | 説明 |
|------------|-----|------|
| `dedicated` | `number` | 専有メモリ量（MiB、1 以上必須） |
| `swap` | `number` | スワップサイズ（MiB、0 以上） |

---

## `network_interface`

| 項目 | 値 |
|------|-----|
| 型 | `map(object)` |
| 必須 | はい |
| デフォルト | なし |

コンテナのネットワークインターフェース設定。マップのキーは任意の識別子です。

### フィールド

| フィールド | 型 | 説明 |
|------------|-----|------|
| `name` | `string` | インターフェース名（例: `eth0`） |
| `bridge` | `string` | 接続先ブリッジ名（例: `vmbr0`） |
| `address` | `string` | IPv4 アドレス（CIDR 形式） |
| `gateway` | `string` | デフォルトゲートウェイ |
| `vlan_id` | `number` | VLAN ID |

### 使用例

```hcl
network_interface = {
  eth0 = {
    name    = "eth0"
    bridge  = "vmbr0"
    address = "192.168.1.10/24"
    gateway = "192.168.1.1"
    vlan_id = 100
  }
}
```
