include_recipe 'nginx'

nginx_site 'default' do
  enable false
end

nginx_site 'salad' do
  enable true
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
