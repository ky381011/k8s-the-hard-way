# lxc

## テスト方法

このモジュールには `tests/` ディレクトリに Terraform ネイティブテストが含まれています。  
テストは実際のプロバイダーを使用せず、`mock_provider` によってモック実行されます。

### テストファイル

| ファイル | 内容 |
|---|---|
| `tests/basic.tftest.hcl` | 最小構成・オプション指定でのコンテナ作成を検証 |
| `tests/validation.tftest.hcl` | 変数バリデーションが不正入力を正しく拒否することを検証 |

### 実行方法

モジュールのディレクトリで以下を実行します。

```bash
cd src/configs/terraform/modules/lxc
terraform test
```

特定のテストファイルのみ実行する場合:

```bash
terraform test -filter=tests/basic.tftest.hcl
terraform test -filter=tests/validation.tftest.hcl
```

