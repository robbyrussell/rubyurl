require 'mongrel_cluster/recipes'

########################################################################
# Rails Boxcar - Capistrano Deployment Recipe
# Configuration
######################################################################## 
# What is the name of your application? (no spaces)
# Example: 
#   set :application_name, 'my_cool_app'
set :application_name, 'rubyurl'

set :domain_names, 'rubyurl.com'

# What is the hostname of your Rails Boxcar server?
# Example: 
#    set :boxcar_server, 'rc1.railsboxcar.com'
set :boxcar_server, '198.145.115.75'

# What is the username of your Rails Boxcar user that you want
# to deploy this application with?
# Example:
#   set :boxcar_username = 'johnny'
set :boxcar_username, 'rubyurl'

# Where is your source code repository?
# Example:
#   set :repository = 'http://svn.railsboxcar.com/my_cool_app/tags/CURRENT'
set :repository, 'https://svn.roundhaus.com/planetargon/rubyurl_2-0/trunk'
set :checkout,   'export'

# What database server are you using?
# Example:
set :database_adapter, 'postgresql'
set :database_name, { :development  => 'rubyurl_development',
                      :test         => 'rubyurl_test',
                      :production   => 'rubyurl_production' }

# What port number is your database running on?
set :database_port, 5432

# What port number should your mongrel cluster start on?
set :mongrel_port, 8000

# How many instances of mongrel should be in your cluster?
set :mongrel_servers, 3

######################################################################## 
# Advanced Configuration
######################################################################## 

role :web, boxcar_server
role :app, boxcar_server
role :db, boxcar_server, :primary => true

# user
set :user, boxcar_username
set :use_sudo, false


set :db_development,database_name[:development]
set :db_test, database_name[:test]
set :db_production, database_name[:production]

# directories
set :home, "/home/#{user}"
set :etc, "#{home}/etc"
set :log, "#{home}/log"
set :deploy_to, "#{home}/sites/#{application_name}"

# mongrel
set :mongrel_conf, "#{etc}/mongrel_cluster.#{application_name}.conf" 
set :mongrel_pid, "#{log}/mongrel_cluster.#{application_name}.pid" 
set :mongrel_address, '127.0.0.1'
set :mongrel_environment, :production

# database.yml
desc "Create database.yml in shared/config" 
task :after_setup do
  database_configuration = render :template => <<-EOF
login: &login
  adapter: <%= database_adapter %>
  host: localhost
  port: <%= database_port %>
  username: dbuser
  password: xy389muw

development:
  database: <%= db_development %>
  <<: *login

test:
  database: <%= db_test %>
  <<: *login

production:
  database: <%= db_production %>
  <<: *login
EOF

  mongrel_cluster_configuration = render :template => <<-EOF
--- 
port: <%= mongrel_port %>
pid_file: <%= mongrel_pid %>
servers: <%= mongrel_servers %>
cwd: <%= deploy_to %>/current
environment: production
EOF

  nginx_generator_configuration = render :template => <<-EOF
  #######################################################################
  # Add the following to /etc/nginx/nginx.yml
  # Then: cd /etc/nginx; generate_nginx_config nginx.yml nginx.conf
  #######################################################################  
  <%= application_name %>:
    # The upstream servers to proxy balance.
    upstream:<% mongrel_servers.to_i.times do |port| %>
    - 127.0.0.1:<%= mongrel_port + port %><% end %>
    # Just a string of server names.
    server_name: <%= domain_names %>
    root: <%= deploy_to %>/current/public
  #######################################################################
EOF

  run "mkdir -p #{deploy_to}/shared/config" 
  
  # Create the database.yml file
  put database_configuration, "#{deploy_to}/#{shared_dir}/config/database.yml"
  
  # Create mongrel cluster configuration
  put mongrel_cluster_configuration, mongrel_conf  
  
  # Print the nginx configuration information for the person deploying.
  puts nginx_generator_configuration
end

desc "Link in the production database.yml" 
task :after_update_code do
  run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml"
end