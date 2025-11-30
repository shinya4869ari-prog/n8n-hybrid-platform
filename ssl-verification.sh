#!/bin/bash
# SSL証明書取得後の確認スクリプト

DOMAIN="ghost.100.67.3.125.sslip.io"

echo "=== SSL証明書確認 ==="
echo "1. HTTPS応答確認"
curl -I https://$DOMAIN/ 2>&1 | head -15

echo ""
echo "2. 証明書詳細"
openssl s_client -connect $DOMAIN:443 -servername $DOMAIN </dev/null 2>/dev/null | openssl x509 -noout -dates -subject -issuer

echo ""
echo "3. SSL Labs風簡易チェック (プロトコル)"
nmap --script ssl-enum-ciphers -p 443 $DOMAIN 2>/dev/null | grep -E 'TLSv|compressors|cipher preference' || echo "nmap未インストール"

echo ""
echo "4. HTTP→HTTPS自動リダイレクト確認"
curl -I http://$DOMAIN/ 2>&1 | grep -E 'HTTP|Location'

echo ""
echo "5. Ghost Content API (HTTPS経由)"
curl -s "https://$DOMAIN/ghost/api/content/posts/?limit=1&key=\${GHOST_CONTENT_API_KEY}&fields=title" | jq -r '.posts[0].title // "APIキー未設定またはエラー"'

echo ""
echo "6. Security Headers確認"
curl -I https://$DOMAIN/ 2>&1 | grep -iE 'X-Frame-Options|X-Content-Type-Options|Strict-Transport|Content-Security'

echo ""
echo "=== 確認完了 ==="
