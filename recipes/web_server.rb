include_recipe 'nginx'

nginx_site 'default' do
  enable false
end

%w[ /var/www /var/www/salad ].each do |path|
  directory path do
    action :create
  end
end

template '/var/www/salad/index.html' do
  source 'index.html.erb'
end

template "#{node['nginx']['dir']}/sites-available/salad" do
  source 'nginx_site.erb'
end

%w[ /etc/ssl /etc/ssl/certs /etc/ssl/private ].each do |path|
  directory path do
    action :create
  end
end

cookbook_file 'salad.entwicklerbier.org.crt' do
  path '/etc/ssl/certs/salad.entwicklerbier.org.crt'
end

cookbook_file 'salad.entwicklerbier.org.key' do
  path '/etc/ssl/private/salad.entwicklerbier.org.key'
end

nginx_site 'salad' do
  enable true
end

service 'nginx' do
  action :restart
end
