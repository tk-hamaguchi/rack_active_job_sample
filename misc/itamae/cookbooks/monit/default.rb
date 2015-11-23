require 'net/https'

node[:monit] ||= {}
node[:monit][:version] ||= 'latest'

if node[:monit][:version] == 'latest'
  https = Net::HTTP.new('mmonit.com',443)
  https.use_ssl = true
  https.verify_mode = OpenSSL::SSL::VERIFY_NONE
  https.start {
    response = https.get('/monit/dist/binary/')
    node[:monit][:version] = response.body.scan(/href="([\d\.]+)\/"/).last.last
  }
end

Itamae.logger.info "Set Monit vertion to '#{node[:monit][:version]}'."

package 'curl'

execute "curl -L -O 'https://mmonit.com/monit/dist/binary/#{node[:monit][:version]}/monit-#{node[:monit][:version]}-linux-x64.tar.gz' 2>/dev/null" do
  cwd '/usr/local/src'
#  only_if "test ! -e /usr/local/src/monit-#{node[:monit][:version]}-linux-x64.tar.gz"
#  not_if "test '#{node[:monit][:version]}' = `monit -V | head -n 1 | awk '{print $5}'`"
  only_if "monit -V || test '#{node[:monit][:version]}' = `monit -V | head -n 1 | awk '{print $5}'`"
end

execute "tar zxf /usr/local/src/monit-#{node[:monit][:version]}-linux-x64.tar.gz" do
  cwd '/usr/local/src'
  not_if "test -e /usr/local/src/monit-#{node[:monit][:version]}"
  only_if "test -e /usr/local/src/monit-#{node[:monit][:version]}-linux-x64.tar.gz"
end

execute "mv /usr/local/src/monit-#{node[:monit][:version]}/bin/* /usr/local/bin/" do
  only_if "test -e /usr/local/src/monit-#{node[:monit][:version]}"
end

directory '/etc/monit/'
directory '/etc/monit.d/'

remote_file '/lib/systemd/system/monit.service' do
  owner 'root'
  group 'root'
end

template '/etc/monitrc' do
  owner 'root'
  group 'root'
end

template '/etc/monit.d/system' do
  owner 'root'
  group 'root'
  variables(
    filesystem: node[:filesystem].to_a.each_with_object([]) do |(k,v), ary|
                  if v[:mount] && k =~ /^\//
                    name = case v[:mount]
                           when '/'
                             'rootfs'
                           else
                             n = v[:mount]
                             v[:mount][1,n.length].gsub('/','-')
                           end
                    ary << [name, k]
                  end
                end,
    network:    (node[:network][:interfaces].keys - %w(lo))
  )
  notifies :reload, "service[monit.service]"
end


service 'monit.service' do
  action %i(enable start)
end

directory "/usr/local/src/monit-#{node[:monit][:version]}" do
  action :delete
end

file "/usr/local/src/monit-#{node[:monit][:version]}-linux-x64.tar.gz" do
  action :delete
end
