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

# This provider manages an AEM JCR node permissions

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

def make_url(new_resource, action)
  "http://#{new_resource.host}:#{new_resource.port}/#{new_resource.path}/#{new_resource.name}.#{action}.json"
end

def set_permission(new_resource, fields)
  url = make_url(new_resource, 'modifyAce')

  c = curl_form(url, new_resource.user, new_resource.password, fields)
  if c.response_code == 200 || c.response_code == 201
    new_resource.updated_by_last_action(true)
    Chef::Log.debug("New jcr_node was created at #{new_resource.path}")
  else
    fail "JCR Setting node privileges failed. HTTP code: #{c.response_code}"
  end
end

def remove_permission(new_resource, fields)
  url = make_url(new_resource, 'deleteAce')

  c = curl_form(url, new_resource.user, new_resource.password, fields)
  if c.response_code == 200 || c.response_code == 201
    new_resource.updated_by_last_action(true)
    Chef::Log.debug("New jcr_node was created at #{new_resource.path}")
  else
    fail "JCR Removing node privileges failed. HTTP code: #{c.response_code}"
  end
end

action :create do
  converge_by 'Set node permissions' do
    fields = [
      Curl::PostField.content('principalId', new_resource.principal)
    ]
    new_resource.privileges.each do |privilege, permission|
      fields << Curl::PostField.content("privilege@#{privilege}", permission)
    end
    set_permission(new_resource, fields)
  end
end

action :delete do
  converge_by 'Remove node permissions' do
    fields = [
      Curl::PostField.content('applyTo', new_resource.principal)
    ]
    remove_permission(new_resource, fields)
  end
end
