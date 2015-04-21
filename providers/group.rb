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

require 'curb'

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

action :create do
end

action :delete do
end
