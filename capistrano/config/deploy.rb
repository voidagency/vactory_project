# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "vactory8"
set :repo_url, "git@bitbucket.org:adminvoid/vactory8.git"
set :linked_files, fetch(:linked_files, []).push('sites/default/settings.local.php')
set :linked_dirs, fetch(:linked_dirs, []).push('sites/default/files')
set :linked_dirs, fetch(:linked_dirs, []).push('sites/default/private')
set :keep_releases, 5
set :app_path, '.'
set :deploy_via, :remote_cache

# @todo: use full path or "#{shared_path.join("composer.phar")}" > shared_path gives wrong path
SSHKit.config.command_map[:composer] = "composer"

namespace :deploy do
  after :starting, 'composer:install_executable'
end

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

namespace :vactory8 do
  desc 'Vactory Drupal 8 deploy process'
  task :deploy do
    on roles(:app) do

      info "Clear Drush Cache"
      invoke "drupal:drush_clear_cache"

      execute :mkdir, "-p ~/databases-backup"
      within release_path.join(fetch(:app_path)) do
        info "Backup Database"
        execute :drush, "sql-dump > ~/databases-backup/db-#{Time.now.strftime("%m-%d-%Y--%H-%M-%S")}.sql"
      end

      #info "Backup Database"
      #invoke "drupal:backupdb"

      info "Puts site offline "
      invoke "drupal:site_offline"

      within release_path.join(fetch(:app_path)) do
        info "advagg-caf"
        execute :drush, 'advagg-caf'

        #info "advagg-cdc"
        #execute :drush, 'advagg-cdc'
      end

      info "Puts site on line "
      invoke "drupal:site_online"

      info "Clear cache"
      invoke "drupal:cache:clear"

    end
  end
  desc 'Reindex data in Solr'
  task :reindex do
     on roles(:app) do
      within current_path do
          (2..13).each do |i|
            unless i==9
              info "Puts site on line " + i.to_s
              execute :drush, 'sapi-r' , i
              execute :drush, 'sapi-i' , i
            end
          end
      end
     end
  end

  desc 'Set permissions on old releases before cleanup'
   task :cleanup_settings_permission do
       on release_roles :all do |host|
       releases = capture(:ls, "-x", releases_path).split
       valid, invalid = releases.partition { |e| /^\d{14}$/ =~ e }

       warn t(:skip_cleanup, host: host.to_s) if invalid.any?

       if valid.count >= fetch(:keep_releases)
         info t(:keeping_releases, host: host.to_s, keep_releases: fetch(:keep_releases), releases: valid.count)
         directories = (valid - valid.last(fetch(:keep_releases))).map do |release|
           releases_path.join(release).to_s
         end
         if test("[ -d #{current_path} ]")
           current_release = capture(:readlink, current_path).to_s
           if directories.include?(current_release)
             warn t(:wont_delete_current_release, host: host.to_s)
             directories.delete(current_release)
           end
         else
           debug t(:no_current_release, host: host.to_s)
         end
         if directories.any?
           directories.each  do |dir_str|
             execute :chmod, "-R 755", dir_str
           end
         else
           info t(:no_old_releases, host: host.to_s, keep_releases: fetch(:keep_releases))
         end
       end
     end
   end

   desc 'Apply htaccess restricted area patch on preprod instance'
   task :apply_htaccess_patch do
       on roles(:app) do
           if fetch(:instance_type, 'preprod') != 'production'
               execute 'cat ~/public_html/assets/.custom_htaccess >> ~/public_html/web/.htaccess'
           end
       end
   end

   desc 'Apply Permissions'
   task :apply_permissions do
       on roles(:app) do
           info "Apply Permissions -d 755 -f 644"
           within release_path.join(fetch(:app_path)) do
               info "#{release_path}/"
               execute :find, "#{release_path}/", " -type d -exec chmod u=rwx,g=rx,o=rx '{}' ';'"
               execute :find, "#{release_path}/", " -type f -exec chmod u=rw,g=r,o=r '{}' ';'"
           end
       end
   end

  after 'deploy:updated', 'vactory8:deploy'
  before 'deploy:finishing', 'vactory8:cleanup_settings_permission'
  after 'deploy:finishing', 'vactory8:apply_htaccess_patch'
  after 'deploy:finished', 'vactory8:apply_permissions'
end
