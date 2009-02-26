def copy(file_name, from_dir, to_dir)
  FileUtils.mkdir to_dir unless File.exist?(File.expand_path(to_dir))   
  from = File.expand_path(File.join(from_dir,file_name))
  to = File.expand_path(File.join(to_dir, file_name.gsub('.example', '')))
  FileUtils.cp from, to, :verbose => true unless File.exist?(to)
end

# copy config files to application directory
begin 
  templates_dir = File.join(File.dirname(__FILE__), 'templates')
  config_dir = File.join(RAILS_ROOT, 'config')
  root_dir = File.join(RAILS_ROOT)
  copy 'Capfile.example', templates_dir, root_dir
  copy 'deploy.rb.example', templates_dir, config_dir
  puts "#############################################"
  puts "# Boxcar Conductor -- INSTALLED! "
  puts "#   Next steps:"
  puts "#     1. Edit config/deploy.rb"
  puts "#     2. Run cap boxcar:config -q"
  puts "#############################################"  
rescue Exception => e
  puts "There are problems copying Boxcar configuration files to you app: #{e.message}"
end
