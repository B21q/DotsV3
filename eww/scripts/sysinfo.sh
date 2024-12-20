#!/bin/bash

get_username() {
  fullname=$(getent passwd "$(whoami)" | cut -d ':' -f 5 | cut -d ',' -f 1 | tr -d "\n")
  if [ -z "$fullname" ]; then
    username="$(whoami)"
  else
    username="${fullname%% *}"
  fi

  # Transforma todo o texto em maiúsculas
  username="${username^}"

  echo "@$username"
}

get_kernel_version() {
  echo "$(uname -r)"
}

get_mem() {
  used_gb=$(free -m | awk '/Mem/ { printf "%.2f", $3/1024 }')
  echo "${used_gb} GB"
}

get_operating_system() {
  echo "$(cat /etc/os-release | awk 'NR==1' | awk -F '"' '{print $2}')"
}

get_installed_packages() {
  echo "$(yay -Q | wc -l)"
}

get_window_manager() {
  echo "$XDG_CURRENT_DESKTOP"
}

get_uptime() {
  echo "$(uptime -p | sed -e 's/up //g')"
}

get_cpu() {
  # Usando mpstat com tratamento para vírgulas como separador decimal
  cpu_idle=$(mpstat 1 1 | awk '/Média|Average/ && /all/ {print $NF}' | tr ',' '.')
  
  # Verifica se a saída está vazia
  if [ -z "$cpu_idle" ]; then
    echo "Não foi possível calcular o uso da CPU."
    return 1
  fi

  # Converte para número inteiro
  cpu_usage=$(printf "%.0f" "$(echo "100 - $cpu_idle" | bc)")
  echo "${cpu_usage}%"
}

# Main function
main() {
  case "$1" in
    "--name")
      get_username
      ;;
    "--mem")
      get_mem
      ;;
    "--kernel")
      get_kernel_version
      ;;
    "--os")
      get_operating_system
      ;;
    "--pkgs")
      get_installed_packages
      ;;
    "--wm")
      get_window_manager
      ;;
    "--uptime")
      get_uptime
      ;;
    "--cpu")
      get_cpu
      ;;
    *)
      echo "Usage: $0 {--name|--kernel|--mem|--os|--pkgs|--wm|--uptime|--cpu}"
      exit 1
      ;;
  esac
}

# Call the main function with the provided arguments
main "$@"

