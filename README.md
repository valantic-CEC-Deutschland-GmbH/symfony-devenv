# Valantic Hackathon - spring edition 23

![Hackathon](./hackathon.png)

## Task

Fiddle around with [devenv.sh](https://devenv.sh) and create a development environment for shopware 6 and symfony.  

## How to

1. Follow the [instructions](https://developer.shopware.com/docs/guides/installation/devenv#installation) to set up Nix, Cachix and Devenv.sh (skip any following instructions)
2. Continue with the installation of [direnv](https://developer.shopware.com/docs/guides/installation/devenv#direnv) and ignore the next section
3. Clone the repository `git clone https://github.com/nexusunited/symfony-devenv.git`
4. Go into the directory `cd symfony-devenv` and `direnv` will automatically load the environment / configurations
5. Start your environment with `devenv up` (it will start all services within the terminal in the foreground)
6. Open a new terminal and navigate into the project root dir
7. Choose between the installation of symfony or shopware 6 with the underlying commands

> If you have Nix, Cachix, Devenv.sh and Direnv already installed, you can directly follow the steps below  

### Create a new Symfony project 
```bash
# choose your desired version
❯ symfony new project --no-interaction # creates a symfony skeleton trough the symfony-cli
❯ symfony demo project --no-interaction # creates a symfony demo trough the symfony-cli
```

### Create new Shopware 6 project

### Full automated setup for development
```bash
❯ sw-dev # just type this command in the root dir
```

**The following steps are executed through the command**
```bash
❯ composer create-project shopware/production project --no-interaction \
&& cd ./project
&& composer req --dev dev-tools symfony/var-dumper symfony/web-profiler-bundle maltyxx/images-generator mbezhanov/faker-provider-collection frosh/development-helper frosh/tools
&& bin/console system:install --basic-setup
```

### Manual installation 
```bash
❯ composer create-project shopware/production project --no-interaction
```

## Access

Open `127.0.0.1:8000` and your dev-env is ready 🎉


## Delete current project for a new installation
```bash
❯ clean # just type this command in the root dir
```
