vagrant-chef
============

A simple tutorial in using Vagrant and Chef for development and production

## Requirements:

### Chef
https://www.getchef.com/download-chef-client/
```
curl -L https://www.opscode.com/chef/install.sh | bash
```

### knife solo
https://github.com/matschaffer/knife-solo#usage
```
gem install knife-solo
```

### Berkshelf
https://github.com/berkshelf/berkshelf#installation
```
gem install berkshelf
```

### Vagrant
https://docs.vagrantup.com/v2/installation/

### vagrant-omnibus
https://github.com/opscode/vagrant-omnibus
```
vagrant plugin install vagrant-omnibus
```

### vagrant-berkshelf
https://github.com/berkshelf/vagrant-berkshelf
```
vagrant plugin install vagrant-berkshelf --plugin-version 2.0.1
```

## Vagrant

Init a new Vagrant machine with Ubuntu 14.04 64bit:
```
vagrant init ubuntu/trusty64
```

## Berskfile

Create a Berksfile and a corresponding metadata.rb.
These are needed for adding others recipes.

## Create our first recipe

Add a folder named recipes and insert a default.rb
This file contains the definition of our cookbook in the comment section
```
#
# Cookbook Name:: salad
# Recipe:: default
#
```

Add Cookbook definition to metadata.rb
```
name             'salad'
maintainer       'Markus Klepp'
maintainer_email 'khor@entwicklerbier.org'
license          'The MIT License (MIT)'
description      'Installs/Configures salad'
long_description 'Installs/Configures salad'
version          '0.1.0'
```

## Link recipe with Vagrant

Enable omnibus installer in Vagrantfile:
```
config.omnibus.chef_version = '11.16'
```

Enable Berkshelf in Vagrantfile:
```
config.berkshelf.enabled = true
```

Define our recipe to run when VM gets provisioned
```
config.vm.provision :chef_solo do |chef|
    chef.json = {
    }

    chef.run_list = [
        "recipe[salad::default]"
    ]
  end
```

## First boot of Vagrant machine
```
vagrant up
```

## Add nginx to our cookbook

To install nginx, we use the nginx recipe from https://github.com/miketheman/nginx.
Add nginx dependency to metadata.rb  
```
depends 'nginx', '~> 2.7.4'
```

Create a new recipe named recipes/web_server.rb that includes the nginx recipe. It will also contain our basic configuration for the web server.
```
include_recipe 'nginx'
```

Add webserver recipe to our default recipe.
```
include_recipe 'web_server'
```

To cook our cookbook (in this case install nginx in its default state) just type:
```
vagrant provision
```

To access the now running nginx on http://localhost:8080 we need to forward the clients port 80 to the hosts port 8080 in our Vagrantfile.
```
config.vm.network "forwarded_port", guest: 80, host: 8080

```
To reload the Vagrantfile type:
```
vagrant reload
```

## Create our own nginx site

Disable default nginx site in web_server.rb:
```
nginx_site 'default' do
  enable false
end
```

Create index.html.erb and nginx_site.erb in templates/default

Add lines to web_server.rb:
```
directory '/var/www/salad' do
  action :create
end

template '/var/www/salad/index.html' do
  source 'index.html.erb'
end

template "#{node['nginx']['dir']}/sites-available/salad" do
  source 'nginx_site.erb'
end

nginx_site 'salad' do
  enable true
end
```

After cooking we can visit our new nginx site on localhost:8080
```
vagrant provision
```

## Upload to production server

You need a running VPS at the provider of your choice. I prepared a server under salad.entwicklerbier.org.
To bootstrap Chef and install our recipe, we need the following command:

```
knife solo bootstrap root@salad.entwicklerbier.org
```

This command will install our cookbook, but does not run anything. To run the default recipe we need to set the content of nodes/salad.entwicklerbier.org to:
```
{
  "run_list": [
    "recipe[salad::default]"
  ]
}
```

To cook the cookbook on our node type:
```
knife solo cook root@salad.entwicklerbier.org
```

An error should be displayed, because of the order of the commands in the web_server recipe. We enable the salad site before it is defined. So lets move the nginx_site definition to the end of the file.
Another run of the cook command will finish and make our site available under http://salad.entwicklerbier.org.

## Different configuration for development and production

Say we want to enable a more verbose debug log on the development machine.
We need to supply default value in attributes/default.rb
```
default['web_server']['debug_log'] = false

```

In our Vagrantfile add the debug_log=true config to the Chef config:
```
web_server: {
  debug_log: true
}
```

And alter our nginx_site.erb to use the advanced log:
```
error_log /var/log/nginx/error.log <%= 'debug' if node['web_server']['debug_log'] %>;
```

We can now provision our vagrant machine and cook on our node to apply these changes.

## Deploying SSL-Certificates

Adapt your nginx-config to load the ssl certs.

You should really not put your unencrypted key files in a public repo.
There are a couple of new steps in the webserver recipe to copy the certificate chain/key in position.

Provision and ssl :)
