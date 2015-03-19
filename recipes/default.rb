#
# Cookbook Name:: testcookbook
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

package 'httpd' do
  action :install
end

template '/etc/httpd/httpd.conf' do
  source 'httpd.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[httpd]'
end

service 'httpd' do
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end
