include_recipe "passenger_enterprise::apache2"
include_recipe "rails_enterprise"
include_recipe "mysql::server"

web_app "peeps" do
  docroot "/home/tony/peeps/public"
  server_name "peeps.#{node[:domain]}"
  server_aliases [ "peeps", node[:hostname] ]
  rails_env "production"
end

set.mysql.server_root_password ""

execute "create #{node[:railsapp][:db][:database]} database" do
  command "/usr/bin/mysqladmin -u root -p#{node[:mysql][:server_root_password]} create #{node[:railsapp][:db][:database]}"
  not_if do
    m = Mysql.new("localhost", "root", @node[:mysql][:server_root_password])
    m.list_dbs.include?(@node[:railsapp][:db][:database])
  end
end
