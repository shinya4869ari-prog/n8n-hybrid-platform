# n8n Hybrid Integration Platform

統合自動化プラットフォーム: Ghost CMS + n8n + Ollama AI + Nginx Proxy Manager

## 概要

このプロジェクトは、以下を統合したハイブリッド自動化環境です:

- **Ghost CMS** (5.x Alpine): ブログ・コンテンツ管理
- **n8n**: ワークフロー自動化エンジン
- **Ollama**: ローカルLLMサーバー (Mistral/Llama/Phi3等)
- **Ollama WebUI**: AI対話インターフェース
- **Nginx Proxy Manager**: リバースプロキシ + SSL管理
- **PostgreSQL**: n8n用データベース

## 主要機能

- Ghost記事の自動要約 (AI生成)
- n8nによるワークフロー統合 (Cron/Webhook/API連携)
- HTTPS対応 (Let's Encrypt自動取得)
- Docker Composeによる一括管理

## クイックスタート

### 1. 環境変数設定

```bash
cp .env.hybrid.example .env.hybrid
# 必須項目を編集:
# - DB_POSTGRES_PASSWORD
# - N8N_BASIC_AUTH_PASSWORD
# - N8N_ENCRYPTION_KEY (32文字以上のランダム文字列)
# - GHOST_CONTENT_API_KEY (Ghost管理画面で取得後)
# - GHOST_ADMIN_API_KEY (Ghost管理画面で取得後)
```

### 2. 起動

```bash
docker compose -f docker-compose.hybrid.yml up -d
```

### 3. 初期アクセス

- **Nginx Proxy Manager**: http://localhost:81 (初期: admin@example.com / changeme)
- **Ghost**: http://ghost.100.67.3.125.sslip.io/ (NPMでProxy設定後)
- **n8n**: http://localhost:5678 (Basic認証)
- **Ollama WebUI**: http://localhost:3000

### 4. SSL証明書取得

NPM管理画面 → Proxy Hosts → ghost.100.67.3.125.sslip.io → SSL → Request New Certificate

### 5. ワークフロー読込

n8n画面 → Import → `n8n-workflow-ghost-summary.json` を選択

## ディレクトリ構成

```
.
├── docker-compose.hybrid.yml    # メインCompose定義
├── .env.hybrid                  # 環境変数 (Git管理外)
├── .gitignore                   # Git除外設定
├── n8n-workflow-ghost-summary.json  # 要約自動化ワークフロー
├── ssl-verification.sh          # SSL確認スクリプト
├── SECURITY_HEADERS.md          # セキュリティ設定ガイド
├── README.md                    # このファイル
└── Harbor_by_copirot/           # 追加サービス用 (任意)
```

## 利用モデル (Ollama)

プリインストール推奨:

```bash
docker exec -it ai-ollama ollama pull mistral
docker exec -it ai-ollama ollama pull phi3:mini
docker exec -it ai-ollama ollama pull deepseek-coder
```

## セキュリティ

- APIキー: `.env.hybrid` に保管 (Git管理外)
- HTTPS強制化: `SECURITY_HEADERS.md` 参照
- Prompt Injection対策: ワークフロー内プロンプトで明示
- レート制限: NPM Custom Configで設定可能

## メンテナンス

### ログ確認
```bash
docker logs ghost --tail 50
docker logs n8n --tail 50
docker logs ai-ollama --tail 50
```

### バックアップ
```bash
docker exec postgres pg_dump -U n8n n8n > backup_n8n_$(date +%F).sql
docker cp ghost:/var/lib/ghost/content ./ghost_backup_$(date +%F)
```

### 更新
```bash
docker compose -f docker-compose.hybrid.yml pull
docker compose -f docker-compose.hybrid.yml up -d
```

## トラブルシューティング

### Ghostが301ループ
- NPMのProxy設定で「Websockets Support」を有効化
- Ghost `url` 環境変数とアクセスURLを完全一致させる

### n8nワークフローでAPI認証エラー
- `.env.hybrid` の `GHOST_*_API_KEY` を確認
- Ghost管理画面 → Settings → Integrations → Custom Integration作成

### Ollama応答が遅い
- 軽量モデル (`phi3:mini`) への切替
- `docker stats` でメモリ/CPU確認

## ライセンス

各コンポーネントは元のライセンスに従います:
- Ghost: MIT
- n8n: Sustainable Use License (商用は有償)
- Ollama: MIT
- Nginx Proxy Manager: MIT

## 貢献

Issue / Pull Request歓迎

## 参考リンク

- [Ghost公式](https://ghost.org/)
- [n8n公式](https://n8n.io/)
- [Ollama公式](https://ollama.ai/)
- [NPM公式](https://nginxproxymanager.com/)
