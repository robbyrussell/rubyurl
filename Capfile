load 'deploy' if respond_to?(:namespace) # cap2 differentiator
load 'config/deploy'
Dir['vendor/plugins/boxcar-conductor/tasks/*.rb'].each { |plugin| load(plugin) }
