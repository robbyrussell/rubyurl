# Required for using Mongrel with Capistrano2
#   gem install palmtree

require 'palmtree/recipes/mongrel_cluster'

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
#   set :boxcar_server, 'rc1.railsboxcar.com'
set :boxcar_server, '198.145.115.94'

# What is the username of your Rails Boxcar user that you want
# to deploy this application with? Note that you should use the same
# username and password as you use to access your repository. This is
# due to a limitation in Capistrano.

set :boxcar_username, 'borat'

# Where is your source code repository?
#
# Subversion Example:
#
#set :user, 'rubyurl'
#set :repository, 'https://svn.roundhaus.com/planetargon/rubyurl_2-0/trunk'
#
# If you won't be making any code changes on the boxcar itself, it's
# a good idea to do an export instead of a checkout (default) so that
# you avoid all of the .svn cruft.
#set :deploy_via, :export

#
# Git Example:
#   
set :scm, "git"
set :repository, "git://github.com/robbyrussell/rubyurl.git"
