#
# Cookbook Name:: aem
# Resource:: bundle
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

# This resource manages AEM bundles

actions :install, :start, :stop, :uninstall
default_action :install

attribute :symbolic_name, :kind_of => String, :name_attribute => true, :required => true
attribute :version, :kind_of => String, :default => nil
attribute :bundle_url, :kind_of => String, :default => nil

attribute :host, :kind_of => String, :default => 'localhost'
attribute :user, :kind_of => String, :required => true
attribute :password, :kind_of => String, :required => true
attribute :port, :kind_of => String, :required => true
