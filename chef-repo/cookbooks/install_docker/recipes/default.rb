#
# Cookbook:: install_docker
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

docker_service 'default' do
  action [:create, :start]
  daemon true
  insecure_registry "#{node['docker_registry']}"
  ipv4_forward true
end
