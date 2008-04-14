set :keep_releases, 3
set :application, "apicaday"

set :scm, :git
set :user, "mik"
set :repository,  "git@github.com:sudothinker/pic-a-day.git"
set :branch, "origin/master"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :port, 8888
set :deploy_to, "/home/mik/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :location, 'pseudothinker.com'
role :app, location
role :web, location
role :db,  location, :primary => true

set :deploy_via, :remote_cache
set :runner, user

after "deploy:symlink", "sudothinker_symlink_configs"
after "deploy", "deploy:migrate", "reload_mongrel", "reload_nginx", "deploy:cleanup"

desc "Reload Mongrels"
task :reload_mongrel do
  run <<-CMD 
    cd #{release_path} && mongrel_rails cluster::stop
  CMD
  run <<-CMD 
    cd #{release_path} && mongrel_rails cluster::start
  CMD
end

desc "Reload Nginx"
task :reload_nginx do
  sudo "/etc/init.d/nginx reload"
end

# Symlink to non-standard environment-specific configuration
task :sudothinker_symlink_configs, :roles => :app, :except => {:no_release => true, :no_symlink => true} do
  run <<-CMD
    ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml
  CMD
  run <<-CMD
    ln -nfs #{shared_path}/config/amazon_s3.yml #{release_path}/config/amazon_s3.yml
  CMD
end