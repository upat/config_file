# GitHubの準備メモ(MSYS2環境)

### SSH鍵の準備
---
1. `ssh-keygen -t rsa -C "[GitHubに登録したメールアドレス]"` ( `-C` の後ろはコメント文)
1. Enter連打
1. `ssh-add /home/[ユーザー名]/.ssh/id_rsa`
1. ``eval `ssh-agent` `` ( `ssh-add` でエラーが出る場合実行) 
1. `clip < /home/[ユーザー名]/.ssh/id_rsa.pub` をGitHubの設定画面へペーストする

### プロキシ環境下でのSSH設定
---
- .ssh/config を作成
```
Host github.com
    User [ユーザー名]
    HostName github.com
    Port 22
    IdentityFile ~/.ssh/id_rsa
Host ssh.github.com
    User [ユーザー名]
    HostName ssh.github.com
    Port 443
    IdentityFile ~/.ssh/id_rsa
    ProxyCommand connect.exe -H [プロキシ名]:[ポート番号] %h %p
```
- git側の設定
```
git config --global http.proxy [プロキシ名]:[ポート番号]
git remote add origin git@[.ssh/configで設定したssh用Host]:[ユーザー名]/[リポジトリ名].git
```
- ※既に設定済みの場合(URLの変更)
```
git remote set-url origin git@[.ssh/configで設定したssh用Host]:[ユーザー名]/[リポジトリ名].git
```

### gitコマンドについて
---
- 準備
```
cd [任意のフォルダ]
git config --global user.email [メールアドレス]
git config --global user.name [ユーザー名]
git init
git add [任意のファイル]
git commit -m "ここがcommit時のコメントになる"
git remote add origin git@github.com:[ユーザー名]/[リポジトリ名].git
git push -u origin master # -uを付けると、以後 "git push" を "git push origin master" として実行する
```

- ファイルの登録(追加)
    - `git add [ファイル・フォルダ名・ワイルドカードも可]`
        - `-A` , `-u` , `.` を付けた場合、一括登録する
        - `-p` を付けた場合、ファイルの変更箇所の一部のみを登録する

- コミットする
    - `git commit`
        - `-a` を付けると新規追加を除くファイルの変更箇所を検出し、コミットを行う
        - `-m "[任意のコメント]"` でコミットメッセージをコマンドから入力する

- ファイルの削除
    - `git rm [ファイル名]`
        - ※git管理ファイルからのみ削除する場合は `--cache` をつける

- フォルダの削除
    - `git rm -r [フォルダ名]`
        - ※git管理ファイルからのみ削除する場合は `--cache` をつける

- リモートリポジトリからローカルリポジトリへ変更を反映
    - `git pull`

- ローカルリポジトリからローカルリポジトリへ変更を反映
    - `git push origine [tagname(masterとか)]`

- .gitファイルの作成
    - `git init`

- 直前のコミットを取り消す場合(複数人で作業の場合は非推奨)
1. `git reset --soft HEAD^` (実ファイルの変更も行う場合は `--soft` を `--hard` に)
1. `git add [ファイル名など]`
1. `git commit -m "コメント`
1. `git push -f origin master`
