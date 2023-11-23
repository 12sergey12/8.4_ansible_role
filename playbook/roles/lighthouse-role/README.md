lighthouse-role
=========

Предназначена для конфигурирования операционных систем под управлением SystemD

Роль выполняет:

1. установку nginx для использования в качестве веб-сервера
2. клонирование git-репозитория Lighthouse с исходным кодом
3. создание конфигурационного файла nginx для доступа к статическим ресурсам Lighthouse
4. запуск nginx

Requirements
------------

1. Ubuntu ОС
2. Предустановленная БД Clickhouse

Role Variables
--------------

```
lighthouse_home_dir: "/usr/share/nginx/html/lighthouse"
nginx_config_dir: "/etc/nginx"
```

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

```
- name: Install lighthouse
  hosts: lighthouse
  tags: lighthouse
  roles:
    - lighthouse-role
```

License
-------

BSD

Author Information
------------------

Baranov Sergey
