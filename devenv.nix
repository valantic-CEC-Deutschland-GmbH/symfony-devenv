{ pkgs, lib, config, ... }:

{
  packages = [
    pkgs.jq
    pkgs.gnupatch
    pkgs.yarn
    pkgs.symfony-cli
    (pkgs.php82Packages.composer.overrideAttrs (old: {
          version = "2.4.4";
          src = pkgs.fetchurl {
            url = "https://getcomposer.org/download/${"2.4.4"}/composer.phar";
            sha256 = "wlLCoiGZVviAif/CQrQsjLkwCjaP04kNY5QOT8llI0U=";
          };
        }))
  ];

  languages.javascript = {
    enable = lib.mkDefault true;
    package = lib.mkDefault pkgs.nodejs-18_x;
  };

  languages.php = {
    enable = lib.mkDefault true;
    version = lib.mkDefault "8.2";
    extensions = [ "xdebug" ];

    ini = ''
      xdebug.mode = debug
      xdebug.discover_client_host = 1
      xdebug.client_host = 127.0.0.1
      memory_limit = 2G
      realpath_cache_ttl = 3600
      session.gc_probability = 0
      ${lib.optionalString config.services.redis.enable ''
      session.save_handler = redis
      session.save_path = "tcp://127.0.0.1:6379/0"
      ''}
      display_errors = On
      error_reporting = E_ALL
      assert.active = 0
      opcache.memory_consumption = 256M
      opcache.interned_strings_buffer = 20
      zend.assertions = 0
      short_open_tag = 0
      zend.detect_unicode = 0
      realpath_cache_ttl = 3600
    '';

    fpm.pools.web = lib.mkDefault {
      settings = {
        "clear_env" = "no";
        "pm" = "dynamic";
        "pm.max_children" = 10;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 10;
      };
    };
  };

  services.caddy = {
    enable = lib.mkDefault true;

    virtualHosts.":8000" = lib.mkDefault {
      extraConfig = ''
        root * project/public
        php_fastcgi unix/${config.languages.php.fpm.pools.web.socket}
        encode zstd gzip
        file_server
        log {
          output stderr
          format console
          level ERROR
        }
      '';
    };
  };

  services.mysql = {
    enable = true;
    package = pkgs.mysql80;
    initialDatabases = lib.mkDefault [{ name = "symfony"; }];
    ensureUsers = lib.mkDefault [
      {
        name = "symfony";
        password = "symfony";
        ensurePermissions = {
          "symfony.*" = "ALL PRIVILEGES";
          "symfony_test.*" = "ALL PRIVILEGES";
        };
      }
    ];
    settings = {
      mysqld = {
        log_bin_trust_function_creators = 1;
      };
    };
  };

  services.redis.enable = lib.mkDefault true;
  services.mailhog.enable = lib.mkDefault true;

  #services.rabbitmq.enable = true;
  #services.rabbitmq.managementPlugin.enable = true;
  #services.elasticsearch.enable = true;

  # Environment variables
  env.MAILER_DSN = lib.mkDefault "smtp://localhost:1025";
  env.DATABASE_URL = lib.mkDefault "mysql://symfony:symfony@localhost:3306/symfony";

  # Shopware 6 related scripts
  scripts.build-js.exec = lib.mkDefault "./project/bin/build-js.sh";
  scripts.build-storefront.exec = lib.mkDefault "./project/bin/build-storefront.sh";
  scripts.watch-storefront.exec = lib.mkDefault "./project/bin/watch-storefront.sh";
  scripts.build-administration.exec = lib.mkDefault "./project/bin/build-administration.sh";
  scripts.watch-administration.exec = lib.mkDefault "./project/bin/watch-administration.sh";
  scripts.theme-refresh.exec = lib.mkDefault "./project/bin/console theme-refresh";
  scripts.theme-compile.exec = lib.mkDefault "./project/bin/console theme-compile";

  # Symfony related scripts
  scripts.cc.exec = lib.mkDefault "./project/bin/console cache:clear";
  scripts.sw-dev.exec = ''
       composer create-project shopware/production project
       cd ./project
       composer req --dev dev-tools symfony/var-dumper symfony/web-profiler-bundle maltyxx/images-generator mbezhanov/faker-provider-collection frosh/development-helper frosh/tools
       bin/console system:install --basic-setup
      '';
}
