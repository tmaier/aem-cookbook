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

action :install do
  return if bundle.installed?

  file_path = "#{Chef::Config[:file_cache_path]}/#{new_resource.symbolic_name}-#{new_resource.version}.jar"

  remote_file file_path do
    source new_resource.bundle_url
    notifies :run, "ruby_block[Install Bundle #{new_resource.symbolic_name}]", :immediately
  end

  ruby_block "Install Bundle #{new_resource.symbolic_name}" do
    action :nothing
    block do
      bundle.bundle_path = file_path
      bundle.install!
    end
  end
end

action :start do
  bundle.start! unless bundle.started?
end

action :stop do
  bundle.stop! unless bundle.stopped?
end

action :uninstall do
  bundle.uninstall if bundle.installed?
end

def bundle
  return @bundle if @bundle

  uri = URI("http://#{new_resource.host}:#{new_resource.port}")
  uri.user = new_resource.user
  uri.password = new_resource.password

  @bundle =
    AEM::Bundle.new symbolic_name: new_resource.symbolic_name,
                    version: new_resource.version,
                    aem_uri: uri
end
