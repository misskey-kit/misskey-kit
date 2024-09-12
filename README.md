# misskey-kit
misskeyサーバーを簡単に立てるためのdocker compose定義  
Cloudflareを使うので固定IPアドレスは不要、それどころかグローバルIPアドレスさえ不要です。

用意するもの: dockerコマンドとdocker-composeコマンドが動くLinux環境（WSL可）

## クイックスタート: localhostでの起動を試す場合

1. misskey-default.ymlの`url:`の欄を`http://localhost:3000`に書き換えます
2. docker-compose.ymlのコメントアウトされている`ports: ["3000:3000"]`の行のコメントアウトを外します
3. `docker-compose up -d --wait`を実行します
4. http://localhost:3000 にアクセスします

## クイックスタート: ドメインを使う場合

ドメイン名を`example.com`とし、これがCloudflareで管理されているものとします

1. [Cloudflare Tunnels](https://www.cloudflare.com/ja-jp/products/tunnel/)でtunnelを作成します。トークンが生成されますが、それは直接「トークンだ」と表示されるものではなく、表示されているconnector実行用コマンドに含まれる無意味な長い文字列です。
1. misskey-default.ymlの`url:`の欄を`https://example.com`に書き換えます
2. docker.envの`TUNNEL_TOKEN=`の欄にCloudflare Tunnelsのトークンを入力します
3. Cloudflare Tunnelsの設定で、Public Hostnameとして`example.com/`を、そのserviceとして`HTTP://lb`を設定します
4. `docker-compose up -d --wait`を実行します
5. https://example.com/ にアクセスします

## 追加: DBバックアップとその定期実行

1. AWS S3 をはじめとするオブジェクトストレージを作成し、そのクレデンシャルを用意します
2. docker.envの`AWS_ACCESS_KEY_ID=`の欄にAWSのアクセスキーを入力します
3. docker.envの`AWS_SECRET_ACCESS_KEY=`の欄にAWSのシークレットアクセスキーを入力します
4. docker.envの`AWS_DEFAULT_REGION=`の欄にAWSのリージョンを入力します。AWS S3以外のオブジェクトストレージの場合はそのままにしておきます
5. AWS S3以外のオブジェクトストレージの場合は、docker.envの`S3_ENDPOINT=`の欄にオブジェクトストレージのエンドポイントURLを入力します
    - ヒント: Cloudflare R2の場合、`https://XXXXXXXXXX.r2.cloudflarestorage.com/BUCKET_NAME`のようなURLを案内されますが、最後の`BUCKET_NAME`は不要です。バケット名はこのあと`BACKUP_OBJECT_S3URL`を指定するときに使います
6. docker.envの`BACKUP_OBJECT_S3URL=`の欄に`S3://`から始まるバケット名を含むパス名を入力します
7. ./backup-db.shを実行すると、バケット上に指定通りのキー名でDBのバックアップが作成されます
8. `crontab -e`で定期実行の設定を行います。例えば、毎時15分にバックアップを作成する場合は、`15 * * * * /path/to/misskey-kit/backup-db.sh`とします
9. リストアの練習は、他のサーバーに同じ設定ファイルを置いて行うのがよいでしょう
    1. `docker compose up -d db` としてDBを起動します
    2. `./restore-db.sh`としてDBをリストアします
    3. docker-compose.ymlのコメントアウトされている`ports: ["3000:300"]`の行のコメントアウトを外し、直接アクセスできるようにしておきます
    4. `docker compose up -d web`としてMisskeyを起動します
    5. http://localhost:3000 にアクセスします。バックアップしたときの状態に戻っているはずです

## 追加: misskeyのアップデート

1. `./update-misskey.sh`を実行します。これは [公式Dockerhub](https://hub.docker.com/r/misskey/misskey) から最新のイメージを取得し、アプリケーションインスタンスを更新します。このとき、新しいバージョンのコンテナを起動してから既存のコンテナを停止するため、サービスは無停止です
2. β版など、latest以外のタグを使いたい場合は、`./update-misskey.sh TAG`のようにタグ名を指定します

## 追加: libjemallocを使ってメモリ効率を向上させる

libjemallocは、標準のメモリ管理ライブラリよりも高効率な互換メモリ管理ライブラリです。これを使うことで、Misskeyのメモリ使用量を抑えることができます。

1. `./install-libjemalloc.sh`を実行します。これはjemallocをインストールし、Misskeyのコンテナを再起動することなく有効になります  
Misskeyをアップデートしたりしてもlibjemallocは有効のままです
    - dockerに作ったボリューム(misskey-lib64)をインストール先にしているためです
