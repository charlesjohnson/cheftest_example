

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

# Chefspec examples can be found at
# https://github.com/sethvargo/chefspec/tree/master/examples

require 'spec_helper'

# This section describes tests for the "testcookbook::default recipe
describe 'testcookbook::default' do
  #
  # It would be really boring to keep typing some things over and over again.
  # Rspec let() gives us the ability to use a shorthand. We use this instead
  # of a local variable assignment because the value of a let() will be cached
  # across multiple calls in the same example, but not across examples.
  let(:testcookbook) { chef_run.node['testcookbook'] }
  let(:indexfile) { chef_run.cookbook_file("#{testcookbook['web_root']}/index.html") }

  #
  # This cookbook supports multiple linux operating systems. If there are tests
  # that must be run differently in different contexts, like resources that
  # might have different names on different linux systems, we can build up
  # shared example sets to use so that we don't repeat ourselves.
  #
  # For an explanation of each example set, see the table in the comments below.
  shared_examples_for :default_recipe do
    #
    # These test names were chosen deliberately. Note that I didn't say "It
    # installs the package," because that's not what Chefspec tests. Chefspec
    # only tests that a package resource is added to the Chef run's resource
    # collection. To test that the package has actually been installed, use
    # Serverspec.
    #
    # To learn more about how Chef builds the resource collection, see
    # https://www.youtube.com/watch?v=ZGDdhgoFAec
    it 'adds a properly configured package resource to the collection, and'\
    'that resource is named by the [\'testcookbook\'][\'package_name\'] attribute' do
      expect(chef_run).to install_package(testcookbook['package_name'])
    end

    it 'adds a properly configured service resource to the collection, and'\
    'that resource is named for the [\'testcookbook\'][\'service_name\'] attribute' do
      expect(chef_run).to start_service(testcookbook['service_name'])
      expect(chef_run).to enable_service(testcookbook['service_name'])
    end
  end

  shared_examples_for :feature_disabled do
    #
    # Again, we're not testing that the recipe won't write out a new index.html
    # file. We're only testing that a resource is not added to the Chef run's
    # resource collection.
    it 'does not add a cookbook_file \'index.html\' resource with action '\
    ':create to the collection' do
      expect(chef_run).not_to create_cookbook_file("#{testcookbook['web_root']}/index.html")
      expect(chef_run).not_to render_file("#{testcookbook['web_root']}/index.html").with_content('Hello world')
    end
  end

  shared_examples_for :feature_enabled do
    #
    # Once again, only testing that the cookbook_file resource is added to the
    # resource collection with the proper action.
    it 'adds a properly configured cookbook_file resource to the collection,'\
    'and that resource is named for the [\'testcookbook\'][\'web_root\']'\
    'attribute' do
      expect(chef_run).to create_cookbook_file("#{testcookbook['web_root']}/index.html")
      expect(chef_run).to render_file("#{testcookbook['web_root']}/index.html").with_content('Hello world')
      expect(indexfile.owner).to eq('root')
      expect(indexfile.group).to eq('root')
      expect(indexfile.mode).to eq('0644')
    end
  end

  # This recipe supports platform-specific attribute changes for debian-family
  # Linux, and also has a feature flag that wraps a specific resource.
  # This gives us 4 scenarios to test in Chefspec:
  #
  #    Feature flag on     Feature flag off
  #  +------------------+------------------+
  #  | No OS Specified  |  No OS Specified |
  #  +------------------+------------------+
  #  | Debian family OS | Debian family OS |
  #  +------------------+------------------+
  #
  # To test each of the four scenarios, we create a context. Our four contexts
  # will be:
  #  - default attributes, No OS specified (feature_flag defaults to false)
  #  - default attributes, Debian-family OS specified (feature_flag defaults to false)
  #  - feature_flag attribute is set to true, No OS specified
  #  - feature_flag attribute is set to true, Debian-family OS specified
  #
  # Each context will contain a separate Chef-client run.
  #

  context 'When all attributes are default, on an unspecified platform, the recipe:' do
    #
    # Again, it would be really boring to keep typing
    # ChefSpec::ServerRunner.new.converge(described_recipe)
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    # We hardcode the attribute names in the test to catch any regressions that
    # might be caused in the future by changes to the default attributes
    # file
    it 'sets the default attributes correctly' do
      expect(testcookbook['package_name']).to eq('httpd')
      expect(testcookbook['service_name']).to eq('httpd')
      expect(testcookbook['web_root']).to eq('/var/www/html')
    end

    # Invoke the shared example sets defined above
    it_behaves_like :default_recipe
    it_behaves_like :feature_disabled
  end

  context 'When all attributes are default, on a Debian-family platform, the recipe:' do
    #
    # Again, it would be really boring to keep typing
    # ChefSpec::ServerRunner.new.converge(described_recipe)
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04')
      runner.converge(described_recipe)
    end

    # We hardcode the attribute names in the test to catch any regressions that
    # might be caused in the future by changes to the default attributes
    # file
    it 'sets the default attributes correctly' do
      expect(testcookbook['package_name']).to eq('apache2')
      expect(testcookbook['service_name']).to eq('apache2')
      expect(testcookbook['web_root']).to eq('/var/www')
    end

    # Invoke the shared example sets defined above
    it_behaves_like :default_recipe
    it_behaves_like :feature_disabled
  end

  context 'When the feature_flag attribute is true, on an unspecified platform, the recipe:' do
    #
    # Again, it would be really boring to keep typing
    # ChefSpec::ServerRunner.new.converge(described_recipe)
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.node.set['testcookbook']['feature_flag'] = true
      runner.converge(described_recipe)
    end

    # Note that the default attribute regression test was dropped, as we're no
    # longer testing the default attribute set.

    # Invoke the shared example set defined above
    it_behaves_like :default_recipe
    it_behaves_like :feature_enabled
  end

  context 'When the feature_flag attribute is true, on a Debian-family platform, the recipe:' do
    #
    # Again, it would be really boring to keep typing
    # ChefSpec::ServerRunner.new.converge(described_recipe)
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04')
      runner.node.set['testcookbook']['feature_flag'] = true
      runner.converge(described_recipe)
    end

    # Note that the default attribute regression test was dropped, as we're no
    # longer testing the default attribute set.

    # Invoke the shared example set defined above
    it_behaves_like :default_recipe
    it_behaves_like :feature_enabled
  end
end
