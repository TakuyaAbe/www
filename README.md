# www — sayuno.me

sayuno.me のサブドメインにあるサイトの目次ページ。本番: https://sayuno.me （https://www.sayuno.me は `worker.js` で apex へ 301）

サイトを増やしたら `public/index.html` の `.site-list` に `<li class="site">` を 1 つ足して push する（新しいものが上）。

## 新しいサイトを作る

### A. ボタン（推奨・トークン不要）

1. 上の **Deploy to Cloudflare** を押す（個人アカウント a.taku275@gmail.com を選ぶ）。
2. リポジトリ名と Worker 名をサイト名にして Deploy。GitHub の自分のアカウントにリポが複製され、Workers Builds が `main` への push ごとに自動デプロイする（ブランチはプレビュー URL）。
3. カスタムドメインを付けるなら `wrangler.jsonc` の `routes` のコメントを外して `<name>.sayuno.me` にし、push。DNS は自動で作られる。

### B. 無人ブートストラップ（GitHub Actions でデプロイ）

一度だけ: 個人アカウントの API トークン（Workers Scripts:Edit / Workers Routes:Edit / Zone:Read / DNS:Edit、Zone は sayuno.me）を Keychain に保存する。

```bash
security add-generic-password -s cf-personal -a CLOUDFLARE_API_TOKEN -w
```

以後はサイトごとに:

```bash
scripts/bootstrap.sh <name>              # <name>.sayuno.me まで自動
scripts/bootstrap.sh <name> --no-domain  # workers.dev のみ
```

リポ作成 → Worker 名/ドメイン置換 → `.github/workflows/deploy.yml` 追加 → secret 投入 → push → デプロイ、まで走る。

## 手元で

```bash
npm run dev      # http://localhost:5190
npm run deploy   # wrangler auth profile（personal）を有効にしたディレクトリなら個人アカウントに出る
```

## 構成

- `public/` — サイト本体（`index.html`, `style.css`, `script.js`, `404.html`）
- `wrangler.jsonc` — Workers 設定。`account_id` を個人アカウントに固定
- `scripts/bootstrap.sh`, `scripts/deploy.yml` — B の道具
