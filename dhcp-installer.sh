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
echo -ne "[+] Porfavor, indique el servidor DNS " && read ip_dns

echo -e "\n\n[+]Muchas gracias, enseguida comenzará el proceso de configuracion de la IP"

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
echo -e "\n [+] La configuración se ha establecido exitosamente, ahora procederemos a la instalación del servidor dhcp"
$(apt install isc-dhcp-server -y 2>/dev/null)

echo -ne "[+] Desea hacer un segundo rango con tal de hacer una excepción de ip saltando esta pasando a la siguiente ip?\n Por ejemplo, primer rango 1-20 segundo 22-30 saltandonos la 21.\n Indique por favor con Y/N (debe de estar en mayusculas) " && read exception_yn

if [ $exception_yn == "Y" ]; then

  echo -ne "[+] Porfavor, indique la ip de la red: " && read ip_net
  echo -ne "[+] Porfavor, indique la mascara: " && read mascara
  echo -ne "[+] Porfavor, indique la primera ip del primer rango: " && read uno_rango
  echo -ne "[+] Porfavor, indique la ultima ip del primer rango: " && read dos_rango
  echo -ne "[+] Porfavor, indique la primera ip del segundo rango: " && read uno_rangodos
  echo -ne "[+] Porfavor, indique la ultima ip del segundo rango: " && read dos_rangodos
  echo -ne "[+] Porfavor, indique la ip del broadcast: " && read ip_broadcast
  echo -ne "[+] Porfavor, indique el nombre de dominio: " && read domain_name
  echo -ne "[+] Porfavor, indique la cantidad de segundos que durara el lease time: " && read lease_time

  echo -ne "[+] Desea resevar una ip para una MAC? indique con Y/N " && read reserva_respuesta
    if [ $reserva_respuesta == "Y" ]; then
      echo -ne "[+] Porfavor, indique el nombre de la reserva: " && read nombre_reserva
      echo -ne "[+] Porfavor, indique la ip que quiere resevar: " && read ip_reservada
      echo -ne "[+] Porfavor, indique la dirección MAC separada por : de la maquina la cual va a ser reservada la ip" && read mac_reservada
      echo -n "[+] Realizando la configuracion"
      $(echo -e "# CONFIGURACION

subnet $ip_net $mascara{
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
      echo -e "La configuración ha sido realizada con exito"
    elif [ $reserva_respuesta == "N" ]; then
      echo -e "[+] Aplicando la configuracion"
      $(echo -e "# CONFIGURACION

subnet $ip_net $mascara{
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
      echo -e "[!] El input proporcionado no es valido"
      tput cnorm
      exit 1
    fi

elif [ $exception_yn == "N" ]; then
  echo -ne "[+] Porfavor, indique la ip de la red: " && read ip_net
  echo -ne "[+] Porfavor, indique la mascara: " && read mascara
  echo -ne "[+] Porfavor, indique la primera ip del primer rango: " && read uno_rango
  echo -ne "[+] Porfavor, indique la ultima ip del primer rango: " && read dos_rango
  echo -ne "[+] Porfavor, indique la ip del broadcast: " && read ip_broadcast
  echo -ne "[+] Porfavor, indique el nombre de dominio: " && read domain_name
  echo -ne "[+] Porfavor, indique la cantidad de segundos que durara el lease time: " && read lease_time

  echo -ne "[+] Desea resevar una ip para una MAC? indique con Y/N " && read reserva_respuesta
    if [ $reserva_respuesta == "Y" ]; then
      echo -ne "[+] Porfavor, indique el nombre de la reserva: " && read nombre_reserva
      echo -ne "[+] Porfavor, indique la ip que quiere resevar: " && read ip_reservada
      echo -ne "[+] Porfavor, indique la dirección MAC separada por : de la maquina la cual va a ser reservada la ip" && read mac_reservada
      echo -n "[+] Realizando la configuracion"
      $(echo -e "# CONFIGURACION

subnet $ip_net $mascara{
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
      echo -e "La configuración ha sido realizada con exito"
    elif [ $reserva_respuesta == "N" ]; then
      echo -e "[+] Aplicando la configuracion"
      $(echo -e "# CONFIGURACION

subnet $ip_net $mascara{
      range $uno_rango $dos_rango;
      option routers $ip_router;
      option subnet-mask $mascara;
      option broadcast-address $ip_broadcast;
      option domain-name-servers $ip_dns;
      option domain-name \"$domain_name\";
      default-lease-time $lease_time;

  } " > /etc/dhcp/dhcpd.conf)      
    else
      echo -e "[!] El input proporcionado no es valido"
      tput cnorm
      exit 1
    fi
else
  "[!] El input proporcionado no es correcto, recuerde poner Y si es que si o N si es que no"
  tput cnorm
  exit 1
fi

$(service isc-dhcp-server restart)

echo -e "[+] La configuración del servidor dhcp ha terminado, porfavor compruebe el status del servidor para verificar su exito"

tput cnorm
exit 0



