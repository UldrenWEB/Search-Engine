#!/bin/bash

#Colours
endColour="\033[0m\e[0m"
green="\e[0;32m\033[1m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

main_url="https://htbmachines.github.io/bundle.js"
main_file="recurso.js"
file_temp="recurso_temp.js"

function ctrl_c(){
  echo -e "\n${red}[!] Saliendo...\n${endColour}"
  tput cnorm;exit 1
}

# Ctrl+C
trap ctrl_c INT

function helpPanel(){
  echo -e "\n${yellow}[+]${endColour} ${gray}USO:${endColour}"
  echo -e "\t${purple}u)${endColour} ${gray}Descargar o actualizar archivo necesarios${endColour}"
  echo -e "\t${purple}h)${endColour} ${gray}Desplegar panel de Ayuda${endColour}"
  echo -e "\t${purple}m)${endColour} ${gray}Buscar por el nombre de la maquina${endColour}"
  echo -e "\t${purple}i)${endColour} ${gray}Buscar por el IP de la maquina${endColour}"
  echo -e "\t${purple}y)${endColour} ${gray}Buscar por el nombre de la maquina el enlace con la resolucion${endColour}"
  echo -e "\t${purple}o)${endColour} ${gray}Buscar todas las maquinas por el tipo de sistema operativo${endColour}"
  echo -e "\t${purple}a)${endColour} ${gray}Buscar todas las maquinas de Directorio Activo${endColour}"
  echo -e "\t${purple}s)${endColour} ${gray}Buscar por Skill${endColour}"
  echo -e "\t${purple}d)${endColour} ${gray}Obtener todas las maquinas por su dificultad${endColour}"
}

function updateData(){
  
  if [ ! -f $main_file ]; then   
    tput civis
    echo -e "\n${yellow}[+]${endColour}${gray} Descargando archivos necesarios...${endColour}\n"
    
    curl -s https://htbmachines.github.io/bundle.js > $main_file
    js-beautify $main_file | sponge $main_file  

    echo -e "\n${yellow}[-]${endColour} ${gray} Se han descargado todos los archivo correctamente${endColour}\n"
    tput cnorm
  else
    tput civis
    echo -e "\n${yellow}[+]${endColour} ${gray}Buscando nuevas actualizaciones...${endColour}\n"
    
    curl -s https://htbmachines.github.io/bundle.js > $file_temp 
    js-beautify $file_temp | sponge $file_temp  
    
    hash_main_file=$(md5sum $main_file | awk '{print $1}')
    hash_temp_file=$(md5sum $file_temp | awk '{print $1}')

    #echo $hash_main_file
    #echo $hash_temp_file

    if [ $hash_main_file != $hash_temp_file ]; then
      echo -e "\n${yellow}[+]${endColour}${gray} Se encontraron nuevas actualizaciones${endColour}"
      sleep 1,5

      echo -e "\n${yellow}[+]${endColour} ${gray}Se ha actualizado correctamente...${endColour}\n"
      rm $main_file && mv $file_temp $main_file
    else
      rm $file_temp
      echo -e "\n${yellow}[+]${endColour} ${gray}No hay actualizaciones pendientes${endColour}"
    fi
    tput cnorm
  fi
}

function searchMachine(){
  machineName="$1"
  
  if [ ! -f $main_file ]; then
    updateData
  fi
  
  data_checker=$(cat $main_file | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | sed "s/^ *//" | tr -d ',' | tr -d '"')

  if [ "$data_checker" ]; then
    echo -e "\n${yellow}[+]${endColour} ${gray}Listando las propiedades de la maquina${endColour}${blue} $machineName ${endColour}\n"

    cat $main_file | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | sed "s/^ *//" | tr -d ',' | tr -d '"'
    echo ''
  else
    echo -e "\n${red}[!] La maquina proporcionada no existe${endColour}\n"
  fi
}

function searchIP(){
  ipAddress=$1
  
  machineName=$(cat $main_file | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | sed "s/^ *//" | awk '{print $NF}' | tr -d '"' | tr -d ',')
 
  if [ "$machineName" ]; then
    
    echo -e "\n${yellow}[+]${endColour}${gray} La maquina correspondiente para la IP${endColour}${red} $ipAddress${endColour} ${gray}es${endColour}${blue} $machineName${endColour}" 
  
    sleep 1,3
    searchMachine $machineName

  else
    echo -e "\n${red}[!] La direccion IP proporcionada no existe${endColour}\n"
  fi
}

function getYoutubeLink(){
  machineName="$1"
  
  youtubeLink=$(cat $main_file | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | sed "s/^ *//" | tr -d ',' | tr -d '"' | grep "youtube:" | awk '{print $NF}')
  
  if [ "$youtubeLink" ]; then
    echo -e "\n${yellow}[+]${endColour} ${gray}El enlace con la solucion de la maquina es:${endColour} ${blue}$youtubeLink${endColour}\n"
  else
    echo -e "\n${red}[!] La maquina proporcionada no existe${endColour}\n"
  fi
}

function searchMachineByDificulty(){
  dificulty=$1
  
  all_machines=$(cat $main_file | grep "dificultad: \"$dificulty\"" -B 5 | grep "name" | awk '{print $NF}' | tr -d '"' | tr -d ',' | column)
  
  if [ "$all_machines" ]; then
    echo -e "\n${yellow}[+]${endColour}${gray} Listando todas las maquinas con dificultad${endColour} ${red}$dificulty${endColour}\n"
    
    sleep 1,2
    echo -e "${blue} $all_machines ${endColour}"
  else
    echo -e "\n${red}[!] La dificultad proporcionada no existe\n ${yellow}[+]${endColour}${gray} Las dificultades validas son:${endColour}\n - ${turquoise}Fácil\n - Media\n - Difícil\n - Insane${endColour}${endColour}\n"
  fi
}

function getOSMachine(){
  OS="$1"

  all_machine=$(cat $main_file | grep "so: \"$OS\"" -B 4 | grep "name:" | awk '{print $NF}' | tr -d '"' | tr -d ',' | column)

  if [ "$all_machine" ]; then
    echo -e "\n${yellow}[+]${endColour}${gray} Listando las maquinas con el sistema operativo${endColour}${red} $OS ${endColour}\n"
    
    sleep 1,2
    echo -e "${blue}$all_machine ${endColour}"
  else
    echo -e "\n${red}[!] El sistema operativo proporcionado no existe${endColour}\n"
  fi
}

function getMachineByDifAndOs(){
  OS=$1
  difficulty=$2

  result_checker=$(cat recurso.js | grep "so: \"$OS\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk '{print $NF}' | tr -d '"' | tr -d ',' | column)

  if [ "$result_checker" ]; then 
    echo -e "\n${yello}[+]${endColour}${gray} Listando las maquinas con dificultas ${endColour}${red}$difficulty ${endColour}${gray}y sistema operativo${endColour} ${blue}$OS ${endColour}\n"
    
    sleep 1
    echo -e "${turquoise}$(cat recurso.js | grep "so: \"$OS\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk '{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}"
    
  else
    echo -e "\n${red}[!] La dificultad o el sistema operativo proporcionados no son correctos, verifique :(${endColour}\n"
  fi
}

function getMachinesBySkill(){
  skill="$1"
  
  all_machines_skill=$(cat recurso.js | grep "skills:" -B 6 | grep "$skill" -i -B 6 | grep "name:" | awk '{print $NF}' | tr -d '"' | tr -d ',' | column)

  if [ "$all_machines_skill" ]; then
    echo -e "\n${yellow}[+]${endColour}${gray}Listando todas las maquinas con la skill: ${endColour}${blue}$skill ${endColour}\n"
    sleep 1
    echo -e "${turquoise}$all_machines_skill ${endColour}"
  else
    echo -e "\n${red}[!] La skill proporcionada no es valida, por favor verifique${endColour}\n"
  fi
  
}

getMachineByDifAndSkill(){
  skill="$1"
  difficulty="$2"

  result_checker=$(cat $main_file | grep "skill: \"$skill\"" -B 6 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk '{print $NF}' | tr -d ',' | tr -d '"' | column)

  if [ $result_checker ]; then
    echo -e "\n${yellow}[+]${endColour} Listando todas las maquinas por la dificultad${endColour} ${red}$difficulty ${endColour}y el Skill ${blue}$skill ${endColour}\n"

    sleep 1
    echo -e "${turquoise}$result_checker${endColour}\n"
  else
    echo -e "\n${red}[!] No existe ninguna maquina por la dificultad o la skill proporcionada, verifique${endColour} ${yellow}:${endColour}(\n"
  fi
}

getMachinesByActiveDIrectoryProp(){
  
  result_checker=$(cat $main_file | grep "activeDirectory: \"Active directory\"" -B 9 | grep "name: " | awk '{print $NF}' | tr -d '"' | tr -d ',' | column)
  
  if [ ! "$result_checker" ]; then
    echo -e "\n${red}[!] Hubo un error al obtener las maquinas, descargue de nuevo los archivos necesarios :(${endColour}\n"
  else
    echo -e "\n${yellow}[+]${endColour}${gray} Listando las maquinas de${endColour} ${blue}Directorio Activo${endColour}\n"
    sleep 1
    echo -e "${turquoise}$result_checker ${endColour}\n" 
  fi
 }

declare -i parameter_counter=0

#FUSIONS
declare -i fusion_difficulty_counter=0
declare -i fusion_os_counter=0
declare -i fusion_skill_counter=0

#Se ingresa uh juntas porque son flags que no reciben argumentos
while getopts "m:i:y:d:o:s:auh" arg; do
  case $arg in 
    m) machineName=$OPTARG; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress=$OPTARG; let parameter_counter+=3;;
    y) machineName=$OPTARG; let parameter_counter+=4;;
    d) dificulty=$OPTARG; fusion_difficulty_counter=1; let parameter_counter+=5;;
    o) OS=$OPTARG; fusion_os_counter=1; let parameter_counter+=6;;
    s) skill=$OPTARG; fusion_skill_counter=1; let parameter_counter+=7;;
    a) let parameter_counter+=8;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName 
elif [ $parameter_counter -eq 2 ]; then
  updateData
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  searchMachineByDificulty $dificulty
elif [ $parameter_counter -eq 6 ]; then
  getOSMachine $OS
elif [ $parameter_counter -eq 7 ]; then 
  getMachinesBySkill "$skill"
elif [ $fusion_os_counter -eq 1 ] && [ $fusion_difficulty_counter -eq 1 ]; then
  getMachineByDifAndOs $OS $dificulty
elif [ $fusion_skill_counter -eq 1 ] && [ $fusion_difficulty_counter -eq 1 ]; then
  getMachineByDifAndSkill "$skill" $dificulty
elif [ $parameter_counter -eq 8 ]; then
  getMachinesByActiveDIrectoryProp
else
  helpPanel
fi

