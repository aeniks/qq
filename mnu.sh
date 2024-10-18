#!/bin/bash ## installer and html index file ##
## aeniks.github.io #######
###########################
# printf "\e[2K\e[A\e[A\e[2K"; ## delet init lines
size=($(stty size)); s=sudo; [ "$SUDO_UID" ]&& sudo=""; dots="$(for i in $(seq $(($(stty size|tail -c4) - 11))); do echo -ne "·"; done;)";
c2='\e[36m--\e[0m'; re='\e[0m'; dim='\e[2m'; bold='\e[1m'; green='\e[92m'; cyan='\e[36m'; 
##
##
# for i in $(seq $((size-4))); do printf "  \e[$((RANDOM%6))B  \e[48;5;$((RANDOM%88))m  \e[$(shuf -n1 -i0-6)A"; printf " "; sleep .01; done;
# # printf "\n\n\n\n\n\n\n\e[6A";
# sleep .1;
# printf "\n$c2 hello \n"; sleep .1;
# printf "\n$c2 hello \n"; sleep .1;
# sleep .1;
###################
## multiselection menu for bash
mnu() {
for i in $(seq $((LINES))); do printf "\n"; sleep 0.1; done; 
printf "\e[H\e[J\e[0m"; 
##vars
# printf "\e[s\e[H\e[J";
ex="$s apt install -y"; [ "$2" ]&& ex="$2";
PROMPT1="hello_ installer"; [ $3 ]&& PROMPT1=$3;
printf "
 $dots\e[4G ${green}$PROMPT_1${re}  
 $dots\e[4G [${bold}${dim}^${re}/${dim}v${re}]$dim${cyan} select${re} [${dim}a${re}]$dim${cyan}ll${re}\
  [${dim}h${re}]$dim${cyan}elp${re}  [${dim}  ${re}]$dim$cyan enter${re}\
  [${dim}c${re}]$dim${cyan}onfirm${re} [${dim}q${re}]$dim${cyan}uit${re}  \n $dots\n";
unset OPTIONS_VALUES OPTIONS_STRING SELECTED CHECKED OPTIONS_LABELS ov1 cd;
if [[ $1 ]]; then cd $1; OPTIONS_VALUES=($(ls -p|grep -v /)); else OPTIONS_VALUES=($(ls -p $PWD/$1)); fi;
if [[ $4 ]]; then for i in ${OPTIONS_VALUES[@]}; do
OPTIONS_LABELS+=("\e[2m $($4 "$i";) "); done;
else for i in ${OPTIONS_VALUES[@]};
do ft=$(file $i --mime-type -b|head -c4); if [[ $ft == "text" ]]; then
OPTIONS_LABELS+=("\e[2m $(sed -n 2p $i|tr -s ';()\\' ' '|cut -c-${size[1]}) "); else
OPTIONS_LABELS+=("\e[2m $(file -b $i|cut -c-${size[1]}) "); fi; done; echo -e "\e[0J"; fi;
for i in "${!OPTIONS_VALUES[@]}"; do
OPTIONS_STRING+="$dots\e[6G "${OPTIONS_VALUES[$i]%/$PWD/}" \e[22G ${OPTIONS_LABELS[$i]};"; done;
OPTIONS_STRING+="\e[1K\n\e[6G\e[1m${cyan} Confirm";
####################
checkbox () {
## little helpers for terminal print control and key input
e=$( printf "\e"); cursor_blink_on()   { printf "$e[?25h"; }; cursor_blink_off()  { printf "$e[?25l"; }; cursor_to()         { printf "$e[$1;${2:-1}H"; }; print_inactive()    { printf "$2  $1 "; }; print_active()      { printf "$2 $e[7m $1 $e[27m"; }; get_cursor_row()    { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
#####################
## keys ##########
key_input()         {
local key IFS; IFS= read -rsn1 key 2>/dev/null >&2;
if [[ $key = "" ]]; then if [[ ${active} == $((idx - 1)) ]];
then echo -e "c"; else echo enter; fi; fi;
if [[ $key = "q" ]]; then echo -e "q"; fi; if [[ $key = "h" ]]; then echo -e "h"; fi;
if [[ $key = "c" ]]; then echo -e "c"; fi; if [[ $key = "a" ]]; then echo -e "a"; fi;
if [[ $key = $'\x20' ]]; then echo space; fi; if [[ $key = $'\x1B' ]]; then read -rsn2 key;
if [[ $key = [A ]]; then echo up; fi; if [[ $key = [B ]]; then echo down; fi; fi;
};
#####################
## toggler ##########
toggle_option() { arr_name=$1; eval " arr=(\"\${${arr_name}[@]}\")"; option=$2;
if [[ ${arr[option]} == true ]]; then arr[option]=
else arr[option]=true; fi; eval $arr_name='("${arr[@]}")'; };
retval=$1; IFS=';' read -r -a options <<< "$2"; if [[ -z $3 ]];
then unset defaults; else IFS=' ' read -r -a defaults <<< "$3"; fi;
selected=(); for ((i=0; i<${#options[@]}; i++)); do
selected+=("${defaults[i]:-false}"); printf "\n"; done
## determine current screen position for overwriting the options
lastrow=$(get_cursor_row); startrow=$(($lastrow - ${#options[@]}));
## ensure cursor and input echoing back on upon a ctrl+c during read -s
trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
cursor_blink_off; active=0; while true; do idx=0;
## print options by overwriting the last lines
for option in "${options[@]}"; do prefix="\e[0m [ ]";
if [[ ${selected[idx]} == true ]]; then prefix="\e[0m [$green*$re]"; fi
cursor_to $(($startrow + $idx)); if [ $idx -eq $active ];
then print_active "$option" "$prefix"; else print_inactive "$option" "$prefix"; fi; ((idx++)); done;
## user key control
case `key_input` in
enter) toggle_option selected $active;;
space) toggle_option selected $active;;
a) sel_all selected $active;;
c) break;;
h) halp;;
q) cd "$olpwd"; echo -e "\e[?25h"; break; return &>/dev/null;;
up) ((active--)); if [ $active -lt 0 ]; then active=$((${#options[@]} - 1)); fi;;
down) ((active++)); if [ $active -ge ${#options[@]} ]; then active=0; fi;;
esac; done; cursor_to $lastrow; echo; cursor_blink_on; eval $retval='("${selected[@]}")'; }
####################
## select all ######
sel_all() { arr_name=$1; eval " arr=(\"\${${arr_name}[@]}\")"; option=$2;
if [[ ${arr} == true ]]; then for oi in ${!arr[@]}; do arr[oi]=; done; else
for oi in ${!arr[@]}; do arr[oi]=true; arr[-1]=""; done; fi; eval $arr_name='("${arr[@]}")'; }
#####################
## help-section ####
halp() { echo -e '\n\n\e[6m'$cyan'--\e[37m bash-menu '$c2' \n
-- use as such: \n\nmenu "option1 option2 opt..." "command" "de" \n
if no args are made default options are current folder contents.
"bash" is default command. \ndefault deriotion if second line from file if readable. \else file class is\displayed.\n\n'$cyan'--'$re'\nhttps://github.com/aeniks\n'$cyan'--'$re'
enjoy!\n'$c2'\n\n\n\n['$cyan'Q'$re']uit\n\n\n\n'|less -JR --use-color --tilde --quotes=c; };
#####################
checkbox SELECTED "$OPTIONS_STRING"; ######## << call functions
for i in "${!SELECTED[@]}"; do if [ "${SELECTED[$i]}" == "true" ];
then CHECKED+=("${OPTIONS_VALUES[$i]}"); fi; done;
## confirm ##########
if [ -z $CHECKED ]; then
echo -e "\n \e[4;32mYou chose:\e[0m nothing"; cd "$olpwd";
echo -ne "\n $c2 Try again? \e[2m[\e[0my\e[2m/\e[0mN\e[2m]\e[0m ";
read -n1 -ep "" "yn";
if [ "$yn" != "${yn#[Yy]}" ];
then mnu "$1" "$2" "$3" "$4"; return 0;
else cd "$olpwd"; echo -e "\e[?25h\n Nope\n"; return 0; fi
else
echo -e "\n \e[4;32mYou chose:\n\e[0m${CHECKED[@]/#/\\n" "}";
#echo -ne "\n $c2 Current command to execute is: $cyan$ex$re "
echo -ne "\n $c2 Do you wish to proceed? \e[2m[\e[0mY\e[2m/\e[0mn\e[2m]\e[0m ";
read -n1 -ep "" "yn"; if [ "$yn" != "${yn#[Nn]}" ]; then
cd "$olpwd"; echo -e "\e[?25h\n Nope\n"; return 0; else echo -e "\n $c2 OK";
## after ############
## EXECUTE ##########
printf " $c2 Command:"; read -rep " " -i "$ex" "ex";
for i in "${CHECKED[@]}"; do $ex $i; printf " "; done; 
printf "\nGG\n";
#for i in "${CHECKED[@]}"; do echo -e "\e[0m $c2 Installing $i \e[2m"; sleep 0.1;
#[ "$2" ]|| bash $i; [ "$2" ]&&
#$ex $i;
echo -e "\e[0m $c2 $i$green OK$re \e[2m";
cd $olpwd; echo -e "\n Done"; fi;
echo -e "\e[0m"; fi;
}; ## END MENU ##
#################
## 12_ menu #####
#################
rollup() { for i in $(seq $((LINES-4))); do printf "\n"; sleep 0.1; done; 
printf "\n\e[2H\e[28m\n"; } 
mnu; 
##
printf "\n\n    gg  \n\n\n\n\n\n"; 
return &>/dev/null; break &>/dev/null; return &>/dev/null; exit 0;
##  -->
