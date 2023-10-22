#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n${redColour}[!] Saliendo...${endColour}\n\n"
  tput cnorm
  exit 1
}

# Ctrl + C
trap ctrl_c INT


tput civis

echo -e "\n${greenColour}[+] Bienvenido al instalador automatico de servidores DHCP${endColour}"
echo -e "${purpleColour}Creador por: Azrael\n${endColour}"
echo -ne "\n\n${greenColour}[+] Primero, debemos configurar su ip fisica, que ip desearia tener?${endColour} " && read ip_fisica
echo -ne "${greenColour}[+] Que IP de puerta de enlace deberiamos usar?${endColour} " && read ip_router
echo -ne "${greenColour}[+] Porfavor, indique el servidor DNS:${endColour} " && read ip_dns

echo -e "\n\n${greenColour}[+]Muchas gracias, enseguida comenzará el proceso de configuracion de la IP${endColour}"

$(echo -e "network:
  ethernets:
    enp0s3:
      addresses:
      - ${ip_fisica}/24
      dhcp4: false
      routes:
      - to: default
        via: ${ip_router}
      nameservers:
        addresses:
        - ${ip_dns}
  version: 2
" > /etc/netplan/00-installer-config.yaml)

$(netplan apply)
echo -e "\n ${greenColour}[+] La configuración se ha establecido exitosamente, ahora procederemos a la instalación del servidor dhcp${endColour}"
$(apt install isc-dhcp-server -y 2>/dev/null)

echo -ne "${greenColour}[+] Desea hacer un segundo rango con tal de hacer una excepción de ip saltando esta pasando a la siguiente ip?\n Por ejemplo, primer rango 1-20 segundo 22-30 saltandonos la 21.\n Indique por favor con Y/N (debe de estar en mayusculas)${endColour} " && read exception_yn

if [ $exception_yn == "Y" ]; then

  echo -ne "${greenColour}[+] Porfavor, indique la ip de la red:${endColour} " && read ip_net
  echo -ne "${greenColour}[+] Porfavor, indique la mascara:${endColour} " && read mascara
  echo -ne "${greenColour}[+] Porfavor, indique la primera ip del primer rango:${endColour} " && read uno_rango
  echo -ne "${greenColour}[+] Porfavor, indique la ultima ip del primer rango:${endColour} " && read dos_rango
  echo -ne "${greenColour}[+] Porfavor, indique la primera ip del segundo rango:${endColour} " && read uno_rangodos
  echo -ne "${greenColour}[+] Porfavor, indique la ultima ip del segundo rango:${endColour} " && read dos_rangodos
  echo -ne "${greenColour}[+] Porfavor, indique la ip del broadcast:${endColour} " && read ip_broadcast
  echo -ne "${greenColour}[+] Porfavor, indique el nombre de dominio:${endColour} " && read domain_name
  echo -ne "${greenColour}[+] Porfavor, indique la cantidad de segundos que durara el lease time:${endColour} " && read lease_time

  echo -ne "${greenColour}[+] Desea resevar una ip para una MAC? indique con Y/N${endColour} " && read reserva_respuesta
    if [ $reserva_respuesta == "Y" ]; then
      echo -ne "${greenColour}[+] Porfavor, indique el nombre de la reserva:${endColour} " && read nombre_reserva
      echo -ne "${greenColour}[+] Porfavor, indique la ip que quiere resevar:${endColour} " && read ip_reservada
      echo -ne "${greenColour}[+] Porfavor, indique la dirección MAC separada por : de la maquina la cual va a ser reservada la ip${endColour}" && read mac_reservada
      echo -n "${greenColour}[+] Realizando la configuracion${endColour}"
      $(echo -e "# CONFIGURACION

subnet $ip_net netmask $mascara{
      range $uno_rango $dos_rango;
      range $uno_rangodos $dos_rangodos;
      option routers $ip_router;
      option subnet-mask $mascara;
      option broadcast-address $ip_broadcast;
      option domain-name-servers $ip_dns;
      option domain-name \"$domain_name\";
      default-lease-time $lease_time;

      host $nombre_reserva{
          hardware ethernet $mac_reservada;
          fixed-address $ip_reservada;
      }
  } " > /etc/dhcp/dhcpd.conf)
      echo -e "${greenColour}La configuración ha sido realizada con exito${endColour}"
    elif [ $reserva_respuesta == "N" ]; then
      echo -e "${greenColour}[+] Aplicando la configuracion${endColour}"
      $(echo -e "# CONFIGURACION

subnet $ip_net netmask $mascara{
      range $uno_rango $dos_rango;
      range $uno_rangodos $dos_rangodos;
      option routers $ip_router;
      option subnet-mask $mascara;
      option broadcast-address $ip_broadcast;
      option domain-name-servers $ip_dns;
      option domain-name \"$domain_name\";
      default-lease-time $lease_time;

  } " > /etc/dhcp/dhcpd.conf)      
    else
      echo -e "${redColour}[!] El input proporcionado no es valido${endColour}"
      tput cnorm
      exit 1
    fi

elif [ $exception_yn == "N" ]; then
  echo -ne "${greenColour}[+] Porfavor, indique la ip de la red:${endColour} " && read ip_net
  echo -ne "${greenColour}[+] Porfavor, indique la mascara:${endColour} " && read mascara
  echo -ne "${greenColour}[+] Porfavor, indique la primera ip del primer rango:${endColour} " && read uno_rango
  echo -ne "${greenColour}[+] Porfavor, indique la ultima ip del primer rango:${endColour} " && read dos_rango
  echo -ne "${greenColour}[+] Porfavor, indique la ip del broadcast:${endColour} " && read ip_broadcast
  echo -ne "${greenColour}[+] Porfavor, indique el nombre de dominio:${endColour} " && read domain_name
  echo -ne "${greenColour}[+] Porfavor, indique la cantidad de segundos que durara el lease time:${endColour} " && read lease_time

  echo -ne "${greenColour}[+] Desea resevar una ip para una MAC? indique con Y/N ${endColour}" && read reserva_respuesta
    if [ $reserva_respuesta == "Y" ]; then
      echo -ne "${greenColour}[+] Porfavor, indique el nombre de la reserva:${endColour} " && read nombre_reserva
      echo -ne "${greenColour}[+] Porfavor, indique la ip que quiere resevar:${endColour} " && read ip_reservada
      echo -ne "${greenColour}[+] Porfavor, indique la dirección MAC separada por : de la maquina la cual va a ser reservada la ip: ${endColour}" && read mac_reservada
      echo -n "${greenColour}[+] Realizando la configuracion${endColour}"
      $(echo -e "# CONFIGURACION

subnet $ip_net netmask $mascara{
      range $uno_rango $dos_rango;
      option routers $ip_router;
      option subnet-mask $mascara;
      option broadcast-address $ip_broadcast;
      option domain-name-servers $ip_dns;
      option domain-name \"$domain_name\";
      default-lease-time $lease_time;

      host $nombre_reserva{
          hardware ethernet $mac_reservada;
          fixed-address $ip_reservada;
      }
  } " > /etc/dhcp/dhcpd.conf)
      echo -e "${greenColour}La configuración ha sido realizada con exito${endColour}"
    elif [ $reserva_respuesta == "N" ]; then
      echo -e "${greenColour}[+] Aplicando la configuracion${endColour}"
      $(echo -e "# CONFIGURACION

subnet $ip_net netmask $mascara{
      range $uno_rango $dos_rango;
      option routers $ip_router;
      option subnet-mask $mascara;
      option broadcast-address $ip_broadcast;
      option domain-name-servers $ip_dns;
      option domain-name \"$domain_name\";
      default-lease-time $lease_time;

  } " > /etc/dhcp/dhcpd.conf)      
    else
      echo -e "${redColour}[!] El input proporcionado no es valido${endColour}"
      tput cnorm
      exit 1
    fi
else
  "${redColour}[!] El input proporcionado no es correcto, recuerde poner Y si es que si o N si es que no${endColour}"
  tput cnorm
  exit 1
fi

$(service isc-dhcp-server restart)

echo -e "${blueColour}[+] La configuración del servidor dhcp ha terminado, porfavor compruebe el status del servidor para verificar su exito${endColour}"

tput cnorm
exit 0



