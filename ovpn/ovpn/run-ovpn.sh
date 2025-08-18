#!/bin/bash

# --- Configuration ---
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
BASE_DIR="$SCRIPT_DIR"
CONFIGS_DIR="$BASE_DIR/configs"
OVPN_PID_FILE="/tmp/current_ovpn_script.pid"
OVPN_LOG_FILE="/tmp/current_ovpn_script.log"

# --- Color Codes ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Helper Functions ---
cleanup() {
  echo -e "\n${YELLOW}Cleaning up...${NC}"
  if [ -f "$OVPN_PID_FILE" ]; then
    local ovpn_pid
    ovpn_pid=$(cat "$OVPN_PID_FILE")
    if ps -p "$ovpn_pid" >/dev/null 2>&1; then
      echo -e "${YELLOW}Stopping OpenVPN (PID: $ovpn_pid)...${NC}"
      sudo kill "$ovpn_pid"
      sleep 2
      if ps -p "$ovpn_pid" >/dev/null 2>&1; then
        echo -e "${YELLOW}OpenVPN did not stop gracefully, sending SIGKILL...${NC}"
        sudo kill -9 "$ovpn_pid"
      fi
    else
      echo "OpenVPN process (PID: $ovpn_pid) was already stopped."
    fi
    sudo rm -f "$OVPN_PID_FILE"
  else
    echo "No active OpenVPN PID file found."
  fi
  sudo rm -f "$OVPN_LOG_FILE"
  echo "Cleanup complete."
  tput cnorm
  exit 0
}

trap cleanup SIGINT SIGTERM

# Check configs directory is exists
if [ ! -d "$CONFIGS_DIR" ]; then
  echo -e "${RED}Error: Configs directory '$CONFIGS_DIR' not found.${NC}"
  exit 1
fi

# Check openvpn is installed
if ! command -v openvpn &>/dev/null; then
  echo -e "${RED}Error: OpenVPN is not installed. Please install it first.${NC}"
  exit 1
fi

# Check if the script is already running in another terminal if yes disconned it
if [ -f "$OVPN_PID_FILE" ]; then
  if ps -p "$(cat "$OVPN_PID_FILE")" >/dev/null 2>&1; then
    echo -e "${YELLOW}An OpenVPN connection managed by this script is already active (PID: $(cat "$OVPN_PID_FILE")).${NC}"
    echo -e "${YELLOW}Run this script with 'disconnect' argument to stop it, or manually kill the process and remove $OVPN_PID_FILE.${NC}"
    read -rp "Do you want to try to disconnect the current session? (y/N): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      cleanup
    fi
    exit 0
  else
    echo -e "${YELLOW}Found stale PID file. Cleaning up...${NC}"
    sudo rm -f "$OVPN_PID_FILE"
    sudo rm -f "$OVPN_LOG_FILE"
  fi
fi

# if user run this script with disconned arg (./run-ovpn.sh disconned) then the script kill all other ovpn processes
if [[ "$1" == "disconnect" ]]; then
  echo "Disconnect argument received."
  cleanup
  exit 0
fi

# map and create the select menu options
mapfile -t ovpn_files_full_path < <(find "$CONFIGS_DIR" -maxdepth 1 -type f -name "*.ovpn" -print)

if [ ${#ovpn_files_full_path[@]} -eq 0 ]; then
  echo -e "${RED}Error: No .ovpn files found in '$CONFIGS_DIR'.${NC}"
  exit 1
fi

options=()
for f_path in "${ovpn_files_full_path[@]}"; do
  options+=("$(basename "$f_path")")
done
options+=("Quit")

echo -e "${BLUE}Available OpenVPN Configurations:${NC}"
PS3=$'\nPlease select a configuration (number): '
select opt_basename in "${options[@]}"; do
  if [[ "$opt_basename" == "Quit" ]]; then
    echo "Exiting."
    exit 0
  fi

  selected_ovpn_file_fullpath=""
  for f_path in "${ovpn_files_full_path[@]}"; do
    if [[ "$(basename "$f_path")" == "$opt_basename" ]]; then
      selected_ovpn_file_fullpath="$f_path"
      break
    fi
  done

  if [[ -n "$selected_ovpn_file_fullpath" ]] && [[ -f "$selected_ovpn_file_fullpath" ]]; then
    echo -e "${GREEN}You selected: $opt_basename${NC}"
    break
  else
    echo -e "${RED}Invalid option '$REPLY'. Please try again.${NC}"
  fi
done

if [[ -z "$selected_ovpn_file_fullpath" ]]; then
  echo -e "${RED}No configuration selected. Exiting.${NC}"
  exit 1
fi

# Check openvpn has any auth file text if yes include it in the ovpn command:
auth_arg_value=""
auth_file_txt_path="${selected_ovpn_file_fullpath%.ovpn}.txt"

if [ -f "$auth_file_txt_path" ]; then
  if [ "$(wc -l <"$auth_file_txt_path")" -ge 1 ]; then
    echo -e "${GREEN}Using authentication file: $auth_file_txt_path${NC}"
    auth_arg_value="$auth_file_txt_path"
  else
    echo -e "${YELLOW}Warning: Auth file '$auth_file_txt_path' is empty. OpenVPN might prompt for credentials.${NC}"
  fi
else
  echo -e "${YELLOW}No .txt auth file found for $opt_basename. OpenVPN might prompt for credentials if required.${NC}"
fi

echo -e "\n${YELLOW}Attempting to connect with $opt_basename...${NC}"
echo -e "${BLUE}OpenVPN logs will be at: $OVPN_LOG_FILE${NC}"
echo -e "${BLUE}You might be prompted for your sudo password.${NC}"

sudo -v || {
  echo -e "${RED}Sudo privileges are required. Aborting.${NC}"
  exit 1
}

# --- Prepare log file ---
sudo touch "$OVPN_LOG_FILE"
sudo chown "$USER":"$USER" "$OVPN_LOG_FILE"

# --- Build OpenVPN command ---
openvpn_cmd_args=(
  "--config" "$selected_ovpn_file_fullpath"
  # "--daemon"
  "--writepid" "$OVPN_PID_FILE"
  "--log" "$OVPN_LOG_FILE"
  "--verb" "3"
  "--script-security" "2"
  "--down-pre"
  # "--up" "/etc/openvpn/update-resolv-conf"
  # "--down" "/etc/openvpn/update-resolv-conf"
)

if [[ -n "$auth_arg_value" ]]; then
  openvpn_cmd_args+=("--auth-user-pass" "$auth_arg_value")
fi

# --- Run OpenVPN ---
sudo openvpn "${openvpn_cmd_args[@]}"

echo -e "${YELLOW}Waiting for OpenVPN to establish connection (up to 60 seconds)...${NC}"
SECONDS=0
connected=false
initial_connect_check_delay=60

tput civis

while [ $SECONDS -lt $initial_connect_check_delay ]; do
  if [ -f "$OVPN_PID_FILE" ] && ps -p "$(cat "$OVPN_PID_FILE")" >/dev/null 2>&1; then
    if grep -q "Initialization Sequence Completed" "$OVPN_LOG_FILE"; then
      echo -e "\n${GREEN}CONNECTED to $opt_basename! (PID: $(cat "$OVPN_PID_FILE"))${NC}"
      connected=true
      break
    elif grep -q -E "AUTH_FAILED|Cannot resolve host address|TLS Error: TLS handshake failed" "$OVPN_LOG_FILE"; then
      echo -e "\n${RED}CONNECTION FAILED for $opt_basename. Check log: $OVPN_LOG_FILE${NC}"
      cleanup
      tput cnorm
      exit 1
    fi
  fi
  echo -n -e "${YELLOW}.${NC}"
  sleep 1
done

tput cnorm

if ! $connected; then
  echo -e "\n${RED}Failed to confirm connection to $opt_basename within $initial_connect_check_delay seconds.${NC}"
  echo -e "${RED}Please check the log file: $OVPN_LOG_FILE${NC}"
  cleanup
  exit 1
fi

echo -e "${BLUE}Monitoring connection. Press Ctrl+C to disconnect and exit.${NC}"
while true; do
  if ! ([ -f "$OVPN_PID_FILE" ] && ps -p "$(cat "$OVPN_PID_FILE")" >/dev/null 2>&1); then
    echo -e "\n${RED}DISCONNECTED: OpenVPN process is no longer running.${NC}"
    sudo rm -f "$OVPN_PID_FILE"
    break
  fi
  echo -n -e "${GREEN}Connected.${NC} (Checking status every 10s) \r"
  sleep 10
done

cleanup
exit 0
