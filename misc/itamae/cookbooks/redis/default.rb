node[:redis] ||= {}
node[:redis][:version] ||= 'stable'

Itamae.logger.info "Set Redis vertion to '#{node[:redis][:version]}'."

package 'curl'

execute "curl -O 'http://download.redis.io/releases/redis-#{node[:redis][:version]}.tar.gz' 2>/dev/null" do
  cwd '/usr/local/src'
  only_if "redis-server version || test '#{node[:redis][:version]}' = `redis-server --version | sed -e 's/.\+ v=\([\.0-9a-zA-Z]\+\) .\+$/\1/g'`"
end

execute "tar zxf /usr/local/src/redis-#{node[:redis][:version]}.tar.gz" do
  cwd '/usr/local/src'
  not_if "test -e /usr/local/src/redis-#{node[:redis][:version]}"
  only_if "test -e /usr/local/src/redis-#{node[:redis][:version]}.tar.gz"
end

execute "make PREFIX=/usr && make install" do
  cwd "/usr/local/src/redis-#{node[:redis][:version]}"
  only_if "test -e /usr/local/src/redis-#{node[:redis][:version]}"
end

directory '/etc/redis'

execute "cp /usr/local/src/redis-#{node[:redis][:version]}/redis.conf /etc/redis/re
dis.conf" do
  not_if 'test -e /etc/redis/redis.conf'
end

file '/etc/redis/redis.conf' do
  action :edit
  block do |content|
    content.gsub!(/^(daemonize) .*$/, '\1 yes')
    content.gsub!(/^ *(bind) .*\n$/, '')
    content.gsub!(/^(# bind 127.0.0.1)\n$/, '\1' + "\nbind 0.0.0.0\n")
  end
  only_if 'test -e /etc/redis/redis.conf'
end

directory "/usr/local/src/redis-#{node[:redis][:version]}" do
  action :delete
  only_if "test -e /usr/local/src/redis-#{node[:redis][:version]}.tar.gz"
end

file "/usr/local/src/redis-#{node[:redis][:version]}.tar.gz" do
  action :delete
  only_if "test -e /usr/local/src/redis-#{node[:redis][:version]}.tar.gz"
end

remote_file '/etc/monit.d/redis' do
  owner 'root'
  group 'root'
  notifies :reload, "service[monit.service]"
end

if node[:platform] == 'centos' && node[:platform_version].to_i == 7
  firewalld_zone 'public' do
    interfaces node[:network][:interfaces].keys - ['lo']
    #services   %w(dhcpv6-client http ssh)
    ports      %w(6379/tcp)
    default_zone true
    notifies :reload, "service[firewalld]"
  end
end

