```
tags:rails
```
### 添加新用户

> 在服务器添加一个新的用户，用户名为deploy[教程]()

- 执行命令`adduser` 

- 按提示输入密码

- 设置一些个人信息，可以直接按enter键，设为空

- 添加权限
<!--more-->
  在root用户下，打开`/etc/sudoers`文件

  ```shell
  #
  # This file MUST be edited with the 'visudo' command as root.
  #
  # Please consider adding local content in /etc/sudoers.d/ instead of
  # directly modifying this file.
  #
  # See the man page for details on how to write a sudoers file.
  #
  Defaults        env_reset
  Defaults        mail_badpass
  Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
  
  # Host alias specification
  
  # User alias specification
  
  # Cmnd alias specification
  
  # User privilege specification
  root    ALL=(ALL:ALL) ALL
  deploy  ALL=(ALL:ALL) ALL # 添加这一行，使deploy具有使用sudo的权限
  
  # Members of the admin group may gain root privileges
  %admin ALL=(ALL) ALL
  
  # Allow members of group sudo to execute any command
  %sudo   ALL=(ALL:ALL) ALL
  
  # See sudoers(5) for more information on "#include" directives:
  
  #includedir /etc/sudoers.d
  ```

### ruby安装

- 安装`rbenv`  [教程来源](https://ruby-china.org/wiki/rbenv-guide)
  `sudo deploy`回到deploy下

  ```shell
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  # 用来编译安装 ruby
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  # 用来管理 gemset, 可选, 因为有 bundler 也没什么必要
  git clone git://github.com/jamis/rbenv-gemset.git  ~/.rbenv/plugins/rbenv-gemset
  # 通过 rbenv update 命令来更新 rbenv 以及所有插件, 推荐
  git clone git://github.com/rkh/rbenv-update.git ~/.rbenv/plugins/rbenv-update
  # 使用 Ruby China 的镜像安装 Ruby, 国内用户推荐
  git clone git://github.com/AndorChen/rbenv-china-mirror.git ~/.rbenv/plugins/rbenv-china-mirror
  ```

  然后把下面的代码放到 `~/.bashrc` 里

  ```shell
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
  ```

  然后重开一个终端就可以执行 rbenv 了.

- 安装ruby

  ```shell
  rbenv install --list  # 列出所有 ruby 版本
  rbenv install 2.5.0     # 安装 2.5.0
  ```

  安转过程可能出现缺少依赖的错误，可参考[这篇文章解决](https://gist.github.com/sandyxu/8aceec7e436a6ab9621f)
  一般解决办法:

  ```shell
  sudo apt-get install autoconf bison build-essential libssl-dev libyaml-dev libreadline6 libreadline6-dev zlib1g zlib1g-dev
  ```

- 验证安装是否成功

  ```shell
  rbenv versions               # 列出安装的版本
  rbenv version                # 列出正在使用的版本
  ```

- 设置版本

  ```shell
  rbenv global 2.5.0      # 默认使用 2.5.0
  rbenv shell 2.5.0       # 当前的 shell 使用 2.5.0, 会设置一个 `RBENV_VERSION` 环境变量
  rbenv local jruby-1.7.3      # 当前目录使用 jruby-1.7.3, 会生成一个 `.rbenv-version` 文件
  ```

- last

  ```shell
  rbenv rehash                 # 每当切换 ruby 版本和执行 bundle install 之后必须执行这个命令
  rbenv which irb              # 列出 irb 这个命令的完整路径
  rbenv whence irb             # 列出包含 irb 这个命令的版本
  ```

- 安装`bundle`

  ```shell
  gem install bundle
  ```

- 安装`rails`

  ```shell
  gem install rails
  ```

- 安装nodejs

  ```shell
  sudo apt install nodejs
  ```

### 数据库

  使用postgresql数据库[教程来源](https://www.postgresql.org/download/linux/ubuntu/)

```shell
  sudo apt-get install postgresql  
```

- 新建数据库用户

  ```shell
  sudo -i -u postgres  //切换到数据库的超级管理员
  psql                 //进入数据库控制台
  create user deploy with password 'xxxx'; //新建一个deploy用户，密码是xxx
  alter role deploy with createdb; //使deploy用户具有创建数据库的权限
  alter role deploy with login；//使deploy用户具有登录数据库的权限
  ```

- 注意：

  在后面安装pg gem时，可能会出现`You need to install postgresql-server-dev-X.Y for building a server-side extension or libpq-dev for building a client-side applic
  ation`错误,依次执行：

  ```shell
  sudo apt-get install python-psycopg2
  sudo apt-get install libpq-dev
  ```

### nginx passenger 安装

  [这里很详细了](https://www.phusionpassenger.com/library/install/nginx/install/oss/xenial/)

```shell
  sudo apt-get install -y dirmngr gnupg
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
  sudo apt-get install -y apt-transport-https ca-certificates
  sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main > /etc/apt/sources.list.d/passenger.list'
  sudo apt-get update
  sudo apt-get install -y nginx-extras passenger
```

- passenger的配置

  nginx安装以后，打开`/etc/nginx/passenger.conf`会看到

  ```conf
  passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
  passenger_ruby /home/deploy/.rbenv/shims/ruby; //这里需要修改ruby的安装路径
  ```

  `which ruby` 可以查看ruby的路径

### Capistrano配置[原文教程](https://ruby-china.org/topics/18616)

- 安装必要的包

  ```ruby
  group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  # Add this if you're using rvm
  # gem 'capistrano-rvm'
  end
  ```

- `cap install`

- 我的capfile文件

  ```ruby
  # Load DSL and set up stages
  require "capistrano/setup"
  
  # Include default deployment tasks
  require "capistrano/deploy"
  
  # Load the SCM plugin appropriate to your project:
  #
  # require "capistrano/scm/hg"
  # install_plugin Capistrano::SCM::Hg
  # or
  # require "capistrano/scm/svn"
  # install_plugin Capistrano::SCM::Svn
  # or
  require "capistrano/scm/git"
  install_plugin Capistrano::SCM::Git
  
  # Include tasks from other gems included in your Gemfile
  #
  # For documentation on these, see for example:
  #
  #   https://github.com/capistrano/rvm
  #   https://github.com/capistrano/rbenv
  #   https://github.com/capistrano/chruby
  #   https://github.com/capistrano/bundler
  #   https://github.com/capistrano/rails
  #   https://github.com/capistrano/passenger
  #
  # require "capistrano/rvm"
  require "capistrano/rbenv"
  # require "capistrano/chruby"
  require "capistrano/bundler"
  require "capistrano/rails/assets"
  require "capistrano/rails/migrations"
  require "capistrano/passenger"
  set :rbenv_type, :user
  set :rbenv_ruby, '2.5.0'
  
  # Load custom tasks from `lib/capistrano/tasks` if you have any defined
  Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r } 
  
  ```

  我的deploy.rb文件

  ```ruby
  # config valid for current version and patch releases of Capistrano
  lock "~> 3.10.2"
  
  set :application, "script_blog"
  set :repo_url, "https://github.com/dccmmtop/script_blog.git"
  # Default branch is :master
  # ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
  
  # Default deploy_to directory is /var/www/my_app_name
  set :deploy_to, "/home/deploy/scrit_blog"
  
  # Default value for :format is :airbrussh.
  # set :format, :airbrussh
  
  # You can configure the Airbrussh format using :format_options.
  # These are the defaults.
  # set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto
  
  # Default value for :pty is false
  # set :pty, true
  
  # Default value for :linked_files is []
  # 在服务器<project-name>/share/config/ 下，要手动新建这两个文件，
  append :linked_files, "config/database.yml","config/secrets.yml" 
  
  # Default value for linked_dirs is []
  append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
  
  # Default value for default_env is {}
  # set :default_env, { path: "/opt/ruby/bin:$PATH" }
  
  # Default value for local_user is ENV['USER']
  # set :local_user, -> { `git config user.name`.chomp }
  
  # Default value for keep_releases is 5
  # set :keep_releases, 5
  
  # Uncomment the following to require manually verifying the host key before first deploy.
  # set :ssh_options, verify_host_key: :secure
  
  ```

  注意`append :linked_files, "config/database.yml","config/secrets.yml" ` 

  `database.yml`和`secrets.yml`是手动在,`share/config/`目录下新建的，一个是连接数据库的相关信息，一个是安全验证相关信息。我的部署目录是`scriot_blog/` 就新建  `script_blog/share/config/` 目录

  同时新建以上两个文件。

  database.yml

  ```yml
  production:
  adapter: postgresql
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000
  database: production_blog
  username: 'xxx'
  password: 'xxx'
  
  ```

  secrets.yml

  ```yml
  production:
  secret_key_base: xxxxxx
  ```

  其中`secret_key_base`的值是在本地项目下 执行`rake secret` 命令生成的。

- deploy/production.rb

  ```ruby
  # server-based syntax
  # ======================
  # Defines a single server with a list of roles and multiple properties.
  # You can define all roles on a single server, or split them:
  
  # server "39.108.138.149", user: "root", roles: %w{app db web}, my_property: :my_value
  server "xxxx服务器的ip", user: "deploy", roles: %w{app db web}
  # server "example.com", user: "deploy", roles: %w{app web}, other_property: :other_value
  # server "db.example.com", user: "deploy", roles: %w{db}
  # role-based syntax
  # ==================
  
  # Defines a role with one or multiple servers. The primary server in each
  # group is considered to be the first unless any hosts have the primary
  # property set. Specify the username and a domain or IP for the server.
  # Don't use `:all`, it's a meta role.
  
  # role :app, %w{deploy@example.com}, my_property: :my_value
  # role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
  # role :db,  %w{deploy@example.com}
  
  # Configuration
  # =============
  # You can set any configuration variable like in config/deploy.rb
  # These variables are then only loaded and set in this stage.
  # For available Capistrano configuration variables see the documentation page.
  # http://capistranorb.com/documentation/getting-started/configuration/
  # Feel free to add new variables to customise your setup.
  
  # Custom SSH Options
  # ==================
  # You may pass any option but keep in mind that net/ssh understands a
  # limited set of options, consult the Net::SSH documentation.
  # http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
  #
  # Global options
  # --------------
  set :ssh_options, {
  keys: %w(/home/deploy/.ssh/id_rsa),
  port: xxx
  # forward_agent: false,
  # auth_methods: %w(password)
  }
  #
  # The server-based syntax can be used to override options:
  # ------------------------------------
  # server "example.com",
  #   user: "user_name",
  #     keys: %w(/home/user_name/.ssh/id_rsa),
  #     forward_agent: false,
  #     auth_methods: %w(publickey password)
  #     # password: "please use keys"
  #   }
  
  ```

### 最后

  本地执行`cap production deploy`