# lock '3.7.2'
lock '3.4.0'

set :application, 'nucleo-website'
set :repo_url, 'git@github.com:Nucleo-235/nucleo-website.git' # Edit this to match your repository
set :branch, :live

set :deploy_to, '/home/deploy-nucleo/nucleo-website'
set :pty, false
set :linked_files, %w{config/database.yml config/application.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads}
set :keep_releases, 5
set :rvm_type, :user
set :rvm_ruby_version, '2.2.4' # Edit this if you are using MRI Ruby

set :puma_rackup, -> { File.join(current_path, 'config.ru') }
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"    #accept array for multi-bind
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_error.log"
set :puma_error_log, "#{shared_path}/log/puma_access.log"
set :puma_role, :web
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [4, 8]
set :puma_workers, 2
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :puma_preload_app, false

# set :sidekiq_role, :app
# set :sidekiq_timeout,  10
# set :sidekiq_processes,  1
# set :sidekiq_concurrency, 33


namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      with rails_env: :production do
        # Here we can do anything such as:
        within release_path do
          # execute :rake, 'cache:clear'
          execute :rake, "assets:precompile"
        end
      end
    end
  end

end