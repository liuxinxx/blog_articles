```
tags:rails
source_url:https://www.jianshu.com/p/37ce034b4638
source_title:使用 capistrano 部署 Rails 应用
```



#### 1. 介绍

本站有很多篇使用mina来部署的文章，但是相信一定有很多人是使用capistrano来部署rails应用的。所以本篇文章也来讲讲如何用capistrano部署ruby on rails应用。<!--more-->

capistrano比Mina给人的感觉部署时间要长，mina比较精简，而capistrano流行度比较广，功能也很强大，插件也是相当多。

#### 2. 安装

添加下面这行到Gemfile文件：

```
group :development do
  gem "capistrano", "~> 3.4"
end
```

然后执行：

```
$ bundle install
```

创建部署的各种文件：

```
$ bundle exec cap install
```

这条命令会输出下面的信息：

```
mkdir -p config/deploy
create config/deploy.rb
create config/deploy/staging.rb
create config/deploy/production.rb
mkdir -p lib/capistrano/tasks
create Capfile
Capified
```

由此可看出，跟Mina不同，capistrano默认情况下就是多个stage的部署环境，而Mina是要用插件才能做到，所以在这上面，Mina显得简单些，因为并不是每个人都需要多stage的环境的。

#### 3. 修改部署文件

这其中有比较重要的几个文件：`Capfile`，`config/deploy.rb`，`config/deploy/production.rb`。

先来说`Capfile`文件。

这是一个主要的文件，用来加载其他各种文件或组件模块的，Mina没有这个文件，它这样的功能都放到`config/deploy.rb`中了。

```
# Capfile
require 'capistrano/setup'
require 'capistrano/deploy'
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
```

默认情况下，只有上面的三行，其他的都是注释，现在我们要加载rbenv，rails，bundler等组件，所以要把相应的组件打开。

```
# Capfile
require 'capistrano/rbenv'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
```

这些组件都是一个个的gem，所以你需要在Gemfile上添加这些gem。

先添加`rbenv`。

```
gem 'capistrano-rbenv'
gem 'capistrano-bundler'
gem 'capistrano-rails'
```

到`config/deploy.rb`文件中添加下面几行。

```
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.3.0'

# in case you want to set ruby version from the file:
# set :rbenv_ruby, File.read('.ruby-version').strip
#
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value

# 可以看到bundle install的输出
set :bundle_flags, ''
```

接下来是`config/deploy.rb`文件。

这个文件指定的是部署的应用名称，主机地址和目录，源码库地址等信息，Mina也是在这个文件中指定。

```
# config/deploy.rb
# 部署的应用名
set :application, 'rails365_cap'
# 源码地址
set :repo_url, 'git@github.com:yinsigan/rails365.git'
# 源码分支
set :branch, "cap"
# 部署目录
set :deploy_to, "/home/yinsigan/#{fetch(:application)}"
# 链接的文件
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/application.yml')
# 链接的目录
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'pids', 'tmp/sockets')
```

至于`config/deploy`目录下的文件就是不同的stage的部署文件，是对`config/deploy.rb`的继承，可以重写`config/deploy.rb`的配置，它主要是指定了部署的主机和用户名，还有一些ssh连接的信息。

```
# config/deploy/production.rb
server 'www.rails365.net', user: 'yinsigan', roles: %w{app db web}
set :rails_env, "production"
set :stage, :production
```

#### 4. 部署之前

上面的工作看似准备差不多了，有了主机的地址，用户名，还有源码库的地址，分支，就可以下载代码。

首先要确保你的主机是能下载到代码的，所以有必要先将主机的ssh public key上传到托管源码的网站上。

然后是要确保linked_files文件是存在的，例如上面的`config/database.yml`和`config/application.yml`，这两个文件可以到主机上自己创建。

存放的位置是shared/config目录下，例如`rails365_cap/shared/config`，`rails365_cap`是部署的目录。

还有，在部署之前，要先安装`bundler`这个gem。

#### 5. 部署命令

现在可以开始来部署。

输出所有可用的命令。

```
$ bundle exec cap -T
```

执行部署。

```
$ bundle exec cap production deploy
```

可以看到，跟Mina不同的是，它不用自己去手动生成linked_dirs目录，capistrano会自动生成各种链接目录。

如果怕出错，还可以模拟生产环境的部署，但实际上没有做任何事。

```
$ bundle exec cap production deploy --dry-run
```

#### 6. 让应用跑起来

上面是看似完成了部署，但是我们的应用没有跑起来。所以我们需要使用unicorn来加载整个应用，整个应用监听在一个文件socket上。

##### 6.1 unicorn

只要我们做到部署的时候，unicorn也让它重启就OK，没有必要自己写shell脚本，我们用一个插件来完成。

这个插件是[capistrano3-unicorn](https://link.jianshu.com?t=https://github.com/tablexi/capistrano3-unicorn)。

添加下面的代码到`Gemfile`文件：

```
group :development do
  gem 'capistrano3-unicorn', '~> 0.2.1'
end
gem 'unicorn', '~> 4.9.0'
```

添加下面这行到`Capfile`文件：

```
require 'capistrano3/unicorn'
```

找到`config/deploy.rb`文件，修改如下：

```
after 'deploy:publishing', 'deploy:restart'
namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  task :restart do
    invoke 'unicorn:legacy_restart'
  end

end
```

除些之外，unicorn是需要配置的，比如配置文件存放的位置，pid文件的位置，监听的socket存放的位置，加载的环境(development，production)等。默认的情况下是这样的：

```
set :unicorn_pid, -> { File.join(current_path, "tmp", "pids", "unicorn.pid") }
set :unicorn_config_path, -> { File.join(current_path, "config", "unicorn", "#{fetch(:rails_env)}.rb") }
set :unicorn_roles, -> { :app }
set :unicorn_options, -> { "" }
set :unicorn_rack_env, -> { fetch(:rails_env) == "development" ? "development" : "deployment" }
set :unicorn_restart_sleep_time, 3
```

我们要确保pid和socket文件是在linked_dirs目录下。

添加下面一行到`config/deploy.rb`文件中：

```
set :unicorn_config_path, -> { File.join(current_path, "config", "unicorn.rb") }
```

主要的配置文件是`config/unicorn.rb`，大多数内容在里面定义。

```
app_path = File.expand_path( File.join(File.dirname(__FILE__), '..', '..'))
worker_processes   1
timeout            180
listen             "#{app_path}/shared/tmp/sockets/unicorn.sock"
pid                "#{app_path}/shared/tmp/pids/unicorn.pid"
stderr_path        "log/unicorn.log"
stdout_path        "log/unicorn.log"

# preload
preload_app true

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end

before_exec do |server| # 修正无缝重启unicorn后更新的Gem未生效的问题，原因是config/boot.rb会优先从ENV中获取BUNDLE_GEMFILE，而无缝重启时ENV['BUNDLE_GEMFILE']的值并未被清除，仍指向旧目录的Gemfile
  ENV["BUNDLE_GEMFILE"] = "#{app_path}/current/Gemfile"
end
```

再次执行`bundle exec cap production deploy`部署，完成后可以用ps来查看进程的情况。

```
root@iZ94x9hoenwZ:~# ps -ef | grep unicorn
yinsigan  5457     1  3 17:07 ?        00:00:03 unicorn master -c /home/yinsigan/rails365_cap/current/config/unicorn.rb -E production -D                                                       
yinsigan  7409  5457  0 17:07 ?        00:00:00 unicorn worker[0] -c /home/yinsigan/rails365_cap/current/config/unicorn.rb -E production -D
```

unicorn现在是加载了整个rails应用并以文件socket的形式监听，我们可以用nginx反向代理到这个文件sokcet上就可以实现外网访问了。

##### 6.2 sidekiq

除了unicorn，我们还需要把sidekiq给跑起来。

我们使用是[capistrano-sidekiq](https://link.jianshu.com?t=https://github.com/seuros/capistrano-sidekiq)这个插件。

添加下面的代码到`Gemfile`文件：

```
group :development do
  gem 'capistrano-sidekiq', '~> 0.5.4'
end
```

添加下面两行到`Capfile`文件中：

```
require 'capistrano/sidekiq'
```

修改`config/deploy.rb`文件：

```
set :rbenv_map_bins, %w{rake gem bundle ruby rails sidekiq sidekiqctl}
```

再重新部署。

#### 7. 高级选项

这部分介绍一些capistrano部署时的高级选项。

##### 7.1 capistrano支持回滚。

```
$ bundle exec cap production deploy:rollback
```

##### 7.2 设置日志等级。

默认情况下，部署时输出的日志等级为debug。

我们可以指定为info，让输出的信息更少一些。

```
# config/deploy.rb
set :log_level, :info
```

##### 7.3 使用ask命令

使用ask命令，可以让部署的时候暂停，等待输入，并传递输入的内容给指定的变量，使用它可以轻易地实现交互式的部署。

```
# 输入部署的分支
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
```

##### 7.4 自定义task

`lib/capistrano/tasks`这个目录可以放自己的task。

比如运行`rake db:seed`。

```
# lib/capistrano/tasks/setup.rake
namespace :setup do

  desc "Seed the database."
  task :seed_db do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: :production do
          execute :rake, "db:migrate"
          execute :rake, "db:seed"
        end
      end
    end
  end

end
```

运行`bundle exec cap production setup:seed_db`可执行上面的task。

上传一个文件到服务器中。

```
# lib/capistrano/tasks/setup.rake
namespace :setup do

  desc "upload rails.conf to shared dir"
  task :upload_nginx do
    on roles(:app) do
      upload! StringIO.new(File.read("config/rails.conf")), "#{shared_path}/config/nginx.conf"
    end
  end

end
```

查看生产环境的日志。

```
# lib/capistrano/tasks/setup.rake
namespace :setup do

  desc "tailf production log"
  task :production_log do
    on roles(:app) do
      execute "tail -f #{current_path}/log/production.log"
    end
  end

end
```

固定的分支才能部署。

```
namespace :deploy do

  desc "Makes sure local git is in sync with remote."
  task :check_revision do
    unless `git rev-parse HEAD` == `git rev-parse origin/deploy`
      puts "WARNING: HEAD is not the same as origin/develop"
      puts "Run `git push` to sync changes."
      exit
    end
  end

  before :deploy, "deploy:check_revision"
end
```

#### 8. 加速rake assets:precompile

在每次部署的时候，都会重新编译整个静态资源，即`rake assets:precompile`，这个过程又很慢。

我们需要有一个机制，就是有静态文件改变的时候才重新编译，不然的话不用重新编译。

而[capistrano-faster-assets](https://link.jianshu.com?t=https://github.com/capistrano-plugins/capistrano-faster-assets)就是解决这个问题的。

添加下面这行到`Gemfile`文件中：

```
gem 'capistrano-faster-assets', '~> 1.0.2'
```

添加下面这行到`Capfile`文件中，但需要在`require 'capistrano/rails/assets'`之后：

```
require 'capistrano/faster_assets'
```

重新部署即可。