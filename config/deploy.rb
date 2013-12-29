#require 'vendor/plugins/capistrano_mailer/lib/capistrano_mailer'
set :application, "IFEL Wicked Start"

default_run_options[:pty] = true
puts "The application name is #{application}"

task :staging do
  role :app, "66.135.40.62"
  role :web, "66.135.40.62"
  role :db,  "66.135.40.62", :primary => true

  set :rake, "/opt/ruby-enterprise-1.8.7-2010.02/bin/rake"
  set :deploy_to, "/var/rails/apps/wibo.wickedstart"
  set :deploy_via, :remote_cache
  set :user, 'wickedstart'
  set :password, Capistrano::CLI.password_prompt("#{fetch(:user, "server_user")} password: ")
  set :use_sudo, false

  set :scm_username, "wickedstart"
  set :scm_password, Capistrano::CLI.password_prompt("#{fetch(:scm_username, "scm_user")} SVN password: ")
  set :repository,  "svn+ssh://#{scm_username}@svn.wickedstart.com/srv/svn/wibo.wickedstart/branches/ifel"

  after 'deploy:update_code' do
    run "mv #{release_path}/config/environments/production.rb #{release_path}/config/environments/del_production.rb"
    run "mv #{release_path}/config/environments/staging.rb #{release_path}/config/environments/production.rb"
  end
  set :jammit, "/opt/ruby-enterprise-1.8.7-2010.02/bin/jammit"
end

task :production do
  role :app, "108.175.150.3"
  role :web, "108.175.150.3"
  role :db,  "108.175.150.3", :primary => true

  set :deploy_to, "/var/rails/apps/ifel.wickedstart"
  set :deploy_via, :remote_cache
  set :user, 'wickedstart'
  set :password, Capistrano::CLI.password_prompt("#{fetch(:user, "server_user")} password: ")

  set :scm_username, "wickedstart"
  set :scm_password, Capistrano::CLI.password_prompt("#{fetch(:scm_username, "scm_user")} SVN password: ")
  set :use_sudo, false
  set :repository,  "svn+ssh://#{scm_username}@svn.wickedstart.com/srv/svn/wibo.wickedstart/branches/ifel"
  set :jammit, "/opt/ruby-enterprise-1.8.7-2012.02/bin/jammit"
  set :rake, "/opt/ruby-enterprise-1.8.7-2012.02/bin/rake"
end

namespace :deploy do
  desc "Restart the app server"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "mv #{release_path}/config/database.yml #{release_path}/config/del_database.yml"
    run "ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml"
    run "mv #{release_path}/public/admin #{release_path}/public/del_admin"
    run "ln -nfs #{shared_path}/admin #{release_path}/public/admin"
    run "ln -nfs #{shared_path}/client #{release_path}/public/client"
#    run "ln -nfs #{shared_path}/wordpress #{release_path}/public/blog"
    run "mv #{release_path}/assets #{release_path}/assets_bak"
    run "ln -nfs #{shared_path}/assets #{release_path}/assets"
    run "ln -nfs #{shared_path}/forum #{release_path}/public/forum"
    
    #    run "ln -nfs /media/s3/admin #{release_path}/public/admin"
    #    run "ln -nfs /media/s3/client #{release_path}/public/client"
  end

  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    default_run_options[:pty] = false
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
  
  desc "Generate minified assets"
  task :generate_assets, :roles => :web do
	  send(:run, "cd #{release_path} && #{jammit} --force config/assets.yml")
	end
end

namespace :delayed_job do
  def rails_env
    set :rails_env, 'production'
    fetch(:rails_env, false) ? "RAILS_ENV=#{fetch(:rails_env)}" : ''
  end

  desc "Show the delayed_job process status"
  task :status, :roles => :app do
    run "cd #{current_path};#{rails_env} ruby script/delayed_job status"
  end

  desc "Stop the delayed_job process"
  task :stop, :roles => :app do
    run "cd #{current_path};#{rails_env} ruby script/delayed_job stop"
  end

  desc "Start the delayed_job process"
  task :start, :roles => :app do
    run "cd #{current_path};#{rails_env} ruby script/delayed_job start"
  end

  desc "Restart the delayed_job process"
  task :restart, :roles => :app do
    run "cd #{current_path};#{rails_env} ruby script/delayed_job restart"
  end
end

after "deploy:update_code", "deploy:symlink_shared"
#after "deploy:symlink",     "deploy:update_crontab", "deploy:generate_assets"
after "deploy:symlink",     "deploy:generate_assets"
after "deploy:stop",        "delayed_job:stop"
after "deploy:start",       "delayed_job:start"
after "deploy:restart",     "delayed_job:restart"