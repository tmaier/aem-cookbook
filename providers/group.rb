#
# Cookbook Name:: aem
# Provider:: group
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

# This resource manages AEM groups

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

def make_url(new_resource)
  "http://#{new_resource.host}:#{new_resource.port}/libs/granite/security/post/authorizables"
end

def group_exists?(new_resource)
  first_letter = new_resource.name[0].downcase
  url = "http://#{new_resource.host}:#{new_resource.port}/home/groups/#{first_letter}/#{new_resource.name}.json"
  c = curl(url, new_resource.admin_user, new_resource.admin_password)
  case c.response_code
  when 200, 201
    true
  when 404
    false
  else
    fail "Unable to read group at #{url}. response_code: #{c.response_code} response: #{c.body_str}"
  end
end

action :create do
  unless group_exists?(new_resource)
    converge_by 'Create group' do
      url = make_url(new_resource)
      fields = [
        Curl::PostField.content('createGroup', ''),
        Curl::PostField.content('authorizableId', new_resource.name)
      ]
      curl_form(url, new_resource.admin_user, new_resource.admin_password, fields)
    end
  end
end

action :delete do
  if group_exists?(new_resource)
    converge_by 'Delete group' do
      # ToDo: delete group
    end
  end
end
