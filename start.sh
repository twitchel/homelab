#!/usr/bin/env bash

# Current Working Directory
PWD=$(pwd)

# Bootstrapping
source ./scripts/bootstrap.sh "$PWD"

# Lets go!
echo -e " \033[33;5m    ____                    _   _                      _       _         \033[0m"
echo -e " \033[33;5m   |  _ \  __ _ _ __  ___  | | | | ___  _ __ ___   ___| | __ _| |__      \033[0m"
echo -e " \033[33;5m   | | | |/ _\` | '_ \/ __| | |_| |/ _ \| '_ \` _ \ / _ \ |/ _\` | '_ \  \033[0m"
echo -e " \033[33;5m   | |_| | (_| | | | \__ \ |  _  | (_) | | | | | |  __/ | (_| | |_) |    \033[0m"
echo -e " \033[33;5m   |____/ \__,_|_| |_|___/ |_| |_|\___/|_| |_| |_|\___|_|\__,_|_.__/     \033[0m"

echo -e " \033[36;5m                _  _________   ___         _        _ _                  \033[0m"
echo -e " \033[36;5m               | |/ |__ / __| |_ _|_ _  __| |_ __ _| | |                 \033[0m"
echo -e " \033[36;5m               | ' < |_ \__ \  | || ' \(_-|  _/ _\` | | |                \033[0m"
echo -e " \033[36;5m               |_|\_|___|___/ |___|_||_/__/\__\__,_|_|_|                 \033[0m"
echo -e " \033[36;5m                                                                         \033[0m"
echo -e " \033[32;5m            Influenced by: https://youtube.com/@jims-garage              \033[0m"
echo -e " \033[32;5m                                                                         \033[0m"

# 1. Ensure required dependencies are installed
check_dependencies_installed

ask_before_running_task "🚀  Do you want to initialize the k3s cluster?"
if [[ $? -eq 0 ]]; then
  # 2. Initialize k3s cluster
  ./scripts/1-init-k3s/init-k3s.sh "$PWD"
fi
