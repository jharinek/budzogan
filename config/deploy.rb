require 'rvm/capistrano'
require 'bundler/capistrano'
#require 'whenever/capistrano'

set :stages, [:staging, :production]

require 'capistrano/ext/multistage'

set :application,    "budzogan"
set :scm,            :git
set :repository,     "git@github.com:jharinek/budzogan.git"
set :scm_passphrase, ''
set :user,           'deploy'
set(:branch)         { rails_env }
set(:deploy_to)      { "/home/deploy/projects/#{application}-#{rails_env}" }

set :use_sudo, false

set :rvm_ruby_string, :local         # use the same ruby as used locally for deployment
set :rvm_autolibs_flag, 'read-only'  # more info: rvm help autolibs
set :rvm_ruby_version, 'ruby-2.1.0@budzogan'

set :deploy_via, :remote_cache
set :git_enable_submodules, 1
set :ssh_options, { forward_agent: true }
set :keep_releases, 5

# Whenever
#set :whenever_command, "RAILS_ENV=#{rails_env} bundle exec whenever"

default_run_options[:pty] = true

namespace :fixtures do
  desc "Create fixtures data"
  task :all, roles: :db do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake fixtures:all"
  end
end

namespace :db do
  desc "Creates DB"
  task :create, roles: :db do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake db:create"
  end

  desc "Sets up current DB for this environment"
  task :setup, roles: :db do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake db:setup"
  end

  desc "Drops DB for this environment"
  task :drop, roles: :db do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake db:drop"
  end

  desc "Migrates DB during release"
  task :create_release, roles: :db do
    run "cd #{release_path}; RAILS_ENV=#{rails_env} bundle exec rake db:create"
  end

  desc "Sets up DB during deployment of release for this environment"
  task :setup_release, roles: :db do
    run "cd #{release_path}; RAILS_ENV=#{rails_env} bundle exec rake db:setup"
  end

  desc "Run database seeds"
  task :seed do
    run "cd #{release_path}; RAILS_ENV=#{rails_env} bundle exec rake db:seed"
  end
end

namespace :deploy do
  [:start, :stop, :restart, :upgrade].each do |command|
    desc "#{command.to_s.capitalize} nginx server"
    task command, roles: :app, except: { no_release: true } do
    end
      run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    end
  end

  desc "Symlink shared"
  task :symlink_shared, roles: :app do
    run "ln -nfs #{shared_path} #{release_path}/shared"
    run "for file in #{shared_path}/config/*.yml; do ln -nfs $file #{release_path}/config; done"
  end

  after 'deploy', 'deploy:cleanup'
  after 'deploy:update_code', 'deploy:symlink_shared', 'db:create_release', 'deploy:migrate', 'db:seed'

  after 'deploy:update_code' do
    run "cd #{release_path}; RAILS_ENV=#{rails_env} bundle exec rake assets:precompile"
  end
end

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#role :web, "your web-server here"                          # Your HTTP server, Apache/etc
#role :app, "your app-server here"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
#namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
#end
