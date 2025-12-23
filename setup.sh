#!/bin/bash

echo "Select setup type:"
echo "1) Minimal setup (default)"
echo "2) Full setup"
echo "3) Termux setup"
read -r -p "Enter choice (1 or 2, press Enter for minimal): " choice

# If no input, default to 1
choice=${choice:-1}

case $choice in
1 | "")
  echo "Running minimal setup..."
  # === Commands for minimal setup ===
  . ./scripts/setup_minimal.sh
  echo "Minimal setup completed."
  ;;
2)
  echo "Running full setup..."
  # === Commands for full setup ===
  . ./scripts/setup_full.sh
  echo "Full setup completed."
  ;;
3)
  echo "Running Termux setup..."
  # === Commands for full setup ===
  . ./scripts/setup_termux.sh
  echo "Termux setup completed."
  ;;
*)
  echo "Invalid choice. Exiting."
  exit 1
  ;;
esac
