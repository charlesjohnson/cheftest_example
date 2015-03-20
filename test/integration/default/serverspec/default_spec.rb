# This serverspec test was created by Chef generate

require 'spec_helper'

describe 'testcookbook::default' do
  #
  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html

  # Serverspec cannot (and should not!) read Chef attributes, so
  # any per-os conditionals have to be re-defined in the test.
  if %w(debian ubuntu).include?(os[:family])
    service_name = 'apache2'
  else
    service_name = 'httpd'
  end

  it 'should configure the server with a started webserver' do
    expect(service(service_name)).to be_running
  end

  it 'should configure the server with an enabled webserver' do
    expect(service(service_name)).to be_enabled
  end

  it 'should configure the server to listen on TCP port 80' do
    expect(port(80)).to be_listening
  end
end
