## NPM SSL証明書取得 - クイックリファレンス

### 前提条件 ✓ 確認済み
- [x] NPM ポート 80/443 公開済み
- [x] Ghost コンテナ稼働中 (URL: https://ghost.100.67.3.125.sslip.io/)
- [x] 内部疎通OK (nginx-proxy-manager → ghost:2368)
- [x] DNS解決OK (100.67.3.125)

---

### 🔐 NPM管理画面アクセス

**URL**: `http://100.67.3.125:81/` または `http://localhost:81/`

**初回ログイン** (変更済みならスキップ):
- Email: `admin@example.com`
- Password: `changeme`
- ログイン後に新しいメールアドレスとパスワードを設定

---

### 📝 SSL証明書取得手順 (簡易版)

#### 1. Proxy Host追加
```
左メニュー: Hosts → Proxy Hosts → 右上「Add Proxy Host」
```

**Details タブ:**
| 項目 | 値 |
|------|-----|
| Domain Names | `ghost.100.67.3.125.sslip.io` |
| Scheme | `http` |
| Forward Hostname/IP | `ghost` |
| Forward Port | `2368` |
| Cache Assets | ☑ |
| Block Common Exploits | ☑ |
| Websockets Support | ☑ |

#### 2. SSL証明書要求

**SSL タブ:**
- SSL Certificate: `Request a new SSL Certificate` 選択
- Email: `your-email@example.com` (Let's Encrypt通知用)
- ☑ Force SSL
- ☑ HTTP/2 Support
- ☑ I Agree to the Let's Encrypt Terms of Service

**「Save」クリック → 自動で証明書取得開始 (10-30秒)**

---

### ✅ 証明書取得成功の確認

#### ターミナルから:
```bash
# HTTPS応答確認
curl -I https://ghost.100.67.3.125.sslip.io/

# 詳細確認スクリプト実行
./ssl-verification.sh
```

#### ブラウザから:
```
https://ghost.100.67.3.125.sslip.io/
```
→ 🔒 鍵マークが表示されGhostトップページが見えればOK

---

### ⚠️ よくあるエラーと対処

| エラー | 原因 | 対処 |
|--------|------|------|
| Challenge failed | ポート80/443が外部から到達不可 | `sudo ufw allow 80/tcp && sudo ufw allow 443/tcp` |
| Rate limited | Let's Encrypt レート制限 (5回/時) | 1時間待機 |
| Invalid response | Ghost未起動 | `docker restart ghost` |
| 301ループ | URL不一致 | 既に修正済み。Websockets Support確認 |

---

### 🔒 証明書取得後の追加設定 (推奨)

#### A. HSTS有効化
```
NPM → Proxy Hosts → ghost.100.67.3.125.sslip.io 編集
SSL タブ:
  ☑ HSTS Enabled
  ☑ HSTS Subdomains
Save
```

#### B. Security Headers追加
```
Advanced タブ → Custom Nginx Configuration:
```
```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

詳細: `SECURITY_HEADERS.md` 参照

---

### 📋 次のステップ

証明書取得完了後:

1. **Ghost管理画面アクセス**: `https://ghost.100.67.3.125.sslip.io/ghost/`
2. **API Key発行**: Settings → Integrations → Add custom integration
   - Content API Key → `.env.hybrid` の `GHOST_CONTENT_API_KEY` へ
   - Admin API Key → `.env.hybrid` の `GHOST_ADMIN_API_KEY` へ
3. **n8n再起動**: `docker restart n8n`
4. **ワークフロー読込**: n8n画面 → Import → `n8n-workflow-ghost-summary.json`
5. **動作テスト**: ワークフロー手動実行

---

### 🆘 サポート

問題が解決しない場合:
```bash
# NPMログ確認
docker logs nginx-proxy-manager --tail 50

# Ghostログ確認
docker logs ghost --tail 50

# ポート使用状況
sudo netstat -tlnp | grep -E ':80|:443'
```
