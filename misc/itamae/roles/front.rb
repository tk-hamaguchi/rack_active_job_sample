#include_recipe './common.rb'
include_recipe 'rvm::system'

#include_recipe '../cookbooks/redis/default.rb'


rvm_install '2.2' do
  user 'root'
end

require File.expand_path('../../../../lib/rack_active_job_sample/version.rb', __FILE__)

remote_file "/tmp/rack_active_job_sample-#{::RackActiveJobSample::VERSION}.gem" do
  source File.expand_path("../../../../pkg/rack_active_job_sample-#{::RackActiveJobSample::VERSION}.gem", __FILE__)
end

rvm_gem_package "/tmp/rack_active_job_sample-#{::RackActiveJobSample::VERSION}.gem" do
  user 'root'
  rvm_use '2.2'
end

