# Required for using Mongrel with Capistrano2
#   gem install palmtree
require 'palmtree/recipes/mongrel_cluster'
require 'highline/import'

########################################################################
# Rails Boxcar - Capistrano Deployment Recipe
# Configuration
######################################################################## 
# What is the name of your application? (no spaces)
# Example: 
#   set :application_name, 'my_cool_app'
set :application_name, 'rubyurl'

# What is the hostname of your Rails Boxcar server?
# Example: 
#    set :boxcar_server, 'rc1.railsboxcar.com'
set :boxcar_server, 'rubyurl.com'

# What is the username of your Rails Boxcar user that you want
# to deploy this application with?
# Example:
#   set :boxcar_username, 'johnny'
set :boxcar_username, 'rubyurl'

# Where is your source code repository?
# Example:
#   set :repository = 'http://svn.railsboxcar.com/my_cool_app/tags/CURRENT'
set :svn_username, 'rubyurl'
set :svn_repository_url, 'https://svn.roundhaus.com/planetargon/rubyurl_2-0/trunk'

# What database server are you using?
# Example:
set :database_name, { :development  => 'rubyurl_development',
                      :test         => 'rubyurl_test',
                      :production   => 'rubyurl_production' }













######################################################################## 
# Advanced Configuration
# Only the courageous of ninjas dare pass this! 
######################################################################## 

role :web, boxcar_server
role :app, boxcar_server
role :db, boxcar_server, :primary => true

# user
set :user, boxcar_username
set :use_sudo, false


set :domain_names, Proc.new { HighLine.ask("What is the primary domain name?") { |q| q.default = "railsboxcar.com" } }


# subversion / SCM
# Ask the user for their subversion password
set :svn_password, Proc.new { HighLine.ask("What is your subversion password for #{svn_username}: ") { |q| q.echo = "x" } }
set :repository, Proc.new { "--username #{svn_username} " + "--password #{svn_password} " + "#{svn_repository_url}" }
set :checkout,   'export'

set :db_development,database_name[:development]
set :db_test, database_name[:test]
set :db_production, database_name[:production]

# Prompt user to set database user/pass
set :database_username, Proc.new { HighLine.ask("What is your database username?  ") { |q| q.default = "dbuser" } }
set :database_host, Proc.new { HighLine.ask("What host is your database running on?  ") { |q| q.default = "localhost" } }
set :database_adapter, Proc.new { 
  choose do |menu|
    menu.prompt = "What database server will you be using?"
    menu.choices(:postgresql, :mysql) 
  end
}
set :database_password, Proc.new { HighLine.ask("What is your database user's password?  ") { |q| q.echo = "x" } }
set :database_socket, Proc.new { HighLine.ask("Where is the MySQL socket file?  ") { |q| q.default = "/var/run/mysqld/mysqld.sock" } }
set :database_port, Proc.new { 
  HighLine.ask("What port does your database run on?  ") do |q| 
    if database_adapter.to_s == "postgresql"
      q.default = "5432" 
    else
      q.default = "3306" 
    end
  end
}

# directories
set :home, "/home/#{user}"
set :etc, "#{home}/etc"
set :log, "#{home}/log"
set :deploy_to, "#{home}/sites/#{application_name}"

set :shared_dir, "#{deploy_to}/shared"

# mongrel
# What port number should your mongrel cluster start on?
set :mongrel_port, Proc.new { HighLine.ask("What port will your mongrel cluster start with?  ") { |q| q.default = "8000" } }

# How many instances of mongrel should be in your cluster?
set :mongrel_servers, Proc.new { 
 choose do |menu|
    menu.prompt = "How many mongrel servers should run?"
    menu.choices(1,2,3)
  end
}

set :mongrel_conf, "#{etc}/mongrel_cluster.#{application_name}.conf" 
set :mongrel_pid, "#{log}/mongrel_cluster.#{application_name}.pid" 
set :mongrel_address, '127.0.0.1'
set :mongrel_environment, :production


# database.yml
desc "Create database.yml in shared/config" 
task :after_setup do
  puts "###########################################"
  puts " Rails Boxcar - setup process"
  puts "###########################################"
  puts "# STEP 1: Database Configuration"
  puts "###########################################" 


  today = Time.now.strftime('%b %d, %Y')

  yml_comment = <<EOF
#
# Generated on #{today} for Rails Boxcar (http://railsboxcar.com)
# 
EOF

  case database_adapter.to_s
    when "postgresql"
      database_configuration = <<EOF
#{yml_comment}      
login: &login
  adapter: #{database_adapter}
  host: #{database_host}
  port: #{database_port}
  username: #{database_username}
  password: #{database_password}

development:
  database: #{db_development}
  <<: *login

test:
  database: #{db_test}
  <<: *login

production:
  database: #{db_production}
  <<: *login
EOF

    when "mysql"
      database_configuration = <<EOF
#{yml_comment}   
login: &login
  adapter: #{database_adapter}
  host: #{database_host}
  port: #{database_port}
  username: #{database_username}
  password: #{database_password}
  socket: #{database_socket}

development:
  database: #{db_development}
  <<: *login

test:
  database: #{db_test}
  <<: *login

production:
  database: #{db_production}
  <<: *login
EOF
      
end

  mongrel_cluster_configuration = <<EOF
#{yml_comment}
--- 
port: #{mongrel_port}
pid_file: #{mongrel_pid}
servers: #{mongrel_servers}
cwd: #{deploy_to}/current
environment: production
EOF

  puts "###########################################"  
  puts "Step 2: Creating necessary directories on\n your Rails Boxcar!"
  puts "###########################################"  
  run "mkdir -p #{shared_dir}/config" 
  
  puts "###########################################"  
  puts "Step 3: Uploading database.yml to Boxcar"
  puts "###########################################"
    
  # Create the database.yml file
  put database_configuration, "#{shared_dir}/config/database.yml"

  puts "###########################################"  
  puts "Step 4: Uploding mongrel cluster config to\n your Rails Boxcar."
  puts "###########################################"  
  
  # Create mongrel cluster configuration
  put mongrel_cluster_configuration, mongrel_conf  

  puts "###########################################"  
  puts "DONE! Now run cap deploy:cold"
  puts "###########################################"  
end

desc "Link in the production database.yml" 
task :after_update_code do
  run "ln -nfs #{shared_dir}/config/database.yml #{release_path}/config/database.yml"
end

