#!/usr/bin/env sh

# Directory Paths
SOURCE_BIOS_DIR="nas-01:/mnt/storage/Games/System Files"
SOURCE_ROMS_DIR="nas-01:/mnt/storage/Games/ROMs"
SD_CARD_BIOS_DIR="/Volumes/SD2/MUOS/Bios"
SD_CARD_ROMS_DIR="/Volumes/SD2/ROMS"

# Copy BIOS files
rsync -avP "$SOURCE_BIOS_DIR"/"gb_bios.bin" "$SD_CARD_BIOS_DIR"
rsync -avP "$SOURCE_BIOS_DIR"/"gbc_bios.bin" "$SD_CARD_BIOS_DIR"
rsync -avP "$SOURCE_BIOS_DIR"/"gba_bios.bin" "$SD_CARD_BIOS_DIR"
rsync -avP "$SOURCE_BIOS_DIR"/"bios_CD_*.bin" "$SD_CARD_BIOS_DIR"
rsync -avP "$SOURCE_BIOS_DIR"/"psxonpsp660.bin" "$SD_CARD_BIOS_DIR"
rsync -avP "$SOURCE_BIOS_DIR"/"syscard3.pce" "$SD_CARD_BIOS_DIR"
rsync -avP "$SOURCE_BIOS_DIR"/"disksys.rom" "$SD_CARD_BIOS_DIR"
rsync -avP "$SOURCE_BIOS_DIR"/"bios.min" "$SD_CARD_BIOS_DIR"
rsync -avP "$SOURCE_BIOS_DIR"/"sgb.bios" "$SD_CARD_BIOS_DIR"

# Copy ROMs
rsync -avP "$SOURCE_ROMS_DIR"/"Nintendo - Game Boy" "$SD_CARD_ROMS_DIR"/
rsync -avP "$SOURCE_ROMS_DIR"/"Nintendo - Game Boy Advance" "$SD_CARD_ROMS_DIR"/
rsync -avP "$SOURCE_ROMS_DIR"/"Nintendo - Game Boy Color" "$SD_CARD_ROMS_DIR"/"Game Boy Color (GBC)"/
rsync -avP "$SOURCE_ROMS_DIR"/"Nintendo - Nintendo Entertainment System" "$SD_CARD_ROMS_DIR"/
rsync -avP "$SOURCE_ROMS_DIR"/"Nintendo - Super Nintendo Entertainment System" "$SD_CARD_ROMS_DIR"/
rsync -avP "$SOURCE_ROMS_DIR"/"Sega - Game Gear" "$SD_CARD_ROMS_DIR"/"Sega Game Gear (GG)"/
rsync -avP "$SOURCE_ROMS_DIR"/"Sega - Genesis" "$SD_CARD_ROMS_DIR"/"Sega Genesis (MD)"/
rsync -avP "$SOURCE_ROMS_DIR"/"Sega - Master System" "$SD_CARD_ROMS_DIR"/
rsync -avP "$SOURCE_ROMS_DIR"/"Sega - Sega 32X" "$SD_CARD_ROMS_DIR"/
rsync -avP "$SOURCE_ROMS_DIR"/"Sega - Sega CD" "$SD_CARD_ROMS_DIR"/
