output "vm_external_ip_address" {
  value = [
    for vm in yandex_compute_instance.logs_stack : {"host" = vm.name, "ip" = vm.network_interface[0].nat_ip_address}
  ]
  description = "external ip"
}

