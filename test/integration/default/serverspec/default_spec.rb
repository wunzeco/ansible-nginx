require 'spec_helper'

nginx_conf_dir = '/etc/nginx'
nginx_run_dir = '/var/nginx'
nginx_log_dir = '/var/log/nginx'


#-----------------
#  Package
describe package('nginx') do
  it { should be_installed }
end

#-----------------
#  Config
%W(
  #{nginx_conf_dir}
  #{nginx_run_dir}
  #{nginx_log_dir}
  #{nginx_conf_dir}/conf.d
  #{nginx_conf_dir}/conf.mail.d
  #{nginx_conf_dir}/sites-enabled
  #{nginx_conf_dir}/sites-available
  #{nginx_run_dir}/client_body_temp
  #{nginx_run_dir}/proxy_temp
).each do |d|
  describe file(d) do
    it { should be_directory }
    it { should be_mode 755 }
  end
end

describe file("#{nginx_conf_dir}/sites-enabled/default") do
  it { should_not exist }
end

describe file("#{nginx_conf_dir}/nginx.conf") do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
end

#-----------------
#  Service
describe service('nginx') do
  it { should be_running }
end
