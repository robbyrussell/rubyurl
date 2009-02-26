require 'highline/import'

class Capistrano::Configuration
  ##
  # Read a file and evaluate it as an ERB template.
  # Path is relative to this file's directory.

  def render_erb_template(filename)
    template = File.read(filename)
    result   = ERB.new(template).result(binding)
  end

end

########################################################################
# Advanced Configuration
# Only the courageous of ninjas dare pass this!
########################################################################

role :web, boxcar_server
role :app, boxcar_server
role :db, boxcar_server, :primary => true

# What database server are you using?
# Example:
set :database_name, { :development  => "#{application_name}_development",
                      :test         => "#{application_name}_test",
                      :production   => "#{application_name}_production" }

# user
set :user, boxcar_username
set :use_sudo, false

set :domain_names, Proc.new { HighLine.ask("What is the primary domain name?") { |q| q.default = "railsboxcar.com" } }

set :db_development,database_name[:development]
set :db_test, database_name[:test]
set :db_production, database_name[:production]

# Prompt user to set database user/pass
set :database_username, Proc.new { HighLine.ask("                     What is your database username?  ") { |q| q.default = "dbuser" } }
set :database_host, Proc.new {
  if setup_type.to_s == "quick"
    "localhost"
  else
    HighLine.ask("           What host is your database running on?  ") { |q| q.default = "localhost" }
  end
}
set :database_adapter, Proc.new {
  choose do |menu|
    menu.layout = :one_line
    menu.prompt = "What database server will you be using?  "
    menu.choices(:postgresql, :mysql)
  end
}
set :database_password, Proc.new { database_first = "" # Keeping asking for the password until they get it right twice in a row.
                                   loop do
                                     database_first = HighLine.ask("                   Please enter your database user's password:  ") { |q| q.echo = "." }
                                     database_confirm = HighLine.ask("                        Please retype the password to confirm:  ") { |q| q.echo = "." }
				     break if database_first == database_confirm
				   end
				   database_first }
set :database_socket, Proc.new {
  if setup_type.to_s == "quick"
    "/var/run/mysqld/mysqld.sock"
  else
    HighLine.ask("Where is the MySQL socket file?  ") { |q| q.default = "/var/run/mysqld/mysqld.sock" }
  end
}

set :database_port, Proc.new {
  if setup_type.to_s == "quick"
    if database_adapter.to_s == "postgresql"
      "5432"
    else
      "3306"
    end
  else
    HighLine.ask("                  What port does your database run on?  ") do |q|
      if database_adapter.to_s == "postgresql"
        q.default = "5432"
      else
        q.default = "3306" 
      end
    end
  end
}

# server type
set :server_type, Proc.new {
  choose do |menu|
    menu.layout = :one_line
    menu.prompt = "    What web server will you be using?  "
    menu.choices(:passenger, :mongrel)
  end
}

# directories
set :home, "/home/#{user}"
set :etc, "#{home}/etc"
set :log, "#{home}/log"
set :deploy_to, "#{home}/sites/#{application_name}"

set :app_shared_dir, "#{deploy_to}/shared"


# mongrel
# What port number should your mongrel cluster start on?
set :mongrel_port, Proc.new {
  HighLine.ask("       What port will your mongrel cluster start with?  ", Integer) do |q|
    q.default = 8000
    q.in = 1024..65536
  end
}

# How many instances of mongrel should be in your cluster?
set :mongrel_servers, Proc.new {
  HighLine.ask("                     How many mongrel servers should run?  ", Integer) do |q|
    q.default=3
    q.in = 1..10
  end
}

# what type of setup does the user want?
set :setup_type, Proc.new {
  choose do |menu|
    menu.layout = :one_line
    menu.prompt = "         What type of setup would you like?  "
    menu.choices(:quick, :custom)
  end
}

set :mongrel_conf, "#{etc}/mongrel_cluster.#{application_name}.conf"
set :mongrel_pid, "#{log}/mongrel_cluster.#{application_name}.pid"
set :mongrel_address, '127.0.0.1'
set :mongrel_environment, :production

set :boxcar_conductor_templates, 'vendor/plugins/boxcar-conductor/templates'

set :today, Time.now.strftime('%b %d, %Y').to_s

namespace :boxcar do
  desc 'Configure your Boxcar environment'
  task :config do
    run "mkdir -p #{home}/etc #{home}/log #{home}/sites"
    run "mkdir -p #{app_shared_dir}/config #{app_shared_dir}/log"
    puts ""
    setup_type
    database.configure
    mongrel.cluster.generate unless server_type == :passenger
    puts ""
    say "Setup complete. Now run cap deploy:cold and you should be all set."
    puts ""
  end
  before "boxcar:config", "deploy:setup"

  namespace :deploy do
    desc "Link in the production database.yml"
    task :link_files do
      run "ln -nfs #{app_shared_dir}/config/database.yml #{release_path}/config/database.yml"
      run "ln -nfs #{app_shared_dir}/log #{release_path}/log"
    end
  end

  namespace :database do
    desc "Configure your Boxcar database"
    task :configure do
      database_configuration = render_erb_template("#{boxcar_conductor_templates}/databases/#{database_adapter}.yml.erb")
      put database_configuration, "#{app_shared_dir}/config/database.yml"
    end
  end

  namespace :mongrel do
    namespace :cluster do
      desc "Generate mongrel cluster configuration"
      task :generate do
        mongrel_cluster_configuration = render_erb_template("#{boxcar_conductor_templates}/mongrel_cluster.yml.erb")
        put mongrel_cluster_configuration, mongrel_conf
      end
    end
  end

  after "deploy:update_code", "boxcar:deploy:link_files"

end
