#
# Cookbook Name:: hhbd-app
# Recipe:: install
#
# Copyright 2015, WebAsCrazy.net <jakub.kulak@gmail.com>
#

# Additional packages

include_recipe "jku-common"
include_recipe "jku-memcached"

# Create initial release repository
directory "#{node['apache']['docroot_dir']}/#{node["hhbd-app"]["url"]}/releases/initial" do
    mode 00755
    action :create
    recursive true
    user node[:deploy][:user]
    group node[:deploy][:group]
end

# Empty directory for /releases/previous symlink
directory "#{node['apache']['docroot_dir']}/#{node["hhbd-app"]["url"]}/releases/preinitial" do
    mode 00755
    action :create
    recursive true
    user node[:deploy][:user]
    group node[:deploy][:group]
end

directory "#{node['apache']['docroot_dir']}/#{node["hhbd-app"]["url"]}/releases/preinitial" do
    mode 00755
    action :create
    recursive true
    user node[:deploy][:user]
    group node[:deploy][:group]
end

# Create current symlinks
link "#{node['apache']['docroot_dir']}/#{node["hhbd-app"]["url"]}/releases/current" do
    to "#{node['apache']['docroot_dir']}/#{node["hhbd-app"]["url"]}/releases/initial"
    user node[:deploy][:user]
    group node[:deploy][:group]
end

# Create previous symlink
link "#{node['apache']['docroot_dir']}/#{node["hhbd-app"]["url"]}/releases/previous" do
    to "#{node['apache']['docroot_dir']}/#{node["hhbd-app"]["url"]}/releases/preinitial"
    user node[:deploy][:user]
    group node[:deploy][:group]
end

# Create current->www symlink
link "#{node['apache']['docroot_dir']}/#{node["hhbd-app"]["url"]}/www" do
    to "#{node['apache']['docroot_dir']}/#{node["hhbd-app"]["url"]}/releases/current"
    user node[:deploy][:user]
    group node[:deploy][:group]
end

# Copy configuration file
template "#{node['apache']['docroot_dir']}/#{node["hhbd-app"]["url"]}/www/application/configs/application.ini" do
    source "application.ini.erb"
    variables('config' => node["hhbd-app"]["config"])
end

# Create log directory
directory "/var/log/#{node["hhbd-app"]["url"]}" do
    user "www-data"
    mode 00755
    action :create
    recursive true
end

# http://hhbd.pl.vmx/
web_app "000-#{node["hhbd-app"]["url"]}" do
    server_name "#{node["hhbd-app"]["url"]}"
    server_aliases ["www.#{node["hhbd-app"]["url"]}"]
    allow_override "All"
    docroot "#{node['apache']['docroot_dir']}/#{node["hhbd-app"]["url"]}/www/public"
    cookbook "apache2"
end

template "/etc/nginx/sites-available/hhbd.pl" do
    source "hhbd.pl.erb"
    mode "0644"
end

nginx_site 'hhbd.pl' do
    enable true
end
