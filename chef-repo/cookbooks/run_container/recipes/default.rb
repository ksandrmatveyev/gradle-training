#
# Cookbook:: run_container
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

   # 1. Create method for checking free port
def getPort
  Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
  command = 'sudo docker port task4 8080'
  output = shell_out(command).stdout.to_s
  to_return = '8080'
  if output.include? to_return
    to_return = '8081'
  end
  return to_return
  puts to_return
end

   # 2. Pull image with new version
   docker_image 'task4' do
     repo "#{node['docker_registry']}/#{node['image_name']}"
     tag "#{node['image_version']}"
     action :pull
   end

   # 3. Create new version
free_port = getPort
puts free_port

  docker_container 'task4_green' do
      repo "#{node['docker_registry']}/#{node['image_name']}"
      tag "#{node['image_version']}"
      port "#{free_port}:8080"
      action :run
  end

  # 4. Remove container with old version
  docker_container 'task4' do
    action [:stop,:delete]
  end

  # 5. Rename container with old version
  execute 'rename green to blue' do
    command 'sudo docker rename task4_green task4'
  end
