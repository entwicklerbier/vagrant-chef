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
