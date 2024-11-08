# SubVoretex Miner Validation Testing 

## Overview

This repository contains a script that performs analysis on miners in the SubVortex subnet. The script first extracts current metagraph data from the Bittensor network, then evaluates the performance of each miner based on their connectivity and responsiveness. The entire process is automated into a single script, making it easier to manage and monitor miner activity.

## Features

- **Directory Creation by Date**: Automatically creates a new directory named with the current date to store all output files generated during the script run.
- **Metagraph Data Extraction**: Runs a Python script to extract the latest metagraph data from the SubVortex network, saving the processed data into an output file (`output.txt`).
- **Miner Testing**: Evaluates each miner's connectivity and responsiveness by running various tests, including network connection checks and WebSocket response times.
- **Logs Underperforming Miners**: Saves details of underperforming miners to a timestamped file (`underperforming_YYYYMMDD.txt`).

## Requirements

- **Bash**: The main script is written in Bash.
- **Python3**: Required to run the metagraph extraction and processing.
- **btcli**: A command-line tool for interacting with the Bittensor network.
- **netcat (nc)**: Used for connectivity testing.
- **timeout**: Used to limit the duration of connectivity and command tests.

Make sure all these dependencies are installed and available in your environment before running the script.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/TidalWavesNode/S7_Miner_Validation-Testing.git
   cd miner-analysis
   ```

2. Make the script executable:
   ```bash
   chmod +x Miner_Validation.sh
   ```

## Usage

Run the script with the following command:
```bash
./Miner_Validation.sh
```

This will:
1. Create a new directory named `subvortex_data_YYYYMMDD` where `YYYYMMDD` is today's date.
2. Extract metagraph data from the Bittensor network and save it in the new directory as `metagraph_output.txt` and `output.txt`.
3. Run tests on miners listed in `output.txt`, storing results in `underperforming_YYYYMMDD.txt` within the same directory.

## Outputs

- **Directory (`subvortex_data_YYYYMMDD`)**: Contains all output files generated during the run.
  - **`metagraph_output.txt`**: Raw data from the Bittensor network.
  - **`output.txt`**: Processed list of miners including UID, Emission, Axon, Hotkey, and Coldkey.
  - **`underperforming_YYYYMMDD.txt`**: Details of underperforming miners, including the reasons for underperformance and the time each test was conducted.

## Underperforming Miner Analysis
The script tests each miner based on the following criteria:
1. **No Axon IP**: Miner does not have an IP or has an invalid IP.
2. **Ping Test**: Checks the connectivity to the miner's IP:port with a timeout of 3 seconds.
3. **`btcli` Response**: Verifies if the miner responds to a `btcli s list` command within 8 seconds.
4. **WSS Test**: Runs `btcli s list` with a WebSocket chain endpoint and expects a response within 8 seconds.

If a miner fails any of these checks, it is recorded in the `underperforming` file along with the time of the test.

## Example Output
The script's output directory (`subvortex_data_YYYYMMDD`) contains:
- **`underperforming_YYYYMMDD.txt`** example:
  ```
  DateTime             UID     Emission        Reason
  2023-11-08 15:30:12  1       6113618         NO_AXON_IP
  2023-11-08 15:30:15  2       5892037         PING_FAILED_OR_SLOW (3500ms)
  2023-11-08 15:30:18  3       5987693         BTCLI_FAILED_OR_SLOW (9000ms)
  2023-11-08 15:30:21  4       5936832         WSS_FAILED_OR_SLOW (8500ms)
  ```

## Customization
- **Change Network**: You can modify the network by adjusting the `btcli` commands in the script.
- **Timeouts**: Adjust the timeout values in the script to make the connectivity and command response checks more or less strict.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Contact
If you have any questions, feel free to contact the repository owner.

Happy mining!

