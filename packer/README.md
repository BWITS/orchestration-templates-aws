## Packer templates for building aws Linux AMI image

## Usage

### Installing Packer

Download the latest packer from http://www.packer.io/downloads.html and unzip the appropriate directory.

### Running Packer

    $ git clone https://github.com/bwits/packer-templates-aws
    $ cd packer-templates-aws
    $ cd <LINUX_VERSION>
    $ packer build template.json

### Running packer behind corporate proxy server.

Packer uses GO's `crypto/ssh` package, which does not do anything with the OpenSSH config file. It also doesn't support `OpenSSH` config options like ProxyCommand etc.

But packer supports to run the build via external bastion server which has internet access directly. Here are step-by-step to run packer behind corporate proxy server.

1, set ~/.ssh/config to make sure you can login the bastion server without password.

Replace `proxy_server` with your corporate proxy server. 

```
$ cat ~/.ssh/config

Host ec2*
  ProxyCommand nc -X connect -x proxy_server:3128 %h %p
  User ubuntu
  IdentityFile ~/.ssh/ec2.pem

Host 5*
  ProxyCommand nc -X connect -x proxy_server:3128 %h %p
  User ubuntu
  IdentityFile ~/.ssh/ec2.pem
```

2, run the build command

    $ git clone https://github.com/bwits/packer-templates-aws
    $ cd packer-templates-aws
    $ cd <LINUX_VERSION>
    $ packer build \
    -var 'bastion_username=<YOUR_BASTION_USERNAME> \
    -var 'bastion_private_key=<FULL_PATH_OF_BASTION_PRIVATE_KEY> \
    template.bastion.json

