#!/bin/bash

# Initialize counters
num_working=0
num_bad_ping=0
num_bad_btcli=0
num_bad_wss=0
num_no_ip=0

# Get the current date for the filename
current_date=$(date +"%Y%m%d")
underperforming_file="underperforming_${current_date}.txt"

# Prepare the underperforming miners file with a header
echo -e "DateTime\tUID\tEmission\tReason" > "$underperforming_file"

# Get the total number of miners (excluding header)
total_miners=$(($(wc -l < output.txt) - 1))
current_miner=0

echo "Testing $total_miners miners/validators..."

# Read the miners from output.txt, skipping the header
{
  read -r header_line  # Read and discard the header line
  while IFS=$'\t' read -r uid emission axon hotkey coldkey; do
      current_miner=$((current_miner + 1))
      echo "Testing miner $current_miner/$total_miners (UID: $uid)..."

      # Check if AXON field is empty or invalid
      if [[ -z "$axon" || "$axon" == ":" ]]; then
          num_no_ip=$((num_no_ip + 1))
          current_datetime=$(date +"%Y-%m-%d %H:%M:%S")
          echo -e "$current_datetime\t$uid\t$emission\tNO_AXON_IP" >> "$underperforming_file"
          continue
      fi

      # Extract IP and PORT from AXON
      IFS=":" read -r ip port <<< "$axon"

      if [[ -z "$ip" || -z "$port" ]]; then
          num_no_ip=$((num_no_ip + 1))
          current_datetime=$(date +"%Y-%m-%d %H:%M:%S")
          echo -e "$current_datetime\t$uid\t$emission\tINVALID_AXON_IP" >> "$underperforming_file"
          continue
      fi

      # Test connection to IP:port using nc with a timeout of 3 seconds
      # Measure the time it takes to connect
      start_time=$(date +%s%N)
      nc -z -w3 "$ip" "$port" 2>/dev/null
      nc_exit_status=$?
      end_time=$(date +%s%N)
      elapsed_time=$(( (end_time - start_time)/1000000 ))  # in milliseconds

      if [ $nc_exit_status -ne 0 ] || [ $elapsed_time -gt 3000 ]; then
          num_bad_ping=$((num_bad_ping + 1))
          current_datetime=$(date +"%Y-%m-%d %H:%M:%S")
          echo -e "$current_datetime\t$uid\t$emission\tPING_FAILED_OR_SLOW (${elapsed_time}ms)" >> "$underperforming_file"
          continue
      fi

      # Run btcli s list with a timeout of 8 seconds and measure execution time
      start_time=$(date +%s%N)
      cmd_output=$(timeout 8 btcli s list --subtensor.network "$ip":"$port" 2>&1)
      btcli_exit_status=$?
      end_time=$(date +%s%N)
      btcli_elapsed_time=$(( (end_time - start_time)/1000000 ))  # in milliseconds

      if [ $btcli_exit_status -ne 0 ] || [ $btcli_elapsed_time -gt 8000 ]; then
          num_bad_btcli=$((num_bad_btcli + 1))
          current_datetime=$(date +"%Y-%m-%d %H:%M:%S")
          echo -e "$current_datetime\t$uid\t$emission\tBTCLI_FAILED_OR_SLOW (${btcli_elapsed_time}ms)" >> "$underperforming_file"
          continue
      fi

      # New Test: Run btcli s list with --subtensor.chain_endpoint wss://secure.subvortex.info:443
      start_time=$(date +%s%N)
      wss_output=$(timeout 8 btcli s list --subtensor.network "$ip":"$port" --subtensor.chain_endpoint wss://secure.subvortex.info:443 2>&1)
      wss_exit_status=$?
      end_time=$(date +%s%N)
      wss_elapsed_time=$(( (end_time - start_time)/1000000 ))  # in milliseconds

      if [ $wss_exit_status -ne 0 ] || [ $wss_elapsed_time -gt 8000 ]; then
          num_bad_wss=$((num_bad_wss + 1))
          current_datetime=$(date +"%Y-%m-%d %H:%M:%S")
          echo -e "$current_datetime\t$uid\t$emission\tWSS_FAILED_OR_SLOW (${wss_elapsed_time}ms)" >> "$underperforming_file"
          continue
      fi

      # Miner is considered working
      num_working=$((num_working + 1))
      echo "Miner UID $uid is working. (Connection: ${elapsed_time}ms, btcli: ${btcli_elapsed_time}ms, WSS: ${wss_elapsed_time}ms)"

  done
} < output.txt  # Redirect the file as input to the block

# Display summary
echo "====== Summary ======"
echo "Working Miners: $num_working"
echo "Miners with No AXON IP: $num_no_ip"
echo "Miners with Bad Connection: $num_bad_ping"
echo "Miners with Bad btcli Response: $num_bad_btcli"
echo "Miners with Bad WSS Response: $num_bad_wss"
echo "Underperforming miners details are saved in '$underperforming_file'"
