#!/usr/bin/bash
# fix this
apt update
apt install doas ufw neofetch neovim git flatpak fail2ban exa nala preload unzip wget linux-headers-amd64 xdg-desktop-portal-wlr qtwayland5 vlc -y
echo "permit persist alino10 as root" > /etc/doas.conf
doas ln -s /usr/bin/doas /usr/bin/sudo
exit 0
sudo ufw limit 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak run io.gitlab.librewolf-community
flatpak run org.prismlauncher.PrismLauncher
git clone https://github.com/LazyVim/starter ~/.config/nvim
doas cat << EOF > /etc/fail2ban/jail.local
[DEFAULT]
ignoreip = 127.0.0.1/8 ::1
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = false

EOF
doas cat << EOF > ~/.bashrc
# If not running interactively, don't do anything 
[[ $- != *i* ]] && return 

# Aliases
alias install='doas nala install'
alias update='doas nala update'
alias upgrade='doas nala upgrade'
alias remove='doas nala autoremove'
alias ls='exa -al --header --icons --group-directories-first'
alias free='free -h'
alias reload='source ~/.bashrc'
alias gc="git clone"

# Add Color
alias grep='grep --color=auto' 

 export VISUAL=nvim;
 export EDITOR=nvim;
# PS1 Customization
PS1="\[\e[32m\]\h\[\e[m\]\[\e[36m\]@\[\e[m\]\[\e[34m\]\u\[\e[m\] \W \$ " 
neofetch
EOF
doas cat << EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian testing main non-free contrib
deb-src http://deb.debian.org/debian testing main non-free contrib

deb http://deb.debian.org/debian-security/ bookworm-security main non-free contrib
deb-src http://deb.debian.org/debian-security/ bookworm-security main non-free contrib

deb http://deb.debian.org/debian bookworm-updates main non-free contrib
deb-src http://deb.debian.org/debian bookworm-updates main non-free contrib
EOF
mkdir -p ~/.local/share/fonts

fonts=( 
"CascadiaCode"
"FiraCode" 
"Go-Mono" 
"Hack"  
"JetBrainsMono" 
"Meslo"
"Mononoki" 
"RobotoMono" 
"SourceCodePro" 
"UbuntuMono"
)

for font in ${fonts[@]}
do
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/$font.zip
	  unzip $font.zip -d $HOME/.local/share/fonts/$font/
    rm $font.zip
done
fc-cache

sudo systemctl enable fail2ban
sudo systemctl start fail2ban
doas cat << EOF > ~/.profile
export MOZ_ENABLE_WAYLAND=1 # for firefox
export XDG_SESSION_TYPE=wayland 
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland
if [ -z \$DISPLAY ] && [ "\$(tty)" = "/dev/tty1" ]; then
  exec bswpm
fi
EOF
sudo nala upgrade
