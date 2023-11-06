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
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm; exit 1
}

# Ctrl+C
trap ctrl_c INT

# Variables Globales
main_url="https://htbmachines.github.io/bundle.js"


function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso de la herramienta:${endColour}\n"
  echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por un nombre de máquina${endColour}" 
  echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por dirección IP${endColour}"
  echo -e "\t${purpleColour}d)${endColour}${grayColour} Buscar máquinas por dificultad.${endColour}" 
  echo -e "\t${purpleColour}o)${endColour}${grayColour} Buscar máquinas por Sistema Operativo.${endColour}" 
  echo -e "\t${purpleColour}s)${endColour}${grayColour} Buscar máquinas por Skills.${endColour}" 
  echo -e "\t${purpleColour}p)${endColour}${grayColour} Buscar máquinas por preparacion para certificaciones.${endColour}" 
  echo -e "\t${purpleColour}y)${endColour}${grayColour} Obtener link de la resolucion de la maquina en Youtube.${endColour}"   
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar este panel de ayuda${endColour}\n"
}

function searchMachine(){
  machineName="$1"


  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//')"

  if [ "$machineName_checker" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la maquina${endColour}${blueColour} $machineName${endColour}${grayColour}:${endColour}\n"
    sleep 1 

    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' > request.txt 
    while read line; do 
    first_column=$(echo $line | awk '{print $1}') 
    second_column=$(echo $line | awk '{$1=""; print $0}' | sed 's/^[ \t]*//') 
    echo -e "${blueColour}$first_column${endColour} ${grayColour}$second_column${endColour}"; done < request.txt
    echo -e "\n"
    rm request.txt
  else
    echo -e "\n${redColour}[!] La maquina indicada no existe${endColour}\n"
  fi
} 

function updateFiles(){
  tput civis

  if [ ! -f bundle.js  ]; then 
    echo -e "\n${yellowColour}[!]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js 
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todos los archivos han sido descargados${endColour}" 

  else
    echo -e "\n${yellowColour}[!]${endColour}${grayColour} Comprobando actualizaciones disponibles...\n${endColour}"
    sleep 2
  
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')

    if [ $md5_original_value == $md5_temp_value ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} No hay actualizaciones disponibles. Todo al dia ;)${endColour}\n"
      rm bundle_temp.js
    else
      echo -e "\n${yellowColour}[!]${endColour}${grayColour} Se han encontrado actualziaciones disponibles${endColour}\n"
      sleep 1
      rm bundle.js && mv bundle_temp.js bundle.js

      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Los archivos han sido actualizados${endColour}"
     fi   
  fi 
  tput cnorm
}

function searchIP(){
  ipAdress="$1" 
  

  ipMachine_checker="$(cat bundle.js | grep "ip: \"${ipAdress}\"" -B 3 | grep "name" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  if [ "$ipMachine_checker" ]; then

    machineName="$(cat bundle.js | grep "ip: \"${ipAdress}\"" -B 3 | grep "name" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

    echo -e "\n${yellowColour}[+]${endColour}${grayColour} La máquina correspodiente para la IP${endColour}${blueColour} $ipAdress${endColour}${grayColour} es${endColour}${purpleColour} $machineName${endColour}\n"

  else
    echo -e "\n${redColour}[!] La direccion IP ingresada no corresponde a ninguna maquina.${endColour}\n"
  fi
}

function searchYoutube(){
  machineName="$1"

  youtubeChecker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep "youtube" | awk 'NF{print $NF}')"

  if [ "$youtubeChecker" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}La resolucion de esta máquina esta en el siguiente link:${endColour} ${blueColour}$youtubeChecker${endColour}\n"
  else
    echo -e "\n${redColour}[!] La máquina ingresada no existe.${endColour}\n"
  fi 
}

function searchDifficulty(){
  difficulty="$1"

  resultsCheker="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d "," | tr -d '"' | column)"
  
  if [ "$resultsCheker" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Estas son las maquinas que posseen un nivel de dificultad${endColour}${blueColour} $difficulty${endColour}${grayColour}:${endColour}\n"
    maquinasDifficulty=$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d "," | tr -d '"' | column)
    
    if [ $difficulty == "Fácil" ]; then
      echo -e "${greenColour}$maquinasDifficulty${endColour}\n"
    elif [ $difficulty == "Media" ];then
      echo -e "${yellowColour}$maquinasDifficulty${endColour}\n"
    elif [ $difficulty == "Difícil" ]; then
      echo -e "${purpleColour}$maquinasDifficulty${endColour}\n"
    else
      echo -e "${redColour}$maquinasDifficulty${endColour}\n"
    fi 
  else 
    echo -e "\n${redColour}[!] La dificultad ingresada no existe.${endColour}\n"
  fi
}

function searchSO(){
  sistemaO="$1"

  soSystem="$(cat bundle.js | grep "so: \"$sistemaO\"" -B 4 | grep "name: " | awk 'NF{print $NF}' | tr -d "," | tr -d '"' | column)"

  if [ "$soSystem" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Estas son las maquinas que tienen Sistema Operativo${endColour}${blueColour} $sistemaO${endColour}${grayColour}:${endColour}\n"

    if [ $sistemaO == "Linux" ]; then
      echo -e "${turquoiseColour}$soSystem${endColour}\n"
    else
      echo -e "${yellowColour}$soSystem${endColour}\n"
    fi 
  else 
    echo -e "\n${redColour}[!] No existen máquinas con el Sistema Operativo ingresado.${endColour}\n"
  fi 
}

function searchDifficultyOS (){
  difficulty="$1"
  sistemaO="$2"

  validadorOsDifficulty="$(cat bundle.js  | grep "so: \"$sistemaO\"" -C 4  | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{ print $NF}' | tr -d '"' | tr -d "," | column)"

  if [ "$validadorOsDifficulty" ]; then
    echo -e "\n${yellowColour}[+]$endColour ${grayColour}Estas son las máquinas con dificultad$endColour ${blueColour}$difficulty${endColour} ${grayColour}y sistema operativo${endColour} ${blueColour}$sistemaO${endColour}${grayColour}:${endColour}\n"

    osDifficulty=$(cat bundle.js  | grep "so: \"$sistemaO\"" -C 4  | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{ print $NF}' | tr -d '"' | tr -d "," | column)

    if [ $difficulty == "Fácil" ]; then
      echo -e "${greenColour}$osDifficulty${endColour}\n"
    elif [ $difficulty == "Media" ]; then
      echo -e "${yellowColour}$osDifficulty${endColour}\n"
    elif [ $difficulty == "Difícil" ]; then
      echo -e "${purpleColour}$osDifficulty${endColour}\n"
    else 
      echo -e "${redColour}$osDifficulty${endColour}\n"
    fi 
  else
    echo -e "\n${redColour}[!] No existen máquinas con el Sistema Operativo y Dificultad ingresadas${endColour}\n"
  fi
}

function searchSkill(){
  skills="$1"

  skillChecker="$(cat bundle.js | grep "skills: " -B 6 | grep "$skills" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column)"  

  if [ "$skillChecker" ]; then
    echo -e "${yellowColour}[+]${endColour}${grayColour} Estas son las máquinas relacionadas con la skill${endColour}${blueColour} $skills${endColour}${grayColour}:${endColour}"
    echo -e "\n${blueColour}$skillChecker${endColour}\n"
  else
    echo -e "\n${redColour}[!] No existen máquinas con el Skill ingresado${endColour}\n"
  fi 
}


function searchPreparation(){
  preparation="$1"

  certificaChecker="$(cat bundle.js | grep "like: " -B 7 | grep "$preparation" -i -B 7 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$certificaChecker" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Estas son las máquinas que te preparan para la certificacion${endColour}${blueColour} $preparation${endColour}${grayColour}:${endColour}\n"
    
    if [ "$preparation" == "ejpt" ]; then
      echo -e "${greenColour}$certificaChecker${endColour}\n"
    else
      echo -e "${purpleColour}$certificaChecker${endColour}\n"
    fi
  else
    echo -e "\n${redColour}[!] No existen máquinas que te preparen para la certificacion indicada${endColour}\n"
  fi
}

function searchPrepOs(){
  sistemaO="$1"
  preparation="$2"

  prepOSChecker="$(cat bundle.js | grep "like: " -B 7 | grep "$preparation" -i -B 7 | grep "so: \"$sistemaO\"" -B 5 | grep "name: " | awk 'NF {print $NF}' | tr -d '"' | tr -d "," | column)"  

  if [ "$prepOSChecker" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Las Máquinas${endColour} ${blueColour}$sistemaO${endColour}${grayColour} que te preparan para la certificacion${endColour}${blueColour} $preparation${endColour}${grayColour} son:${endColour}\n"

    if [ "$sistemaO" == "Linux" ]; then
      echo -e "${greenColour}$prepOSChecker${endColour}\n"
    else
      echo -e "${yellowColour}${prepOSChecker}${endColour}\n"
    fi 

  else
    echo -e "\n${redColour}[!] No existen máquinas ${blueColour}${sistemaO}${endColour}que te preparen para la certificacion indicada${endColour}\n"
  fi 
}


function searchPrepOSDif(){
  sistemaO="$1"
  preparation="$2"
  difficulty="$3"

  allChecker="$(cat bundle.js | grep "like: " -B 7 | grep "$preparation" -i -B 7 | grep "dificultad: \"$difficulty\"" -B 5 | grep "so: \"$sistemaO\"" -B 4 | grep "name: " | awk 'NF{print $NF}' | tr -d "," | tr -d '"' | column)"

  if [ "$allChecker" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Estas son las máquinas${endColour}${blueColour} ${sistemaO}${endColour}${grayColour} con dificultad${endColour}${blueColour} ${difficulty}${endColour}${grayColour} que te preparan para la certificacion${endColour}${blueColour} ${preparation}${endColour}${grayColour}:${endColour}\n"
    
    if [ "$sistemaO" == "Linux" ]; then  
      echo -e "${greenColour}${allChecker}${endColour}\n"
    else   
      echo -e "${yellowColour}${allChecker}${endColour}\n"
    fi 

  else
    echo -e "\n${redColour}[!] No existen máquinas${endColour} ${blueColour}${sistemaO}${endColour}${redColour} con dificultad${endColour} ${blueColour}${difficulty}${endColour}${redColour} que te preparen para la certificacion${endColour}${blueColour} ${preparation}${endColour}\n"
  fi
}


# Indicadores
declare -i parameter_counter=0

# Chivatos

declare -i chivato_difficulty=0
declare -i chivato_os=0
declare -i chivato_prep=0

while getopts "m:ui:y:d:o:s:p:h" arg; do 
    case $arg in
      m) machineName="$OPTARG"; let parameter_counter+=1;;
      u) let parameter_counter+=2;;
      i) ipAdress="$OPTARG"; let parameter_counter+=3;;
      y) machineName="$OPTARG"; let parameter_counter+=4;;
      d) difficulty="$OPTARG"; chivato_difficulty=1; let parameter_counter+=5;;
      o) sistemaO="$OPTARG"; chivato_os=1; let parameter_counter+=6;;
      s) skills="$OPTARG"; let parameter_counter+=7;;
      p) preparation="$OPTARG"; chivato_prep=1; let parameter_counter+=8;;
      h) ;; 
    esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAdress
elif [ $parameter_counter -eq 4 ]; then
  searchYoutube $machineName
elif [ $parameter_counter -eq 5 ]; then
  searchDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  searchSO $sistemaO
elif [ $parameter_counter -eq 7 ]; then
  searchSkill "$skills"
elif [ $parameter_counter -eq 8 ]; then
  searchPreparation $preparation
elif [ $chivato_os -eq 1 ] && [ $chivato_prep -eq 1 ] && [ $chivato_difficulty -eq 1 ]; then
  searchPrepOSDif $sistemaO $preparation $difficulty
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
  searchDifficultyOS $difficulty $sistemaO
elif [ $chivato_os -eq 1 ] && [ $chivato_prep -eq 1 ]; then
  searchPrepOs $sistemaO $preparation
else
  helpPanel
fi  
