package 'git'
package 'rpm-build'

git '/usr/local/src/checkinstall' do
  repository 'http://checkinstall.izto.org/checkinstall.git'
  not_if 'checkinstall -v'
end

#file '/usr/local/src/checkinstall/checkinstallrc-dist' do
#  action :edit
#  block do |content|
#    content.gsub!(/^(MAKEPKG)=.*$/, '\1=')
#    content.gsub!(/^(TRANSLATE)=.*$/, '\1=0')
#    content.gsub!(/^(EXCLUDE)=.*$/, '\1="/selinux"')
#  end
#  only_if 'test -e /usr/local/src/checkinstall/checkinstallrc-dist'
#end

file '/usr/local/src/checkinstall/installwatch/Makefile' do
  action :edit
  block do |content|
    content.gsub!(/^(LIBDIR)=.*$/, '\1=$(PREFIX)/lib64')
  end
  only_if 'test -e /usr/local/src/checkinstall/installwatch/Makefile'
end

execute 'make && make install' do
  cwd '/usr/local/src/checkinstall'
  not_if 'checkinstall -v'
end

directory '/root/rpmbuild/SOURCES'

execute '/usr/local/sbin/checkinstall -y -R' do
  cwd '/usr/local/src/checkinstall'
  not_if 'ls /root/rpmbuild/RPMS/x86_64/checkinstall-*'
end

#execute 'rpm -ivh /root/rpmbuild/RPMS/x86_64/checkinstall-*' do
#  only_if 'ls /root/rpmbuild/RPMS/x86_64/checkinstall-*'
#  not_if 'rpm -qa | grep checkinstall'
#end

#directory '/usr/local/src/checkinstall' do
#  action :delete
#end
