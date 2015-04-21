#
# Cookbook Name:: aem
# Resource:: jcr_node_permission
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

# This resource manages AEM JCR node permissions

actions :create, :delete
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :path, kind_of: String, required: true
attribute :privileges, kind_of: String, required: true
attribute :principal, kind_of: Hash, required: true

attribute :host, kind_of: String, required: true
attribute :port, kind_of: String, required: true
attribute :user, kind_of: String, required: true
attribute :password, kind_of: String, required: true
