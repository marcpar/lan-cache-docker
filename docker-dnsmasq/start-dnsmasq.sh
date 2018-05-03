#!/bin/sh

get_ip() {
  interface=$(route | grep default | awk '{print $(NF)}')
  ip route show dev $interface | grep -Pom1 'link\s+src\s+\d+\.\d+\.\d+\.\d+' | awk -F " " '{print $NF}'
}

if [[ -z $HOST_IP ]]; then
  HOST_IP=$(get_ip)

  if [[ -n $HOST_IP ]]; then
    echo "Autodetected host IP as $HOST_IP"
    export HOST_IP=$HOST_IP
  else
    echo "Could not autodetect host IP. Exiting."
    exit 1
  fi
fi

# concatenate all dnsmasq confs into one file and replace the placeholder with the host IP address
cat /etc/dnsmasq.template.d/*.dnsmasq.conf | sed "s/NGINX_IP/$HOST_IP/" > /etc/dnsmasq.d/custom-zones.conf

exec dnsmasq --no-daemon
