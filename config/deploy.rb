# config valid for current version and patch releases of Capistrano
lock '~> 3.15.0'

set :application, 'search'
set :repo_url, 'https://github.com/julianog12/julianog12.git'

set :user, 'user1'
set :puma_threads,    [4, 16]
set :puma_workers,    0
set :branch, :master
set :deploy_to, '/home/user1/search'

set :migration_command, 'db:migrate'

before 'deploy:starting', 'deploy:test_suite'

# Default value for :format is :airbrussh.
set :format, :airbrussh

set :pty, true
set :use_sudo, false
set :stage, :production
set :deploy_via, :remote_cache

#Essas configurações já faz automaticamente
#set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
#set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
#set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
#set :puma_access_log, "#{release_path}/log/puma.error.log"
#set :puma_error_log,  "#{release_path}/log/puma.access.log"
#set :puma_preload_app, true
#set :puma_worker_timeout, nil
#set :puma_init_active_record, true

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip
set :rbenv_custom_path, '/home/user1/.rbenv'

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

#after :deploy, 'deploy:database'
#namespace :deploy do
#  task :database, :roles => :app do
#    run "cp #{deploy_to}/shared/database.yml #{current_path}/config/"
#  end
#end
#
#task :restart_sidekiq do
#  on roles(:worker) do
#    execute :service, 'sidekiq restart'
#  end
#end
#after 'deploy:published', 'restart_sidekiq'

#task :puma_sidekiq do
#  on roles(:worker) do
#    execute :service, 'puma restart'
#  end
#end
#after 'deploy:published', 'puma_sidekiq'