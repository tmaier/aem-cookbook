#
# Cookbook Name:: aem
# Provider:: jcr_node_permission
#
# Copyright 2015
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

# This provider manages AEM bundles

require 'json'
require 'timeout'

def curl(url, user, password)
  c = Curl::Easy.new(url)
  c.http_auth_types = :basic
  c.username = user
  c.password = password
  c.perform
  c
end

def curl_form(url, user, password, fields)
  c = Curl::Easy.http_post(url, *fields)
  c.http_auth_types = :basic
  c.username = user
  c.password = password
  c.multipart_form_post = true
  c.perform
  c
end

def curl_install(file, new_resource)
  url = "http://#{new_resource.host}:#{new_resource.port}/system/console/bundles"
  cmd = %Q(curl -u #{new_resource.user}:#{new_resource.password} -F action=install -F bundlestartlevel=20 -F bundlefile=@"#{file}" #{url})
  runner = Mixlib::ShellOut.new(cmd)
  runner.run_command
  runner.error!
  Timeout::timeout(600) do
    loop do
      sleep(1)
      break if bundle?(new_resource)
    end
  end
end

def curl_activate(new_resource)
  url = "http://#{new_resource.host}:#{new_resource.port}/system/console/bundles/#{new_resource.symbolic_name}"
  fields = [
    Curl::PostField.content('action', 'start')
  ]
  curl_form(url, new_resource.user, new_resource.password, fields)
end

def curl_disable(new_resource)
  url = "http://#{new_resource.host}:#{new_resource.port}/system/console/bundles/#{new_resource.symbolic_name}"
  fields = [
    Curl::PostField.content('action', 'stop')
  ]
  curl_form(url, new_resource.user, new_resource.password, fields)
end

def curl_uninstall(new_resource)
  url = "http://#{new_resource.host}:#{new_resource.port}/system/console/bundles/#{new_resource.symbolic_name}"
  fields = [
    Curl::PostField.content('action', 'uninstall')
  ]
  curl_form(url, new_resource.user, new_resource.password, fields)
end

def bundle?(new_resource, check_version = true, valid_states = nil)
  url = "http://#{new_resource.host}:#{new_resource.port}/system/console/bundles/#{new_resource.symbolic_name}.json"
  c = curl(url, new_resource.user, new_resource.password)
  case c.response_code
  when 200, 201
    content = JSON.parse(c.body_str)
    result =
      content['data']
        .select { |h| h['symbolicName'] == new_resource.symbolic_name }

    if check_version
      result =
        result.select { |h| h['version'] == new_resource.version }
    end

    if valid_states && !valid_states.empty?
      result =
        result.select { |h| valid_states.include?(h['state']) }
    end

    result.size > 0
  when 404
    false
  else
    fail "Unable to read bundle data at #{url}. response_code: #{c.response_code} response: #{c.body_str}"
  end
end

action :install do
  unless bundle?(new_resource)
    file_path = "#{Chef::Config[:file_cache_path]}/#{new_resource.symbolic_name}-#{new_resource.version}.jar"
    remote_file file_path do
      source new_resource.bundle_url

      action :create
    end

    curl_install(file_path, new_resource)
  end
end

action :start do
  unless bundle?(new_resource, false, %w(Active Fragment))
    curl_activate(new_resource)
  end
end

action :stop do
  if bundle?(new_resource, false)
    curl_disable(new_resource)
  end
end

action :uninstall do
  if bundle?(new_resource, false)
    curl_uninstall(new_resource)
  end
end
