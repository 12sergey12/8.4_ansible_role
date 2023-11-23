resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/hosts.tftpl",
    {
      webservers = [for i in yandex_compute_instance.logs_stack : i],
      user       = local.vm_metadata.ssh-user
    }
  )

  filename = "${abspath(path.module)}/../playbook/inventory/prod.yml"
}

