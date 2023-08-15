#!/usr/bin/env zsh

ip_host_info() {
  # Check if the input argument is provided
  if [ $# -eq 0 ]; then
    echo "No arguments provided"
    return 1
  fi

  IP_OR_HOST=$1

  # Extract the IP address from the input argument
  IP=$(echo $IP_OR_HOST | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")

  # Check if the IP address is valid
  if [ -z "$IP" ]; then
    # Resolve the IP if it's a hostname
    IP=$(dig +short $IP_OR_HOST)
    if [ -z "$IP" ]; then
      echo "Invalid IP address or hostname"
      return 1
    fi
  fi

  # Function to check if the port is open
  check_port() {
    nc -zv $IP_OR_HOST 22 &>/dev/null

    if [ $? -eq 0 ]; then
      echo "SSH Port Status: OPEN"
    else
      echo "SSH Port Status: CLOSED"
    fi
  }

  # Function to check DNS information
  check_dns() {
    dig $IP_OR_HOST ANY +noall +answer
  }

  # Function to guess the OS based on TTL
  guess_os() {
    local ttl=$(ping -c 1 $IP_OR_HOST | grep "ttl" | cut -d' ' -f6 | cut -d'=' -f2)

    if [[ -n "$ttl" ]]; then
      if ((ttl <= 64)); then
        echo "Guessed OS: Linux"
      elif ((ttl <= 128)); then
        echo "Guessed OS: Windows"
      else
        echo "Guessed OS: Solaris/AIX"
      fi
    else
      echo "Could not guess OS"
    fi
  }

  # Function to get SSH Server Version
  get_ssh_version() {
    local ssh_version=$(nc -w 1 $IP_OR_HOST 22 2>&1 | grep -o "SSH-[0-9.]*")
    echo "SSH Version: $ssh_version"
  }

  # Function to get SSH Configuration for the host
  get_ssh_config() {
    echo "SSH Configuration for $IP_OR_HOST:"
    for config in HostName User Port IdentityFile IdentitiesOnly PubkeyAuthentication PasswordAuthentication ChallengeResponseAuthentication UsePAM PermitRootLogin; do
      local config_value=$(ssh -TG $IP_OR_HOST | grep -i "^$config")
      echo "$config: $config_value"
    done
  }

  # Function to get geolocation information
  get_geolocation() {
    echo "Geolocation Information: $IP_OR_HOST"
    local geolocation=$(curl -s ipinfo.io/$IP)
    echo "Geolocation: $geolocation"
  }

  # Print the information
  echo "------------------------------------"
  echo "IP or Host: $IP_OR_HOST"
  echo "------------------------------------"
  echo "Network Information:"
  echo ""
  check_port
  guess_os
  echo "------------------------------------"
  echo "DNS Check:"
  check_dns
  echo "------------------------------------"
  echo "Geolocation Information:"
  echo ""
  get_geolocation
  echo "------------------------------------"
  echo "SSH Information:"
  echo ""
  get_ssh_version
  get_ssh_config
  echo "------------------------------------"
}

# Call the function
ip_host_info $1
