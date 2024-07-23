#!/bin/bash


## ══════════════┃ COLORES PARA LAS SALIDAS DE LOS COMANDOS ┃═════════════ ##
green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

export DEBIAN_FRONTEND=noninteractivee


## ══════════════┃ FUNCIÓN PARA DETENER EL SCRIPT CON CTRL + C ┃═════════════ ##
function ctrl_c(){
  echo -e "\n\n${red}[!] Exiting...${end}\n"
  tput cnorm; exit 1
}
trap ctrl_c INT


## ══════════════┃ DETECTAR SI HAY UN ERROR Y DETENER EL SCRIPT ┃═════════════ ##
function status_code(){
  if [ "$(echo $?)" != "0" ]; then
    echo -e "\n${red}[X] OCURRIÓ UN PROBLEMA${end}\n"
    tput cnorm; exit 1
  fi
}


## ══════════════┃ VERIFICAR LA DISTRO ES DEBIAN ┃═════════════ ##
check_distro() {
    if [ -e /etc/os-release ] && grep -q 'debian' /etc/os-release; then
        echo ""
    else
        echo -e "\n${red}[X] ESTE SCRIPT SOLO FUNCIONA PARA DEBIAN${end}\n"
        sleep 5
        exit 1
    fi
}


## ══════════════┃ VERIFICAR SI SE ESTÁ EJECUTANDO CON ROOT ┃═════════════ ##
function check_user(){
  if [ "$(id -u)" == "0" ]; then
    echo -e "\n${red}[!] NO EJECUTAR ESTE SCRIPT COMO ROOT${end}\n"
    tput cnorm; exit 1
  fi
}


## ══════════════┃ VERIFICAR SI HAY CONECCIÓN A INTERNET ┃═════════════ ##
function check_internet(){
  tput civis; 
  
  ping -c 1 google.com > /dev/null 2>&1
  if [[ "$(echo $?)" -eq 0 ]]; then
    echo -e "\n${green}[✔] CON CONECCIÓN A INTERNET${end}"
    sleep 1.5
  else
    echo -e "\n${red}[X] COMPRUEBA TU CONECCIÓN A INTERNET${end}"
    tput cnorm; exit 1
  fi
}


## ══════════════┃ DETECTAR EL NOMBRE DE LA INTERFAZ DE RED Y AGREGARLO AL SCRIPT ethernet_status.sh ┃═════════════ ##
function iface(){
  interfaz=$(for i in $(ip a | grep -oP ": .*?:" | tr -d ':'); do
    		if [ "$i" != "lo" ]; then
        		echo -e "$i"
    		fi
	done)

  sed -i "s/eth0/$interfaz/" config/bin/ethernet_status.sh
}


## ══════════════┃ FUNCIÓN PARA INSTALAR LOS PAQUETES NECESARIOS ┃═════════════ ##
function package_installer(){
  for package in ${required_packages[@]}; do
      echo -ne "\t${yellow}[${blue}*${yellow}] INSTALANDO ${turquoise}$package ${end}"
      sudo apt install $package -y &>/dev/null
      status_code
      for i in $(seq 1 7); do echo -ne "${yellow}.${end}"; sleep 0.1; done
      echo -e " ${yellow}[${green}\u2713${yellow}]${end}"
      sleep 1
    done
}


## ══════════════┃ DEPENDENCIAS A INSTALAR ┃═════════════ ##
function dependencies(){
  tput civis

  echo -e "\n${yellow}[*] BUSCANDO ACTUALIZACIONES${end}"; sleep 1
  update=$(sudo apt update | tail -n 1 | grep -oP "\d{1,5000}" | tr -d '\n')
  if [ "$update" > "0" ]; then
    echo -e "\n${purple}█ ${gray}HAY ${purple}$update${gray} PAQUETES POR ACTUALIZAR ${purple}█${end}"
  fi

  if [ "$(echo $?)" -eq 0 ]; then
    if [ "$update" > "0" ]; then
      echo -e "\n${yellow}[*] ACTUALIZANDO PAQUETES DEL SISTEMA${end}"; sleep 1
      sudo apt upgrade -y &>/dev/null

      if [ "$(echo $?)" != "0" ]; then
        echo -e "\n${red}[X] OCURRIÓ UN PROBLEMA${end}\n"
        exit 1
      else
        echo -e "\n${turquoise}█ ${gray}SISTEMA ACTUALIZADO CORRECTAMENTE ${turquoise}█${end}"
        sleep 1
      fi

    else
			echo -e "\n${turquoise}█ ${gray}NO SE ENCONTRARON PAQUETES POR ACTUALIZAR ${turquoise}█${end}"
		fi

    echo -ne \\n${yellow}[*] INSTALANDO ALGUNOS PAQUETES NECESARIOS = ;
    sleep 2 & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '\' '|' '/'; do echo -en "\b$X"; sleep 0.1; done; done
    echo -e "${end}\n"

    declare -a required_packages=(build-essential libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev libxinerama1 libxinerama-dev kitty flameshot brightnessctl pamixer moreutils)
    package_installer

    echo -e "\n${turquoise}█ ${gray}PAQUETES INSTALADOS CORRECTAMENTE ${turquoise}█${end}"

  else
    echo -e "\n${red}[X] OCURRIÓ UN PROBLEMA${end}\n"
    tput cnorm; exit 1
  fi

  echo -e "\n${yellow}[*] CONFIGURANDO TERMINAL KITTY${end}"; sleep 1
  mkdir ~/.config/kitty 2>/dev/null
  cp {config/kitty/kitty.conf,config/kitty/color.ini} ~/.config/kitty/.
}


## ══════════════┃ INSTALANDO/CLONANDO BSPWM Y SXHKD ┃═════════════ ##
function bspwm_sxhkd(){
  tput civis

	echo -e "\n${yellow}[*] CLONANDO BSPWM${end}"; sleep 1
  git clone https://github.com/baskerville/bspwm.git &>/dev/null
  status_code
  echo -e "\n${turquoise}█ ${gray}BSPWM CLONADO CORRECTAMENTE ${turquoise}█${end}"
  sleep 1

	echo -e "\n${yellow}[*] CLONANDO SXHKD${end}"; sleep 1
  git clone https://github.com/baskerville/sxhkd.git &>/dev/null
  status_code
  echo -e "\n${turquoise}█ ${gray}SXHKD CLONADO CORRECTAMENTE ${turquoise}█${end}"
  sleep 1

  function install_bspwm(){
	  cd bspwm/
	  make
	  status_code
	  sudo make install
	  status_code
    cd ..
  }

  echo -e "\n${yellow}[*] INSTALANDO BSPWM (make)"; sleep 1
  install_bspwm &>/dev/null
  status_code
  echo -e "\n${turquoise}█ ${gray}BSPWM INSTALADO CORRECTAMENTE ${turquoise}█${end}"; sleep 1

	echo -e "\n${yellow}[*] INSTALANDO SXHKD${end}"; sleep 1
  function install_sxhkd(){
    cd sxhkd/
	  make
	  status_code
    sudo make install
	  status_code
    cd ..
  }

  install_sxhkd &>/dev/null
  status_code
	echo -e "\n${turquoise}█ ${gray}SXHKD INSTALADO CORRECTAMENTE ${turquoise}█${end}"; sleep 1

  echo -e "\n${yellow}[*] INSTALANDO BSPWM (apt)${end}"; sleep 1
  sudo apt install bspwm -y &>/dev/null
	status_code
  echo -e "\n${turquoise}█ ${gray}BSPWM INSTALADO CORRECTAMENTE ${turquoise}█${end}"; sleep 1

	echo -e "\n${yellow}[*] CARGANDO ALGUNOS FICHEROS DE BSPWM Y SXHKD${end}"; sleep 1
	mkdir ~/.config/bspwm
  mkdir ~/.config/bspwm/sxhkd
	cp config/bspwm/bspwmrc ~/.config/bspwm/
	status_code
  echo -e "\n${turquoise}█ ${gray}FICHEROS CARGADOS CORRECTAMENTE ${turquoise}█${end}"
  sleep 1

	echo -e "\n${yellow}[*] CONFIGURANDO BSPWMRC${end}"; sleep 1
	cat config/bspwm/bspwmrc | sed 's/USER/'$USER'/g' > ~/.config/bspwm/bspwmrc && chmod +x ~/.config/bspwm/bspwmrc
	status_code
	echo -e "\n${turquoise}█ ${gray}BSPWMRC CONFIGURADO CORRECTAMENTE ${turquoise}█${end}"
	sleep 1

	echo -e "\n${yellow}[*] CONFIGURANDO SXHKDRC${end}"; sleep 1
	cat config/sxhkd/sxhkdrc | sed 's/USER/'$USER'/g' > ~/.config/bspwm/sxhkd/sxhkdrc
  status_code
  echo -e "\n${turquoise}█ ${gray}SXHKDRC CONFIGURADO CORRECTAMENTE ${turquoise}█${end}"
  sleep 1

	echo -e "\n${yellow}[*] CONFIGURANDO BSPWM_RESIZE${end}"; sleep 1
	mkdir ~/.config/bspwm/scripts/
	cp config/bspwm/scripts/bspwm_resize ~/.config/bspwm/scripts/. && chmod +x ~/.config/bspwm/scripts/bspwm_resize
	status_code
  echo -e "\n${turquoise}█ ${gray}BSPWM_RESIZE CONFIGURADO CORRECTAMENTE ${turquoise}█${end}"
  sleep 1; tput cnorm
}


## ══════════════┃ INSTALAR POLYBAR ┃═════════════ ##
function Polybar(){
	tput civis

	echo -ne \\n${yellow}[*] INSTALANDO PAQUETES NECESARIOS PARA LA POLYBAR = ;
  sleep 2 & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '\' '|' '/'; do echo -en "\b$X"; sleep 0.1; done; done
  echo -e "${end}\n"

  declare -a required_packages=(cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev libuv1-dev libnl-genl-3-dev)
  package_installer 

  echo -e "\n${turquoise}█ ${gray}PAQUETES INSTALADOS CORRECTAMENTE ${turquoise}█${end}"

  function install_polybar(){
	  git clone --recursive https://github.com/polybar/polybar
	  cd polybar/
	  mkdir build
	  cd build/
	  cmake ..
	  status_code
	  make -j$(nproc)
	  status_code
	  sudo make install
  }

	echo -e "\n${yellow}[*] CLONANDO E INSTALANDO POLYBAR"; sleep 1
  install_polybar &>/dev/null
  status_code

  mkdir ~/.config/bspwm/polybar
	echo -e "\n${turquoise}█ ${gray}POLYBAR INSTALADA CORRECTAMENTE ${turquoise}█${end}"
  sleep 1; tput cnorm
}


## ══════════════┃ INSTALAR Y CONFIGURAR PICOM Y ROFI ┃═════════════ ##
function picom_rofi(){
	tput civis

## INSTALACIÓN Y CONFIGURACIÓN DE PICOM
	echo -e "\n${yellow}[*] ACTUALIZANDO EL SISTEMA${end}"; sleep 1
  sudo apt update &>/dev/null
  status_code
  echo -e "\n${turquoise}█ ${gray}SISTEMA ACTUALIZADO CORRECTAMENTE ${turquoise}█${end}"
  sleep 1

  echo -ne \\n${yellow}[*] INSTALANDO PAQUETES NECESARIOS PARA PICOM = ;
  sleep 2 & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '\' '|' '/'; do echo -en "\b$X"; sleep 0.1; done; done
  echo -e "${end}\n"

  declare -a required_packages=(meson libxext-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-present-dev libpixman-1-dev libconfig-dev libgl1-mesa-dev libpcre3 libpcre3-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev libxcb-glx0-dev libdbus-1-dev)
  package_installer 

  echo -e "\n${turquoise}█ ${gray}PAQUETES INSTALADOS CORRECTAMENTE ${turquoise}█${end}"
  sleep 1

  function install_picom(){
    git clone https://github.com/ibhagwan/picom.git
	  cd picom/
	  git submodule update --init --recursive
	  status_code
	  meson --buildtype=release . build
	  status_code
	  sudo ninja -C build
	  status_code
	  sudo ninja -C build install
  }

	echo -e "\n${yellow}[*] INSTALANDO PICOM"; sleep 1
  install_picom &>/dev/null
  status_code
  
  cd ..
	echo -e "\n${turquoise}█ ${gray}PICOM INSTALADO CORRECTAMENTE ${turquoise}█${end}"
  sleep 1


## INSTALACIÓN Y CONFIGURACIÓN DE ROFI
	echo -e "\n${yellow}[*] INSTALANDO ROFI"; sleep 1
  sudo apt install rofi -y &>/dev/null
  status_code
	cd ../../..
	rm -rf ~/.config/rofi
  mkdir ~/.config/rofi
  status_code
	echo -e "\n${turquoise}█ ${gray}ROFI INSTALADO CORRECTAMENTE ${turquoise}█${end}"
  sleep 1

  echo -e "\n${yellow}[*] CONFIGURANDO TEMA DE ROFI"; sleep 1
  git clone https://github.com/adi1090x/rofi.git &>/dev/null
  mkdir ~/.config/rofi 2>/dev/null && rm -rf ~/.config/rofi/*
  cp -R {rofi/files/colors,rofi/files/images,rofi/files/launchers,rofi/files/powermenu} ~/.config/rofi/.

  echo -e "\n${turquoise}█ ${gray}TEMA DE ROFI CONFIGURADO CORRECTAMENTE ${turquoise}█${end}"
  sleep 1
  
}


## ══════════════┃ INSTALAR Y CONFIGURAR FEH_ILOCK ┃═════════════ ##
function feh_ilock(){
  tput civis

  echo -e "\n${yellow}[*] INSTALANDO FEH"; sleep 1
  sudo apt install feh -y &>/dev/null
  status_code
	cp config/bspwm/Wallpaper.png ~/.config/bspwm/.
  echo -e "\n${turquoise}█ ${gray}FEH INSTALADO CORRECTAMENTE ${turquoise}█${end}"
  sleep 1

  echo -ne \\n${yellow}[*] INSTALANDO DEPENDENCIAS PARA I3LOCK = ;
  sleep 2 & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '\' '|' '/'; do echo -en "\b$X"; sleep 0.1; done; done
  echo -e "${end}\n"

  declare -a required_packages=(autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev)
  package_installer 

  echo -e "\n${turquoise}█ ${gray}DEPENDENCIAS INSTALADAS CORRECTAMENTE ${turquoise}█${end}"
  sleep 1
}


## ══════════════┃ INSTALAR UTILIDADES EXTRAS ┃═════════════ ##
function extra_utilities(){
  tput civis

  echo -ne \\n${yellow}[*] INSTALANDO ALGUNAS UTILIDADES EXTRA = ;
  sleep 2 & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '\' '|' '/'; do echo -en "\b$X"; sleep 0.1; done; done
  echo -e "${end}\n"

  declare -a required_packages=(xclip firejail caja flameshot scrub brightnessctl)
  package_installer

  echo -e "\n${turquoise}█ ${gray}UTILIDADES INSTALADAS CORRECTAMENTE ${turquoise}█${end}"
  sleep 1; tput cnorm
}


## ══════════════┃ INSTALAR FUENTES DE HACK NERD FONTS ┃═════════════ ##
function fonts(){
  tput civis

	echo -e "\n${yellow}[*] INSTALANDO HACK NERD FONTS"; sleep 1
	cd config
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.2/Hack.zip

  unzip Hack.zip > /dev/null 2>&1 && sudo mv *.ttf /usr/local/share/fonts/.
  rm Hack.zip LICENSE.md readme.md
  echo -e "\n${turquoise}█ ${gray}HACK NERD FONTS INSTALADAS CORRECTAMENTE ${turquoise}█${end}"; sleep 1
  status_code; tput cnorm
}


## ══════════════┃ CONFIGURACIONES ┃═════════════ ##
function configs(){
  tput civis

	interfaz=$(for i in $(ip a | grep -oP ": .*?:" | tr -d ':'); do
    		if [ "$i" != "lo" ]; then
        		echo -e "$i"
    		fi
	done)
	archivo_config="$HOME/.config/bspwm/polybar/current.ini"

	echo -e "\n${yellow}[*] AÑADIENDO Y CONFIGURANDO POLYBAR${end}"; sleep 1
  cd $HOME/bspwm/config
	sed -i "s/USER/$USER/g" polybar/scripts/powermenu
	sed -i "s/USER/$USER/g" polybar/scripts/powermenu_alt
	cp $HOME/bspwm/config/polybar/* -r ~/.config/bspwm/polybar/. && chmod +x ~/.config/bspwm/polybar/launch.sh
	sudo cp polybar/fonts/* /usr/share/fonts/truetype/. && fc-cache -v install_ilock-col &>/dev/null
	sudo rm -r $HOME/bspwm/bspwm $HOME/bspwm/polybar $HOME/bspwm/sxhkd $HOME/bspwm/0
	cp $HOME/bspwm/config/bin/* -r ~/.config/bspwm/scripts/. && chmod +x ~/.config/bspwm/scripts/* && chmod +x ~/.config/bspwm/polybar/scripts/launcher ~/.config/bspwm/polybar/scripts/powermenu ~/.config/bspwm/polybar/scripts/powermenu_alt
	sed -i "s/interface = wlp2s0/interface = $interfaz/" "$archivo_config"
	status_code
	echo -e "\n${turquoise}█ ${gray}POLYBAR AÑADIDA Y CONFIGURADA CORRECTAMENTE ${turquoise}█${end}"; sleep 1


  echo -e "\n${yellow}[*] CONFIGURANDO PICOM"; sleep 1
	mkdir ~/.config/bspwm/picom
	cp $HOME/bspwm/config/picom/picom.conf ~/.config/bspwm/picom/.
	status_code
	echo -e "\n${turquoise}█ ${gray}PICOM CONFIGURADO CORRECTAMENTE ${turquoise}█${end}"; sleep 1


	echo -e "\n${yellow}[*] ACTUALIZANDO EL SISTEMA${end}"; sleep 1
  sudo apt update &>/dev/null
  status_code
  echo -e "\n${turquoise}█ ${gray}SISTEMA ACTUALIZADO CORRECTAMENTE ${turquoise}█${end}"; sleep 1


  echo -ne \\n${yellow}[*] INSTALANDO I3LOCK Y PAQUETES NECESARIOS PARA I3LOCK-COLOR = ;
  sleep 2 & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '\' '|' '/'; do echo -en "\b$X"; sleep 0.1; done; done
  echo -e "${end}\n"

  declare -a required_packages=(libpam0g-dev libxrandr-dev libfreetype6-dev  libxft-dev i3lock autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev libxcb-xtest0-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev)
  package_installer

	echo -e "\n${turquoise}█ ${gray}I3LOCK Y DEPENDENCIAS INSTALADAS CORRECTAMENTE ${turquoise}█${end}"
  sleep 1

  function install_ilock-col(){
    git clone https://github.com/Raymo111/i3lock-color ~/i3lock-color
    mv ~/i3lock-color . && cd i3lock-color
	  bash install-i3lock-color.sh
	  status_code
  }

	echo -e "\n${yellow}[*] CLONANDO E INSTALANDO I3LOCK-COLOR"; sleep 1
  install_ilock-col &>/dev/null
  echo -e "\n${turquoise}█ ${gray}I3LOCK INSTALADO CORRECTAMENTE ${turquoise}█${end}"
  sleep 1

	echo -e "\n${yellow}[*] CONFIGURANDO FICHEROS PARA I3LOCK-COLOR"; sleep 1
	cd ..
	chmod +x i3lock-color/examples/lock.sh && mv i3lock-color ~/
	status_code
  echo -e "\n${turquoise}█ ${gray}FICHEROS DE I3LOCK-COLOR CONFIGURADOS CORRECTAMENTE ${turquoise}█${end}"
  sleep 1; tput cnorm
}


## ══════════════┃ CONFIGURACIONES DE LA ZSH ┃═════════════ ##
function zsh_config(){
  tput civis

  sudo apt install zsh -y &>/dev/null
  sudo ln -s -f /home/$USER/.zshrc /root/.zshrc
  echo -e "\n${yellow}[*] CLONANDO Y AÑADIENDO POWELEVEL10K PARA EL USUARIO ${gray}$USER${end}"; sleep 1
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k > /dev/null 2>&1
	echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

	echo -e "\n${yellow}[*] CLONANDO Y AÑADIENDO POWELEVEL10K PARA EL USUARIO ${gray}root${end}"; sleep 1
	sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k > /dev/null 2>&1
	status_code
  cd config
	echo -e "\n${turquoise}█ ${gray}POWELEVEL10K INSTALADO Y AÑADIDO CORRECTAMENTE PARA LOS DOS USUARIOS ${turquoise}█${end}"
  sleep 1

	echo -e "\n${yellow}[*] AÑADIENDO BAT Y LSD A LA ZSH${end}"
  sudo apt install bat -y &>/dev/null
  sudo apt install lsd -y &>/dev/null
  status_code
	echo -e "\n${turquoise}█ ${gray}BAT Y LSD INSTALADO Y AÑADIDO CORRECTAMENTE ${turquoise}█${end}"
  sleep 1

	echo -e "\n${yellow}[*] AÑADIENDO PLUGIN DE SUDO A LA ZSH${end}"
	sudo mkdir /usr/share/zsh-plugins && sudo cp sudo.plugin.zsh /usr/share/zsh-plugins/.
	sed -i "s/USER/$USER/g" zsh-adds && cat zsh-adds >> ~/.zshrc && sudo chown $USER:$USER /usr/share/zsh-plugins/ && sudo chown $USER:$USER /usr/share/zsh-plugins/sudo.plugin.zsh
	status_code
	echo -e "\n${turquoise}█ ${gray}PLUGIN DE SUDO AÑADIDO CORRECTAMENTE ${turquoise}█${end}"
  sleep 1

  echo -e "\n${yellow}[*] CLONANDO E INSTALANDO FZF PARA EL USUARIO ${gray}$USER${end}"
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &>/dev/null
	~/.fzf/install --all &>/dev/null

	echo -e "\n${yellow}[*] CLONANDO E INSTALANDO FZF PARA EL USUARIO ${gray}root${end}"
  sudo git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &>/dev/null
  sudo ~/.fzf/install --all &>/dev/null
  status_code
  echo -e "\n${turquoise}█ ${gray}FZF INSTALADO CORRECTAMENTE PARA LOS DOS USUARIOS ${turquoise}█${end}"

  echo -e "\n${yellow}[*] CLONANDO E INSTALANDO NVCHAD PARA EL USUARIO ${gray}$USER${end}"
  rm -rf ~/.config/nvim
  git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 &>/dev/null
  status_code
  pushd /opt &>/dev/null && sudo wget -q https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz && sudo tar -xf nvim-linux64.tar.gz; popd &>/dev/null
  
  echo -e "\n${yellow}[*] CLONANDO E INSTALANDO NVCHAD PARA EL USUARIO ${gray}root${end}"
  sudo rm -rf /root/.config/nvim
  sudo git clone https://github.com/NvChad/NvChad /root/.config/nvim --depth 1 &>/dev/null
  status_code
  echo -e "\n${turquoise}█ ${gray}NVCHAD CLONADO E INSTALADO CORRECTAMENTE ${turquoise}█${end}"

  sleep 1; tput cnorm
}


## ══════════════┃ SLIM ┃═════════════ ##
function slim(){
  tput civis

  cd ~/Descargas/
  echo -e "\n${yellow}[*] CLONANDO E INSTALANDO blue-sky"
  git clone https://github.com/VaughnValle/blue-sky.git &>/dev/null
  status_code

  echo -e "\n${yellow}[*] ACTUALIZANDO SISTEMA"
  sudo apt update &>/dev/null
  status_code

  sudo apt install slim -y
  clear
  status_code

  echo -e "\n${yellow}[*] INSTALANDO PAQUETES PARA SLIM"
  declare -a required_packages=(libpam0g-dev libxrandr-dev libfreetype6-dev libimlib2-dev libxft-dev)
  package_installer
  status_code

  clear
  cd $HOME

  echo -e "\n${yellow}[*] CLONANDO E INSTALANDO SLIM"
  git clone https://github.com/joelburget/slimlock.git &>/dev/null
  cd slimlock/
  rm -rf panel.cpp
  cp -r $HOME/bspwm/config/slim/panel.cpp .
  status_code

  echo -e "\n${yellow}[*] SUDO MAKE"
  sudo make &>/dev/null
  status_code

  echo -e "\n${yellow}[*] SUDO MAKE INSTALL"
  sudo make install &>/dev/null
  status_code

  echo -e "\n${yellow}[*] COPIANDO ARCHIVOS AL /etc/"
  cd ~/Descargas/blue-sky/slim
  sudo cp slim.conf /etc/
  sudo cp slimlock.conf /etc
  sudo cp -r default /usr/share/slim/themes
  status_code

  echo -e "\n${yellow}[*] COPIANDO TEMA DE SLIM"
  cd /usr/share/slim/themes/default
  sudo rm -rf /usr/share/slim/themes/default/*
  sudo cp -r ~/bspwm/config/slim/background.png .
  sudo cp -r ~/bspwm/config/slim/panel.png .
  sudo cp -r ~/bspwm/config/slim/slim.theme .
  status_code

  if [[ -f /etc/X11/default-display-manager ]];then
    local dm_path
    dm_path=$(cat /etc/X11/default-display-manager)

    local dm_name
    dm_name=$(basename "$dm_path")

  fi
  status_code

  sleep 5; tput cnorm
}


## ══════════════┃ CERRAR SESIÓN DEL USUARIO ┃═════════════ ##
function change_session(){
	echo -ne "\n\t\t${purple}█ ${gray}¿DESEA CERRAR ESTA SESIÓN PARA INICIAR LA NUEVA CONFIGURACIÓN? [Y/N]${purple} █> ${end}" && read a
	if [[ "$a" == "Y" || "$a" == "y" ]]; then
    tput civis
		echo -e "\n${red}" 
    echo -n █ CERRANDO SESIÓN - INICIE SESIÓN EN BSPWM COMO EL USUARIO $USER = ;
    sleep 10 & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '\' '|' '/'; do echo -en "\b$X"; sleep 0.1; done; done
		sudo reboot
	fi
}


#══════════════┃ MAIN ┃═════════════

check_distro
check_user 2>/dev/null
iface 2>/dev/null
check_internet 2>/dev/null
dependencies 2>/dev/null
bspwm_sxhkd 2>/dev/null
Polybar 2>/dev/null
picom_rofi 2>/dev/null
feh_ilock 2>/dev/null
extra_utilities	2>/dev/null
fonts 2>/dev/null
configs 2>/dev/null
zsh_config 2>/dev/null
slim
change_session