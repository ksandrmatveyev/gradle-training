#
# Cookbook:: run_container
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

docker_service 'default' do
  action [:restart]
end

docker_image 'task4' do
  repo "#{node['docker_registry']}/#{node['image_name']}"
  tag "#{node['image_version']}"
  action :pull
end

docker_container 'task4' do
  repo "#{node['docker_registry']}/#{node['image_name']}"
  tag "#{node['image_version']}"
  port '8080:8080'
  action :run
end
