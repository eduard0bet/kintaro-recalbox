# Kintaro for Recalbox v9.0+

Version 1.7.0 stable

- Tested on Super Kuma 9000
- tested on Raspberry Pi3 B
- tested on Recalbox 9.2.3 pulstar

Creator: Kintaro
Author: Michael Kirsch
Maintainer: Eduardo Betancourt
This is the official Kintaro script for Recalbox.

## Changelog: 

v1.6.4 stable | 02/23/2025  | tested on Recalbox 9.2.3 pulstar

- Update the .sh file to improve loging and status
- Improved the fan meassure in temperature
- Improved the kintaro.py file some minor tweaks

v1.6.3 stable | 11/26/2023  | tested on Recalbox 9.1

- Fixed some issues with the reset button.
- Fixed issue when the script make the led never stop blinking.
- Cleaning the code and delete unused code.

v1.6.2 | 08/08/2023 

- I make an update on some script mainly on .sh file to make it work with recalbox 9.0
- it works flawless from first install and reboot.
- remember maintain the power button 'ON" on the first reboot o power supply connect.

## Issues:
Let me know.

## Features

- LED power indicator control
- Fan speed control with temperature monitoring
- Power and reset button functionality
- Compatible with RecalBox 9.0

## Installation

-  THE POWER BUTTON HAS TO BE IN "ON" POSITION IN SCRIPT INSTALLATION

### Quick Install (Recommended)

1. Connect to your Raspberry Pi via SSH:
```bash
ssh root@[your-pi-ip-address]
```

2. Run the installation command:
```bash
curl -sSL https://raw.githubusercontent.com/eduard0bet/kintaro-recalbox/main/install.sh | sudo bash
```

The script will automatically:
- Mount the system in write mode
- Install all necessary files
- Set up proper permissions
- Restart your system to apply changes

### Manual Installation

If you prefer to install manually, follow these steps:

1. Connect to your Raspberry Pi via SSH:
```bash
ssh root@[your-pi-ip-address]
```

2. Mount the system in write mode:
```bash
mount -o remount,rw /
```

3. Create the necessary directory:
```bash
mkdir -p /opt/Kintaro
```

4. Copy the files:
```bash
curl -o /opt/Kintaro/kintaro.py https://raw.githubusercontent.com/eduard0bet/kintaro-recalbox/main/kintaro.py
curl -o /etc/init.d/S100kintaro.sh https://raw.githubusercontent.com/eduard0bet/kintaro-recalbox/main/S100kintaro.sh
```

5. Set proper permissions:
```bash
chmod 755 /opt/Kintaro/kintaro.py
chmod 755 /etc/init.d/S100kintaro.sh
```

6. Reboot your system:
```bash
reboot
```

## Usage

Once installed, the controller will automatically:
- Start on system boot
- Control the case fan based on temperature
- Handle power and reset button functions
- Manage the power LED

## Troubleshooting

Check the log file for any issues:
```bash
cat /tmp/kintaro.log
```

To restart the controller service:
```bash
/etc/init.d/S100kintaro.sh restart
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

Based on the original Kintaro Super Kuma 9000 case controller, modified and adapted for RecalBox.

## Support

If you encounter any issues, please open an issue in this repository.
If need more info or help, hit me up eduardo@koudrs.com