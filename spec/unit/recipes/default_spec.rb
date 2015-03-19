# This Chefspec test was created by Chef generate
#
# Cookbook Name:: testcookbook
# Spec:: default
#
# Author:: Charles Johnson (<charles@chef.io>)
#
# Copyright 2015, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe 'testcookbook::default' do

  # Chefspec examples can be found at
  # https://github.com/sethvargo/chefspec/tree/master/examples

  # For this test we are not specifying an operating system or any changes to
  # the default attributes
  context 'When all attributes are default, on an unspecified platform, the recipe:' do
    
    # It would be really boring to keep typing
    # ChefSpec::ServerRunner.new.converge(described_recipe)
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    # It would be really boring to keep typing chef_run.node['testcookbook']
    let(:testcookbook) { chef_run.node['testcookbook'] }

    # Catch any regressions that might be caused in the future by changes to
    # the default attributes
    it 'sets the default attributes correctly' do
      expect(testcookbook['package_name']).to eq('httpd')
      expect(testcookbook['config_filename']).to eq '/etc/httpd/httpd.conf'
      expect(testcookbook['service_name']).to eq('httpd')
    end

    # The resource names are hardcoded below because we aren't testing whether
    # Chef picks up the attribute name and puts it in the resource as part of
    # our recipe. We already know Chef will do that. It's not worth testing.
    #
    # Rather, what we want to test is that this recipe will create a resource
    # of type package, with the name 'httpd' in the Chef run's resource
    # collection. This is the actual necessary step to install the httpd
    # package on the operating system. We want to ensure that whoever changes
    # this recipe in the future, those resources will still be created when
    # this recipe is run.

    it 'has a package resource to install the httpd package' do
      expect(chef_run).to install_package('httpd')
    end

    # It would be really boring to keep typing
    # chef_run.template('/etc/httpd/httpd.conf')
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
