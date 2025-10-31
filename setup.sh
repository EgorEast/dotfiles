#!/bin/bash

echo "Select setup type:"
echo "1) Full setup"
echo "2) Minimal setup (default)"
read -r -p "Enter choice (1 or 2, press Enter for minimal): " choice

# If no input, default to 2
choice=${choice:-2}

case $choice in
1)
  echo "Running full setup..."
  # === Commands for full setup ===
  . ./scripts/setup_full.sh
  echo "Full setup completed."
  ;;
2 | "")
  echo "Running minimal setup..."
  # === Commands for minimal setup ===
  . ./scripts/setup_minimal.sh
  echo "Minimal setup completed."
  ;;
*)
  echo "Invalid choice. Exiting."
  exit 1
  ;;
esac
