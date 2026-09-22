#!/usr/bin/env bash
# 無人ブートストラップ: テンプレから公開リポを作り、GitHub Actions でデプロイするところまで 1 コマンド。
#   scripts/bootstrap.sh <name> [--no-domain]
# 事前条件（一度だけ）:
#   - gh auth login（TakuyaAbe）
#   - 個人アカウントの Cloudflare API トークンを Keychain に保存:
#       security add-generic-password -s cf-personal -a CLOUDFLARE_API_TOKEN -w
set -euo pipefail

name="${1:?usage: bootstrap.sh <name> [--no-domain]}"
domain="${name}.sayuno.me"
owner="TakuyaAbe"
template="${owner}/microsite-template"
dest="${MICROSITE_DIR:-$HOME/codes}/${name}"

if [[ "${2:-}" == "--no-domain" ]]; then domain=""; fi
if [[ -e "$dest" ]]; then echo "already exists: $dest" >&2; exit 1; fi

token="$(security find-generic-password -s cf-personal -w)" || { echo "Keychain に cf-personal がありません" >&2; exit 1; }

gh repo create "${owner}/${name}" --public --template "$template" --clone --description "${name} microsite (Cloudflare Workers)" >/dev/null
mv "$name" "$dest"
cd "$dest"

# Worker 名とカスタムドメイン
sed -i '' "s/\"name\": \"microsite\"/\"name\": \"${name}\"/" wrangler.jsonc
if [[ -n "$domain" ]]; then
  sed -i '' "s|// ,\"routes\": \[{ \"pattern\": \"<name>.sayuno.me\", \"custom_domain\": true }\]|,\"routes\": [{ \"pattern\": \"${domain}\", \"custom_domain\": true }]|" wrangler.jsonc
fi
sed -i '' "s/<title>Microsite<\/title>/<title>${name}<\/title>/" public/index.html

# GitHub Actions デプロイ + secret（値は Keychain から直接。画面には出ない）
mkdir -p .github/workflows
cp scripts/deploy.yml .github/workflows/deploy.yml
printf '%s' "$token" | gh secret set CLOUDFLARE_API_TOKEN --repo "${owner}/${name}"
unset token

npm install --silent
git add -A
git commit -q -m "bootstrap: ${name}${domain:+ (${domain})}"
git push -q -u origin main

echo "repo:   https://github.com/${owner}/${name}"
echo "site:   ${domain:+https://${domain}  /  }https://${name}.a-taku275.workers.dev"
echo "actions: gh run watch --repo ${owner}/${name}"
