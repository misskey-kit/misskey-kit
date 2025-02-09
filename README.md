# misskey-kit
misskeyサーバーを簡単に立てるためのdocker compose定義  
Cloudflareを使うので固定IPアドレスは不要、それどころかグローバルIPアドレスさえ不要です。

用意するもの: dockerコマンドとdocker-composeコマンドが動くLinux環境（WSL可）

立ち上がるもの:
- Misskey（高速ノート検索が有効になった状態）
- 藍ちゃんbot

## クイックスタート: localhostでの起動を試す場合

1. etc/misskey-default.ymlの`url:`の欄が`http://localhost`になっていることを確認します
2. `docker-compose up -d --wait web`を実行します
4. http://localhost/ にアクセスします

## クイックスタート: ドメインを使う場合

ドメイン名を`example.com`とし、これがCloudflareで管理されているものとします

1. [Cloudflare Tunnels](https://www.cloudflare.com/ja-jp/products/tunnel/)でtunnelを作成します。トークンが生成されますが、それは直接「トークンだ」と表示されるものではなく、表示されているconnector実行用コマンドに含まれる無意味な長い文字列です。
1. etc/misskey-default.ymlの`url:`の欄を`https://example.com`に書き換えます
2. etc/docker.envの`TUNNEL_TOKEN=`の欄にCloudflare Tunnelsのトークンを入力します
3. Cloudflare Tunnelsの設定で、Public Hostnameとして`example.com/`を、そのserviceとして`HTTP://lb`を設定します
4. `docker-compose up -d --wait web`を実行します。これで、http://localhost/ でサーバーにローカルアクセスできることを確認します
5. `docker-compose up -d --wait tunnel`を実行します
5. https://example.com/ にアクセスします

## 追加: DBバックアップとその定期実行

1. AWS S3 をはじめとするオブジェクトストレージを作成し、そのクレデンシャルを用意します
2. etc/docker.envの`AWS_ACCESS_KEY_ID=`の欄にAWSのアクセスキーを入力します
3. etc/docker.envの`AWS_SECRET_ACCESS_KEY=`の欄にAWSのシークレットアクセスキーを入力します
4. etc/docker.envの`AWS_DEFAULT_REGION=`の欄にAWSのリージョンを入力します。AWS S3以外のオブジェクトストレージの場合はそのままにしておきます
5. AWS S3以外のオブジェクトストレージの場合は、etc/docker.envの`S3_ENDPOINT=`の欄にオブジェクトストレージのエンドポイントURLを入力します
    - ヒント: Cloudflare R2の場合、`https://XXXXXXXXXX.r2.cloudflarestorage.com/BUCKET_NAME`のようなURLを案内されますが、最後の`BUCKET_NAME`は不要です。バケット名はこのあと`BACKUP_OBJECT_S3URL`を指定するときに使います
6. etc/docker.envの`BACKUP_OBJECT_S3URL=`の欄に`S3://`から始まるバケット名を含むパス名を入力します
7. bin/backup-db.shを実行すると、バケット上に指定通りのキー名でDBのバックアップが作成されます
8. etc/crontab に毎時のbin/backup-db.sh呼び出しが設定されているので、この通りに自動バックアップされるようになります
9. リストアの練習は、他のサーバーに同じ設定ファイルを置いて行うのがよいでしょう
    1. `docker compose up -d db` としてDBを起動します
    2. `./restore-db.sh`としてDBをリストアします
    4. `docker compose up -d web`としてMisskeyを起動します
    5. http://localhost/ にアクセスします。バックアップしたときの状態に戻っているはずです
10. 実際のリストアの際には、次のような手順になるでしょう
    1. `docker compose down` でいったん全コンテナを終了します
    2. `docker compose up -d db` としてDBだけを起動します
    2. `./restore-db.sh`としてDBをリストアします
    4. `docker compose up -d web`としてMisskeyを起動します
    5. http://localhost/ にアクセスし、バックアップしたときの状態に戻っていることを確認します
    6. `docker-compose up -d --wait tunnel`を実行しWebに公開します

## 追加: misskeyのアップデート

1. `bin/update-misskey.sh`を実行します。これは [公式Dockerhub](https://hub.docker.com/r/misskey/misskey) から最新のイメージを取得し、アプリケーションインスタンスを更新します。このとき、新しいバージョンのコンテナを起動してから既存のコンテナを停止するため、サービスは無停止です
2. β版など、latest以外のタグを使いたい場合は、`bin/update-misskey.sh TAG`のようにタグ名を指定します


## 追加: 藍ちゃんbotの立ち上げ

1. Misskey上で藍ちゃん用のアカウントを作ります
2. そのアカウントで、APIトークンを発行します。権限はすべて付いたものにします
3. Gemini APIのページ https://ai.google.dev/gemini-api/docs?hl=ja で「Gemini APIを取得する」から無料のAPIキーを取得します
3. etc/docker.envの`AI_MISSKEY_TOKEN=`の欄にMisskeyアカウントのAPIトークンを入力します。`AI_GEMINI_API_TOKEN=`の欄にGemini APIキーを入力します
4. `docker-compose up -d ai`として藍ちゃんを起動します
5. Misskey上で藍ちゃんアカウントに ping などと話しかけてみてください
6. crontabには、夜11時半に藍ちゃんを止めて朝7時半に藍ちゃんを起動するタイマーが記述されています。また、夜11時半には藍ちゃんにおやすみのあいさつをノートさせるタイマーも記述されています。必要に応じて調整してください
