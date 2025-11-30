# Security Headers 設定ガイド (Nginx Proxy Manager)

## NPM管理画面での追加方法

### 1. Proxy Host編集
- Hosts → Proxy Hosts → `ghost.100.67.3.125.sslip.io` を選択
- Advanced タブへ移動

### 2. Custom Nginx Configuration に以下を追加

```nginx
# Security Headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;

# HSTS (HTTP Strict Transport Security) - SSL証明書取得後のみ有効化
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

# Content Security Policy (CSP) - Ghost管理画面との互換性維持
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self'; frame-ancestors 'self';" always;

# Rate limiting (optional - 高頻度攻撃対策)
limit_req_zone $binary_remote_addr zone=ghost_limit:10m rate=10r/s;
limit_req zone=ghost_limit burst=20 nodelay;
```

### 3. 保存後テスト

```bash
# Headers確認
curl -I https://ghost.100.67.3.125.sslip.io/ | grep -E 'X-Frame|X-Content|Strict-Transport|Content-Security'

# 管理画面アクセステスト (CSP動作確認)
# ブラウザで https://ghost.100.67.3.125.sslip.io/ghost/ を開き Console にCSPエラーが出ないか確認
```

### 4. トラブルシューティング

**Ghost管理画面が動作しない場合**
- CSPの `script-src` に `'unsafe-inline' 'unsafe-eval'` が必要 (Ghost 5.x の制約)
- それでもダメなら一時的にCSP行をコメントアウト

**API呼び出しが403になる場合**
- `connect-src 'self'` を `connect-src 'self' https:` へ拡張

**Rate Limitでブロックされる場合**
- `rate=10r/s` を `rate=30r/s` に緩和
- または Admin IP を whitelist:
  ```nginx
  geo $limit {
    default 1;
    YOUR_ADMIN_IP 0;
  }
  map $limit $limit_key {
    0 "";
    1 $binary_remote_addr;
  }
  limit_req_zone $limit_key zone=ghost_limit:10m rate=10r/s;
  ```

## 追加の強化策

### A. Docker Compose側でのログ制限
```yaml
services:
  ghost:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### B. Ghost側での追加設定 (config.production.json)
```json
{
  "security": {
    "preventGhostCliUpgrade": true,
    "forceAdminSSL": true
  }
}
```

### C. n8n環境変数での暗号化強化
```bash
# .env.hybrid に追加
N8N_SECURE_COOKIE=true
N8N_PROTOCOL=https
```

## 参考: Mozilla Observatory スコア改善目標
- A+ 評価を目指す設定済み
- 定期チェック: https://observatory.mozilla.org/
