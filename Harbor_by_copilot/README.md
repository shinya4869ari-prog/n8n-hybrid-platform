# ローカル構成テンプレート（Nginx Proxy Manager 非公開、Tailscale 経由管理）

## 前提
- WSL + Docker Desktop が導入済み
- ホストまたは WSL に Tailscale が参加済み（推奨）

## 初期セットアップ
1. コピーして .env を作る:
   cp .env.example .env
   # 編集して DB パスワード等を設定してください

2. tailscale entrypoint に実行権限（tailscale コンテナを使う場合）
   chmod +x tailscale/entrypoint.sh

3. 開発起動:
   docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

## NPM 管理UI へ安全にアクセスする方法（推奨）
- ホスト側で Tailscale が稼働している場合:
  - ホストの Tailnet IP を使って、ホスト上で一時フォワードを作成しコンテナの内側ポートへ転送するか、ホストで `tailscale serve` を利用して公開します。
  - 一時フォワード例（ホスト上で実行、network 名は適宜変更）:
    docker run --rm --network project_web -p 127.0.0.1:8081:8081 alpine/socat \
      TCP-LISTEN:8081,fork TCP:nginx-proxy-manager:81
  - その後 Tailnet 内の別ノードから http://\<host-tailnet-ip\>:8081 でアクセス可能。

## 停止
docker compose down

## 注意
- .env に認証キー等を入れる場合は絶対にリポジトリにコミットしないこと。
- WSL 環境で tailscale コンテナは権限の制約で動かない場合があります。動かない場合はホスト側で Tailscale を利用してください。
