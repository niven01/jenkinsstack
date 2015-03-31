# Encoding: utf-8
#
# Cookbook Name:: jenkinsstack
# Recipe:: _base
#
# Copyright 2014, Rackspace
#

node.override['apt']['compile_time_update'] = true
include_recipe 'apt'

include_recipe 'build-essential'

# get curl for testing/jenkins stuff
include_recipe 'curl::default'

# other settings
node.default['nginx']['default_site_enabled'] = false

# jenkins settings
node.default['jenkins']['master']['jvm_options'] = '-XX:MaxPermSize=512m'
node.default['jenkins']['master']['listen_address'] = '127.0.0.1'

# The following attributes need to match. They are the jenkins.war version to download from
# http://mirrors.jenkins-ci.org/war/ and the sha256 hash of the file to prevent download
# of the war file on every Chef run.
# comment out old version --
node.default['jenkins']['master']['install_method'] = 'war'
node.default['jenkins']['master']['version']      = '1.555'
node.default['jenkins']['master']['checksum'] = '31f5c2a3f7e843f7051253d640f07f7c24df5e9ec271de21e92dac0d7ca19431'
node.default['jenkins']['master']['source'] = 'http://d150860c924442f0c4ba-bb788a6a02be77ad65ac0686e629b047.r71.cf3.rackcdn.com/packages/jenkins/1.555/jenkins.war'

node['jenkinsstack']['packages'].each do |pkg|
  package pkg do
    action :install
  end
end

# Hate to do these creates here, since they are also on _prep_keys, but slaves
# need them too.

# Create the Jenkins user
user node['jenkins']['master']['user'] do
  home node['jenkins']['master']['home']
  shell '/bin/bash'
end

# Create the Jenkins group
group node['jenkins']['master']['group'] do
  members node['jenkins']['master']['user']
end

# create .ssh dir for jenkins
directory "#{node['jenkins']['master']['home']}/.ssh" do
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode 00700
  recursive true
end
