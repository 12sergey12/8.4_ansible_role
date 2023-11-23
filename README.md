 Баранов Сергей.
### Домашнее задание к занятию 4 «Работа с roles» Баранов Сергей.

### Подготовка к выполнению

1. * Необязательно. Познакомьтесь с [LightHouse](https://youtu.be/ymlrNlaHzIY?t=929).
2. Создайте два пустых публичных репозитория в любом своём проекте: vector-role и lighthouse-role.
3. Добавьте публичную часть своего ключа к своему профилю на GitHub.

### Основная часть

Ваша цель — разбить ваш playbook на отдельные roles. 

Задача — сделать roles для ClickHouse, Vector и LightHouse и написать playbook для использования этих ролей. 

Ожидаемый результат — существуют три ваших репозитория: два с roles и один с playbook.

**Что нужно сделать**

1. Создайте в старой версии playbook файл `requirements.yml` и заполните его содержимым:

   ```yaml
   ---
     - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
       scm: git
       version: "1.13"
       name: clickhouse 
   ```
[requirements.yml](https://github.com/12sergey12/8.4_ansible_role/blob/main/playbook/requirements.yml)

2. При помощи `ansible-galaxy` скачайте себе эту роль.

```
root@baranovsa:/home/baranovsa/8.4_foles/playbook/roles# ansible-galaxy role install -p roles -r requ>
Starting galaxy role install process
- extracting clickhouse to /ansible/08-ansible-04-role/playbook/roles/clickhouse
- clickhouse (1.11.0) was installed successfully
```

[clickhouse](https://github.com/12sergey12/8.4_ansible_role/tree/main/playbook/roles/clickhouse)

3. Создайте новый каталог с ролью при помощи `ansible-galaxy role init vector-role`.

```
root@baranovsa:/home/baranovsa/8.4_foles/playbook/roles# ansible-galaxy role init vector-role
- Role vector-role was created successfully
```

```
root@baranovsa:/home/baranovsa/8.4_foles/playbook/roles# ansible-galaxy role init lightHouse-role
- Role vector-role was created successfully
```

4. На основе tasks из старого playbook заполните новую role. Разнесите переменные между `vars` и `default`. 

5. Перенести нужные шаблоны конфигов в `templates`.

6. Опишите в `README.md` обе роли и их параметры. Пример качественной документации ansible role [по ссылке](https://github.com/cloudalchemy/ansible-prometheus).

```
Vector-role
=========

Предназначена для установки на операционные системы под управлением SystemD сервиса Vector и базовое конфигурирование отслеживания изменения LOG файлов с отправкой изменений в Clickhouse

Requirements
------------

1. Ubuntu ОС
2. Предустановленная БД Clickhouse.

Role Variables
--------------

vector_version - Версия используемого ПО Vector. По умолчанию 0.34.1-1

```
vector_config:
  sources:
    logs_logs:
      type: demo_logs
      format: syslog
      interval: 1
  transforms:
    parse_logs:
      inputs:
        - logs_logs
      source: |-
        . = parse_syslog!(string!(.message))
        .timestamp = to_string(.timestamp)
        .timestamp = slice!(.timestamp, start:0, end: -1)
      type: remap
  sinks:
    to_clickhouse:
      type: clickhouse
      inputs:
        - parse_logs
      database: vector_logs
      endpoint: "http://178.154.204.25:8123"
      table: logs_logs
      compression: gzip
  api:
    enabled: true
    address: "0.0.0.0:8686"
```

Dependencies
------------

Для установки Clickhouse требуется роль ansible-clickhouse: https://github.com/AlexeySetevoi/ansible-clickhouse

Example Playbook
----------------

Пример добавление роли в playbook:

```
- name: Install Vector
  tags: [vector]
  hosts: vector
  roles:
    - vector-role
```

License
-------

BSD

Author Information
------------------

Baranov Sergey
```

```
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
```

7. Повторите шаги 3–6 для LightHouse. Помните, что одна роль должна настраивать один продукт.

8. Выложите все roles в репозитории. Проставьте теги, используя семантическую нумерацию. Добавьте roles в `requirements.yml` в playbook.

```
---
  - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
    scm: git
    version: "1.11.0"
    name: clickhouse

  - src: git@github.com:12sergey12/lighthouse-role.git
    scm: git
    version: "1.0.0"
    name: lighthouse

  - src: git@github.com:12sergey12/vector-role.git
    scm: git
    version: "1.0.0"
    name: vector
```
[vector-role](https://github.com/12sergey12/vector-role)

[lighthouse-role](https://github.com/12sergey12/lighthouse-role)

9. Переработайте playbook на использование roles. Не забудьте про зависимости LightHouse и возможности совмещения `roles` с `tasks`.

[site.yml](https://github.com/12sergey12/8.4_ansible_role/blob/main/playbook/site.yml)

<details><summary>Применение конфигурирования сервисов</summary>

```
root@baranovsa:/home/baranovsa/8.4_foles/playbook# ansible-playbook -i ./inventory/prod.yml site.yml

PLAY [Ping] *********************************************************************************************

TASK [Gathering Facts] **********************************************************************************
ok: [clickhouse-01]
ok: [vector-01]
ok: [lighthouse-01]

TASK [Check availability servers] ***********************************************************************
ok: [clickhouse-01]
ok: [vector-01]
ok: [lighthouse-01]

PLAY [Install Vector] ***********************************************************************************

TASK [Gathering Facts] **********************************************************************************
ok: [vector-01]

TASK [vector-role : Get vector distrib] *****************************************************************
ok: [vector-01]

TASK [vector-role : Install vector package] *************************************************************
ok: [vector-01]

TASK [vector-role : Redefine vector config name] ********************************************************
ok: [vector-01]

TASK [vector-role : Create vector config] ***************************************************************
ok: [vector-01]

PLAY [Install lighthouse] *******************************************************************************

TASK [Gathering Facts] **********************************************************************************
ok: [lighthouse-01]

TASK [lighthouse-role : add repo nginx] *****************************************************************
changed: [lighthouse-01]

TASK [lighthouse-role : install nginx and git] **********************************************************
changed: [lighthouse-01]

TASK [lighthouse-role : Get lighthouse from git] ********************************************************
changed: [lighthouse-01]

TASK [lighthouse-role : Configure nginx from template] **************************************************
changed: [lighthouse-01]

RUNNING HANDLER [lighthouse-role : restarted nginx service] *********************************************
changed: [lighthouse-01]

PLAY [Install Clickhouse] *******************************************************************************

TASK [Gathering Facts] **********************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ***************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] ***************************************************************************
changed: [clickhouse-01]

TASK [Install clickhouse packages] **********************************************************************
changed: [clickhouse-01]

TASK [Enable remote connections to clickhouse server] ***************************************************
changed: [clickhouse-01]

RUNNING HANDLER [Start clickhouse service] **************************************************************
changed: [clickhouse-01]

TASK [Create database] **********************************************************************************
changed: [clickhouse-01]

TASK [Create table] *************************************************************************************
changed: [clickhouse-01]

PLAY [Install Clickhouse] *******************************************************************************

TASK [Gathering Facts] **********************************************************************************
ok: [clickhouse-01]

TASK [clickhouse : Include OS Family Specific Variables] ************************************************
ok: [clickhouse-01]

TASK [clickhouse : include_tasks] ***********************************************************************
included: /home/baranovsa/8.4_foles/playbook/roles/clickhouse/tasks/precheck.yml for clickhouse-01

TASK [clickhouse : Requirements check | Checking sse4_2 support] ****************************************
ok: [clickhouse-01]

TASK [clickhouse : Requirements check | Not supported distribution && release] **************************
skipping: [clickhouse-01]

TASK [clickhouse : include_tasks] ***********************************************************************
included: /home/baranovsa/8.4_foles/playbook/roles/clickhouse/tasks/params.yml for clickhouse-01

TASK [clickhouse : Set clickhouse_service_enable] *******************************************************
ok: [clickhouse-01]

TASK [clickhouse : Set clickhouse_service_ensure] *******************************************************
ok: [clickhouse-01]

TASK [clickhouse : include_tasks] ***********************************************************************
included: /home/baranovsa/8.4_foles/playbook/roles/clickhouse/tasks/install/yum.yml for clickhouse-01

TASK [clickhouse : Install by YUM | Ensure clickhouse repo GPG key imported] ****************************
changed: [clickhouse-01]

TASK [clickhouse : Install by YUM | Ensure clickhouse repo installed] ***********************************
changed: [clickhouse-01]

TASK [clickhouse : Install by YUM | Ensure clickhouse package installed (latest)] ***********************
skipping: [clickhouse-01]

TASK [clickhouse : include_tasks] ***********************************************************************
included: /home/baranovsa/8.4_foles/playbook/roles/clickhouse/tasks/configure/sys.yml for clickhouse-01

TASK [clickhouse : Check clickhouse config, data and logs] **********************************************
ok: [clickhouse-01] => (item=/var/log/clickhouse-server)
changed: [clickhouse-01] => (item=/etc/clickhouse-server)
changed: [clickhouse-01] => (item=/var/lib/clickhouse/tmp/)
changed: [clickhouse-01] => (item=/var/lib/clickhouse/)

TASK [clickhouse : Config | Create config.d folder] *****************************************************
changed: [clickhouse-01]

TASK [clickhouse : Config | Create users.d folder] ******************************************************
changed: [clickhouse-01]

TASK [clickhouse : Config | Generate system config] *****************************************************
changed: [clickhouse-01]

TASK [clickhouse : Config | Generate users config] ******************************************************
changed: [clickhouse-01]

TASK [clickhouse : Config | Generate remote_servers config] *********************************************
skipping: [clickhouse-01]

TASK [clickhouse : Config | Generate macros config] *****************************************************
skipping: [clickhouse-01]

TASK [clickhouse : Config | Generate zookeeper servers config] ******************************************
skipping: [clickhouse-01]

TASK [clickhouse : Config | Fix interserver_http_port and intersever_https_port collision] **************
skipping: [clickhouse-01]

RUNNING HANDLER [clickhouse : Restart Clickhouse Service] ***********************************************
ok: [clickhouse-01]

TASK [clickhouse : include_tasks] ***********************************************************************
included: /home/baranovsa/8.4_foles/playbook/roles/clickhouse/tasks/service.yml for clickhouse-01

TASK [clickhouse : Ensure clickhouse-server.service is enabled: True and state: restarted] **************
changed: [clickhouse-01]

TASK [clickhouse : Wait for Clickhouse Server to Become Ready] ******************************************
ok: [clickhouse-01]

TASK [clickhouse : include_tasks] ***********************************************************************
included: /home/baranovsa/8.4_foles/playbook/roles/clickhouse/tasks/configure/db.yml for clickhouse-01

TASK [clickhouse : Set ClickHose Connection String] *****************************************************
ok: [clickhouse-01]

TASK [clickhouse : Gather list of existing databases] ***************************************************
ok: [clickhouse-01]

TASK [clickhouse : Config | Delete database config] *****************************************************

TASK [clickhouse : Config | Create database config] *****************************************************

TASK [clickhouse : include_tasks] ***********************************************************************
included: /home/baranovsa/8.4_foles/playbook/roles/clickhouse/tasks/configure/dict.yml for clickhouse-01

TASK [clickhouse : Config | Generate dictionary config] *************************************************
skipping: [clickhouse-01]

TASK [clickhouse : include_tasks] ***********************************************************************
skipping: [clickhouse-01]

PLAY RECAP **********************************************************************************************
clickhouse-01              : ok=33   changed=14   unreachable=0    failed=0    skipped=10   rescued=1    ignored=0   
lighthouse-01              : ok=8    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=7    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

root@baranovsa:/home/baranovsa/8.4_foles/playbook# 

```

</details>

10. Выложите playbook в репозиторий.

11. В ответе дайте ссылки на оба репозитория с roles и одну ссылку на репозиторий с playbook.

---

[vector-role](https://github.com/12sergey12/vector-role)

[lighthouse-role](https://github.com/12sergey12/lighthouse-role)

[playbook](https://github.com/12sergey12/8.4_ansible_role/tree/main/playbook)

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---

