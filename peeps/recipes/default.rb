include_recipe "passenger_enterprise::apache2"
include_recipe "rails_enterprise"
include_recipe "mysql::server"

# deploy directory
directory node[:railsapp][:dir] do
 owner node[:deploy_user][:name]
end

# capify
%w{ releases
    shared
    shared/system
    shared/pids
    shared/log
    releases
    releases/1
    releases/1/public
    releases/1/tmp
  }.each do |dir|
  directory "#{node[:railsapp][:dir]}/#{dir}" do
    owner node[:deploy_user][:name]
  end
end

# hack a public dir together so the web app will get started
link( "#{node[:railsapp][:dir]}/current") { to "#{node[:railsapp][:dir]}/releases/1" }

web_app node[:railsapp][:name] do
  docroot "#{node[:railsapp][:dir]}/current/public"
  server_name "#{node[:railsapp][:name]}.#{node[:domain]}"
  server_aliases [ node[:railsapp][:name], node[:hostname] ]
  rails_env "production"
end

execute "create #{node[:railsapp][:db][:database]} database" do
  root_p = node[:mysql][:server_root_password]
  pass =  "-p#{root_p}" unless root_p == ""
  command "/usr/bin/mysqladmin -u root #{pass} create #{node[:railsapp][:db][:database]}"
  not_if do
    m = Mysql.new("localhost", "root", @node[:mysql][:server_root_password])
    m.list_dbs.include?(@node[:railsapp][:db][:database])
  end
end
