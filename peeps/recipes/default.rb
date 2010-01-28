include_recipe "passenger_enterprise"
include_recipe "rails_enterprise"

web_app do
  docroot "/home/tony/peeps/public"
  server_name "peeps.local"
  server_aliases []
  rails_env "production"
end
