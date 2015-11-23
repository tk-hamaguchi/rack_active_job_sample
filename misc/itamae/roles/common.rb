include_recipe 'selinux::disabled'
execute 'yum update -y' do
  only_if 'yum'
end
if node[:platform] == 'centos' && node[:platform_version].to_i == 7
  require 'itamae/plugin/resource/firewalld'
  service 'firewalld' do
    action [:start, :enable]
  end
end

include_recipe '../cookbooks/monit/default.rb'
