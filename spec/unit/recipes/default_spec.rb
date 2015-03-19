# This Chefspec test was created by Chef generate
#
# Cookbook Name:: testcookbook
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'testcookbook::default' do

  # Chefspec examples can be found at
  # https://github.com/sethvargo/chefspec/tree/master/examples

  context 'When all attributes are default, on an unspecified platform, the recipe:' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'has a package resource to install the httpd package' do
      expect(chef_run).to install_package('httpd')
    end

    let(:conffile)  { chef_run.template('/etc/httpd/httpd.conf') }
    it 'has a template resource that writes the /etc/httpd/httpd.conf config file' do
      expect(chef_run).to create_template('/etc/httpd/httpd.conf')
      expect(conffile.owner).to eq('root')
      expect(conffile.group).to eq('root')
      expect(conffile.mode).to eq('0644')
      expect(conffile).to notify('service[httpd]').to(:restart)
    end

    it 'has a service resource to start and enable the httpd service' do
      expect(chef_run).to start_service('httpd')
      expect(chef_run).to enable_service('httpd')
    end

  end
end
