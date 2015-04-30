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

def whyrun_supported?
  true
end

action :install do
  file_path = "#{Chef::Config[:file_cache_path]}/#{new_resource.symbolic_name}-#{new_resource.version}.jar"

  converge_by "Install bundle #{new_resource.symbolic_name}" do
    remote_file file_path do
      source new_resource.bundle_url
      notifies :run, "ruby_block[Install bundle #{new_resource.symbolic_name}]", :immediately
      not_if { bundle.installed? }
    end

    ruby_block "Install bundle #{new_resource.symbolic_name}" do
      block do
        bundle.bundle_path = file_path
        bundle.install!
      end
      only_if { ::File.exists?(file_path) }
    end
  end
end

action :start do
  converge_by "Start bundle #{new_resource.symbolic_name}" do
    ruby_block "Start bundle #{new_resource.symbolic_name}" do
      block do
        bundle.start!
      end
      not_if { bundle.started? }
    end
  end
end

action :stop do
  converge_by "Stop bundle #{new_resource.symbolic_name}" do
    ruby_block "Stop bundle #{new_resource.symbolic_name}" do
      block do
        bundle.stop!
      end
      not_if { bundle.stopped? }
    end
  end
end

action :uninstall do
  converge_by "Uninstall bundle #{new_resource.symbolic_name}" do
    ruby_block "Uninstall bundle #{new_resource.symbolic_name}" do
      block do
        bundle.uninstall
      end
      not_if { bundle.uninstalled? }
    end
  end
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
