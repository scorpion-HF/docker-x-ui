#!/bin/sh

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

confirm() {
    if [[ $# > 1 ]]; then
        echo && read -p "$1 [default$2]: " temp
        if [[ x"${temp}" == x"" ]]; then
            temp=$2
        fi
    else
        read -p "$1 [y/n]: " temp
    fi
    if [[ x"${temp}" == x"y" || x"${temp}" == x"Y" ]]; then
        return 0
    else
        return 1
    fi
}

confirm_restart() {
    confirm "Whether to restart the panel, restarting the panel will also restart x2ray" "y"
    if [[ $? == 0 ]]; then
        restart
    else
        show_menu
    fi
}

before_show_menu() {
    echo && echo -n -e "${yellow}Press enter to return to the main menu: ${plain}" && read temp
    show_menu
}

reset_user() {
    confirm "Are you sure you want to reset username and password to admin" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    /usr/local/x-ui/x-ui setting -username admin -password admin
    echo -e "Username and password have been reset to ${green}admin${plain}，Please restart the panel now"
    confirm_restart
}

reset_config() {
    confirm "Are you sure you want to reset all panel settings, account data will not be lost, username and password will not change" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    /usr/local/x-ui/x-ui setting -reset
    echo -e "All panel settings have been reset to default, please restart the panel now and use the default ${green}54321${plain} Port Access Panel"
    confirm_restart
}

set_port() {
    echo && echo -n -e "Enter port number[1-65535]: " && read port
    if [[ -z "${port}" ]]; then
        echo -e "${yellow}Cancelled${plain}"
        before_show_menu
    else
        /usr/local/x-ui/x-ui setting -port ${port}
        echo -e "After setting the port, please restart the panel now and use the newly set port ${green}${port}${plain} access panel"
        confirm_restart
    fi
}

restart() {
    sv restart x-ui
    before_show_menu
}
migrate_v2_ui() {
    /usr/local/x-ui/x-ui v2-ui
    before_show_menu
}

show_menu() {
    echo -e "
  ${green}x-ui Panel Management Script${plain}
--- https://blog.sprov.xyz/x-ui ---
  ${green}0.${plain} exit script
————————————————
  ${green}1.${plain} Reset username and password
  ${green}2.${plain} Reset panel settings
  ${green}3.${plain} Set panel port
  ${green}4.${plain} Migrate v2-ui account data to x-ui"
    echo && read -p "please enter selection [0-4]: " num

    case "${num}" in
        0) exit 0
        ;;
        1) reset_user
        ;;
        2) reset_config
        ;;
        3) set_port
        ;;
        4) migrate_v2_ui
        ;;
        *) echo -e "${red}Please enter the correct number [0-4]${plain}"
        ;;
    esac
}
show_menu
