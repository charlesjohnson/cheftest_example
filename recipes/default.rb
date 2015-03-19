#
# Cookbook Name:: testcookbook
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

package node['testcookbook']['package_name'] do
  action :install
end

template node['testcookbook']['config_filename'] do
  source 'httpd.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[#{node['testcookbook']['service_name']}]"
end

service node['testcookbook']['service_name'] do
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end
