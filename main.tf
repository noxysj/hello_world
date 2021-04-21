terraform {
  required_providers {
    docker = {
      source = "terraform-providers/docker"
    }
  }
}

provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_network" "private_network" {
  name = "my_docker_network"

}

resource "docker_image" "php" {
  name         = "php:7-fpm"
  keep_locally = false
}

resource "docker_container" "php" {
  name    = "tutorial_php"
  restart = "always"
  image   = docker_image.php.latest
  networks_advanced {
    name = "my_docker_network"
  }
  volumes {
    host_path      = "/E/Documents/Data/Git/hello_world/code"
    container_path = "/code"
  }
}
resource "docker_container" "nginx" {
  image   = docker_image.nginx.latest
  name    = "tutorial_nginx"
  restart = "always"
  networks_advanced {
    name = "my_docker_network"
  }
  ports {
    internal = 80
    external = 8000
  }
  upload {
    source      = "site.conf"
    source_hash = filebase64("${path.module}/site.conf")
    file        = "/etc/nginx/conf.d/default.conf"
  }
  volumes {
    host_path      = "/E/Documents/Data/Git/hello_world/code"
    container_path = "/code"
  }
}

output "instance_ip_addr" {
  value = lookup(docker_container.nginx.network_data[0], "ip_address")
}
output "instance_host_name" {
  value = lookup(docker_container.php.network_data[0], "ip_address")
}