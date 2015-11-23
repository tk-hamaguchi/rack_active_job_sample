include_recipe './common.rb'

remote_file '/etc/monit.d/rack_active_job_sample_worker' do
  owner 'root'
  group 'root'
  notifies :reload, "service[monit.service]"
end
