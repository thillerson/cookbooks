include_recipe "passenger_enterprise"
include_recipe "rails_enterprise"

web_app "peeps" do
  docroot "/home/tony/peeps/public"
  server_name "peeps.#{node[:domain]}"
  server_aliases [ "peeps", node[:hostname] ]
  rails_env "production"
end
