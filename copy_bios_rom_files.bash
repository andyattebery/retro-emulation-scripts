#!/usr/bin/env bash

# Directory Paths
SOURCE_BIOS_DIR="nas-01:/mnt/storage/Games/System Files"
SOURCE_ROMS_DIR="nas-01:/mnt/storage/Games/ROMs"
MUOS_ROOT_DIR="/Volumes/SD2"
MINUI_ROOT_DIR="/Volumes/MINUI"
ESDE_ROMS_DIR="/Volumes/Untitled/ES-DE ROMs"

# System Constants
readonly ARCADE="ARCADE"
readonly ATARI_2600="ATARI_2600"
readonly ATARI_5200="ATARI_5200"
readonly ATARI_7800="ATARI_7800"
readonly ATARI_JAGUAR="ATARI_JAGUAR"
readonly ATARI_LYNX="ATARI_LYNX"
readonly CBS_COLECOVISION="CBS_COLECOVISION"
readonly COMMODORE_64="COMMODORE_64"
readonly MICROSOFT_XBOX_360="MICROSOFT_XBOX_360"
readonly MICROSOFT_XBOX="MICROSOFT_XBOX"
readonly NEC_TURBOGRAFX_16="NEC_TURBOGRAFX_16"
readonly NEC_TURBOGRAFX_CD="NEC_TURBOGRAFX_CD"
readonly NINTENDO_3DS="NINTENDO_3DS"
readonly NINTENDO_64="NINTENDO_64"
readonly NINTENDO_DS="NINTENDO_DS"
readonly NINTENDO_FAMICOM_DISK_SYSTEM="NINTENDO_FAMICOM_DISK_SYSTEM"
readonly NINTENDO_GAME_BOY_ADVANCE="NINTENDO_GAME_BOY_ADVANCE"
readonly NINTENDO_GAME_BOY_COLOR="NINTENDO_GAME_BOY_COLOR"
readonly NINTENDO_GAME_BOY="NINTENDO_GAME_BOY"
readonly NINTENDO_GAMECUBE="NINTENDO_GAMECUBE"
readonly NINTENDO_NINTENDO_ENTERTAINMENT_SYSTEM="NINTENDO_NINTENDO_ENTERTAINMENT_SYSTEM"
readonly NINTENDO_POKEMON_MINI="NINTENDO_POKEMON_MINI"
readonly NINTENDO_SUPER_NINTENDO_ENTERTAINMENT_SYSTEM="NINTENDO_SUPER_NINTENDO_ENTERTAINMENT_SYSTEM"
readonly NINTENDO_SUPER_GAME_BOY="NINTENDO_SUPER_GAME_BOY"
readonly NINTENDO_SWITCH="NINTENDO_SWITCH"
readonly NINTENDO_WIIU="NINTENDO_WIIU"
readonly NINTENDO_WII="NINTENDO_WII"
readonly PICO_8="PICO_8"
readonly SEGA_32X="SEGA_32X"
readonly SEGA_CD="SEGA_CD"
readonly SEGA_DREAMCAST="SEGA_DREAMCAST"
readonly SEGA_GAME_GEAR="SEGA_GAME_GEAR"
readonly SEGA_GENESIS="SEGA_GENESIS"
readonly SEGA_MASTER_SYSTEM="SEGA_MASTER_SYSTEM"
readonly SEGA_NAMOI="SEGA_NAMOI"
readonly SEGA_SATURN="SEGA_SATURN"
readonly SEGA_SG_1000="SEGA_SG_1000"
readonly SNK_NEO_GEO="SNK_NEO_GEO"
readonly SNK_NEO_GEO_CD="SNK_NEO_GEO_CD"
readonly SNK_NEO_GEO_POCKET="SNK_NEO_GEO_POCKET"
readonly SNK_NEO_GEO_POCKET_COLOR="SNK_NEO_GEO_POCKET_COLOR"
readonly SONY_PLAYSTATION_2="SONY_PLAYSTATION_2"
readonly SONY_PLAYSTATION_3="SONY_PLAYSTATION_3"
readonly SONY_PLAYSTATION_PORTABLE="SONY_PLAYSTATION_PORTABLE"
readonly SONY_PLAYSTATION_VITA="SONY_PLAYSTATION_VITA"
readonly SONY_PLAYSTATION="SONY_PLAYSTATION"

# Source File Mappings
declare -rA SYSTEM_TO_BIOS_FILES_GLOB_MAP=(
  [$NEC_TURBOGRAFX_CD]="syscard*.pce"
  [$NINTENDO_FAMICOM_DISK_SYSTEM]="disksys.rom"
  [$NINTENDO_GAME_BOY_ADVANCE]="gba_bios.bin"
  [$NINTENDO_GAME_BOY_COLOR]="gbc_bios.bin"
  [$NINTENDO_GAME_BOY]="gb_bios.bin"
  [$NINTENDO_POKEMON_MINI]="bios.min"
  [$NINTENDO_SUPER_GAME_BOY]="sgb.bios"
  [$SEGA_CD]="bios_CD_*.bin"
  [$SEGA_DREAMCAST]="dc"
  [$SONY_PLAYSTATION_2]="SCPH-70012.bin"
  [$SONY_PLAYSTATION_VITA]="PS*UPDAT.PUP"
  [$SONY_PLAYSTATION]="psxonpsp660.bin"
)

declare -rA SYSTEM_TO_SOURCE_ROMS_SUBDIRECTORY_MAP=(
  [$ARCADE]='MAME 0.274 ROMs (non-merged)'
  [$ATARI_2600]='Atari - 2600'
  [$ATARI_5200]='Atari - 5200'
  [$ATARI_7800]='Atari - 7800'
  [$ATARI_JAGUAR]='Atari - Jaguar'
  [$ATARI_LYNX]='Atari - Lynx'
  [$CBS_COLECOVISION]='CBS - Colecovision'
  [$COMMODORE_64]='Commodore - 64'
  [$NEC_TURBOGRAFX_16]='NEC - PC Engine - TurboGrafx 16'
  [$NEC_TURBOGRAFX_CD]='NEC - PC Engine CD - TurboGrafx-CD'
  [$NINTENDO_64]='Nintendo - Nintendo 64'
  [$NINTENDO_FAMICOM_DISK_SYSTEM]='Nintendo - Famicom Disk System'
  [$NINTENDO_GAME_BOY_ADVANCE]='Nintendo - Game Boy Advance'
  [$NINTENDO_GAME_BOY_COLOR]='Nintendo - Game Boy Color'
  [$NINTENDO_GAME_BOY]='Nintendo - Game Boy'
  [$NINTENDO_GAMECUBE]='Nintendo - GameCube'
  [$NINTENDO_NINTENDO_ENTERTAINMENT_SYSTEM]='Nintendo - Nintendo Entertainment System'
  [$NINTENDO_SUPER_NINTENDO_ENTERTAINMENT_SYSTEM]='Nintendo - Super Nintendo Entertainment System'
  [$NINTENDO_SWITCH]='Nintendo - Nintendo Switch'
  [$NINTENDO_WII]='Nintendo - Wii'
  [$NINTENDO_WIIU]='Nintendo - WiiU'
  [$SEGA_32X]='Sega - Sega 32X'
  [$SEGA_CD]='Sega - Sega CD'
  [$SEGA_DREAMCAST]='Sega - Dreamcast'
  [$SEGA_GAME_GEAR]='Sega - Game Gear'
  [$SEGA_GENESIS]='Sega - Genesis'
  [$SEGA_MASTER_SYSTEM]='Sega - Master System'
  [$SEGA_SG_1000]='Sega - SG-1000'
  [$SONY_PLAYSTATION]='Sony - Playstation'
)

# Copy Functions

# Copies BIOS files for systems to destination directories
# Arguments:
#   1. Name of systems array
#   2. Name of function that inputs a system and outputs the destination directory for the system
copy_bios_files() {
  local -n systems="$1"
  local get_destination_system_bios_directory_function_name="$2"

  for system in "${systems[@]}"
  do
    if [[ -v SYSTEM_TO_BIOS_FILES_GLOB_MAP[$system] ]]; then
      local source_system_bios_files_glob=(${SYSTEM_TO_BIOS_FILES_GLOB_MAP[$system]})
      local destination_system_bios_directory=$(eval "$get_destination_system_bios_directory_function_name" $system)
      echo "rsync -avP \"$SOURCE_BIOS_DIR/$source_system_bios_files_glob\" \"$destination_system_bios_directory/\""
      #rsync -avP "$SOURCE_BIOS_DIR/$source_system_bios_files_glob" "$destination_system_bios_directory/"
    fi

  done
}

# Copies ROM files for systems to destination directories with the option of copying source directory
# Arguments:
#   1. Name of systems array
#   2. Name of function that inputs a system and outputs the destination directory for the system
#   3. Bool that determines if the source directory should be copied to the destination
#      rather than just the contents
copy_rom_files() {
  local -n systems="$1"
  local get_destination_system_rom_directory_function_name="$2"
  local should_copy_source_directory=${3:-a_string_value_that_is_not_true}

  for system in "${systems[@]}"; do
    if [[ -v SYSTEM_TO_SOURCE_ROMS_SUBDIRECTORY_MAP[$system] ]]; then
      local source_system_rom_dir="${SYSTEM_TO_SOURCE_ROMS_SUBDIRECTORY_MAP[$system]}"
      if [ ! $should_copy_source_directory = true ]; then
        source_system_rom_dir="${source_system_rom_dir}/"
      fi
      local destination_system_rom_directory=$(eval "$get_destination_system_rom_directory_function_name" $system)
      echo "rsync -avP \"${SOURCE_ROMS_DIR}/${source_system_rom_dir}\" \"$destination_system_rom_directory/\""
      rsync -avP "${SOURCE_ROMS_DIR}/${source_system_rom_dir}" "$destination_system_rom_directory/"
    else
      echo "No source ROMS for $system."
    fi

  done
}

# MinUI (https://github.com/shauninman/MinUI)
declare -ra ENABLED_MINUI_SYSTEMS=(
  # Base
  $NINTENDO_GAME_BOY
  $NINTENDO_GAME_BOY_ADVANCE
  $NINTENDO_GAME_BOY_COLOR
  $NINTENDO_NINTENDO_ENTERTAINMENT_SYSTEM
  $NINTENDO_SUPER_NINTENDO_ENTERTAINMENT_SYSTEM
  $SEGA_GENESIS
  $SONY_PLAYSTATION
  # Extras
  # $NEC_TURBOGRAFX_16
  # $NINTENDO_POKEMON_MINI
  # $NINTENDO_SUPER_GAME_BOY
  # $PICO_8
  $SEGA_GAME_GEAR
  # $SEGA_MASTER_SYSTEM
  # $SNK_NEO_GEO_POCKET
)

declare -rA SYSTEM_TO_MINUI_BIOS_SUBDIR_MAP=(
  [$NEC_TURBOGRAFX_CD]="PCE"
  [$NINTENDO_GAME_BOY_ADVANCE]="GBA"
  [$NINTENDO_GAME_BOY_COLOR]="GBC"
  [$NINTENDO_GAME_BOY]="GB"
  [$NINTENDO_POKEMON_MINI]="PKM"
  [$NINTENDO_SUPER_GAME_BOY]="SGB"
  [$SEGA_DREAMCAST]="."
  [$SONY_PLAYSTATION]="PS"
)

get_system_minui_bios_directory(){
  if [[ -v SYSTEM_TO_MINUI_BIOS_SUBDIR_MAP[$1] ]]; then
    echo "$MINUI_ROOT_DIR/Bios/${SYSTEM_TO_MINUI_BIOS_SUBDIR_MAP[$1]}"
    return 0
  fi
  return 1
}

declare -rA SYSTEM_TO_MINUI_ROMS_SUBDIR_MAP=(
  [$NEC_TURBOGRAFX_16]='TurboGrafx-16 (PCE)'
  [$NINTENDO_FAMICOM_DISK_SYSTEM]='Nintendo Entertainment System (FC)'
  [$NINTENDO_GAME_BOY]='Game Boy (GB)'
  [$NINTENDO_GAME_BOY_ADVANCE]='Game Boy Advance (GBA)'
  [$NINTENDO_GAME_BOY_COLOR]='Game Boy Color (GBC)'
  [$NINTENDO_NINTENDO_ENTERTAINMENT_SYSTEM]='Nintendo Entertainment System (FC)'
  [$NINTENDO_SUPER_NINTENDO_ENTERTAINMENT_SYSTEM]='Super Nintendo Entertainment System (SFC)'
  [$SEGA_GAME_GEAR]='Sega Game Gear (GG)'
  [$SEGA_GENESIS]='Sega Genesis (MD)'
  [$SEGA_MASTER_SYSTEM]='Sega Master System (SMS)'
  [$SEGA_32X]='Sega 32X (THIRTYTWOX)'
  [$SEGA_CD]='Sega CD (MD)'
  [$SONY_PLAYSTATION]='Sony PlayStation (PS)'
)

get_system_minui_roms_directory(){
  if [[ -v SYSTEM_TO_MINUI_ROMS_SUBDIR_MAP[$1] ]]; then
    echo "$MINUI_ROOT_DIR/Roms/${SYSTEM_TO_MINUI_ROMS_SUBDIR_MAP[$1]}"
    return 0
  fi
  return 1
}

copy_to_minui() {
  copy_bios_files ENABLED_MINUI_SYSTEMS "get_system_minui_bios_directory"
  copy_rom_files ENABLED_MINUI_SYSTEMS "get_system_minui_roms_directory" false
}

# MuOS (https://muos.dev)
declare -ra ENABLED_MUOS_SYSTEMS=(
  $NINTENDO_GAME_BOY
  $NINTENDO_GAME_BOY_ADVANCE
  $NINTENDO_GAME_BOY_COLOR
  $NINTENDO_NINTENDO_ENTERTAINMENT_SYSTEM
  $NINTENDO_SUPER_NINTENDO_ENTERTAINMENT_SYSTEM
  $SEGA_GAME_GEAR
  $SEGA_GENESIS
  $SONY_PLAYSTATION
)

get_system_muos_bios_directory(){
  echo "$MUOS_ROOT_DIR/MUOS/Bios"
}

get_system_muos_roms_directory(){
  echo "$MUOS_ROOT_DIR/ROMS"
}

copy_to_muos() {
  copy_bios_files ENABLED_MUOS_SYSTEMS "get_system_muos_bios_directory"
  copy_rom_files ENABLED_MUOS_SYSTEMS "get_system_muos_roms_directory" true
}

# ES-DE (EmulationStation Desktop Edition) (https://www.es-de.org)
declare -a ENABLED_ESDE_SYSTEMS=(
  $NINTENDO_64
  $NINTENDO_FAMICOM_DISK_SYSTEM
  $NINTENDO_GAME_BOY_ADVANCE
  $NINTENDO_GAME_BOY_COLOR
  $NINTENDO_GAME_BOY
  $NINTENDO_GAMECUBE
  $NINTENDO_NINTENDO_ENTERTAINMENT_SYSTEM
  $NINTENDO_SUPER_NINTENDO_ENTERTAINMENT_SYSTEM
  $NINTENDO_SWITCH
  $NINTENDO_WII
  $NINTENDO_WIIU
  $SEGA_32X
  # $SEGA_CD
  $SEGA_DREAMCAST
  $SEGA_GAME_GEAR
  $SEGA_GENESIS
  $SEGA_MASTER_SYSTEM
  $SEGA_SG_1000
  $SONY_PLAYSTATION
)

declare -rA SYSTEM_TO_ESDE_ROMS_SUBDIR_MAP=(
  [$ARCADE]='arcade'
  [$ATARI_2600]='atari2600'
  [$ATARI_5200]='atari5200'
  [$ATARI_7800]='atari7800'
  [$ATARI_JAGUAR]='atarijaguar'
  [$ATARI_LYNX]='atarilynx'
  [$CBS_COLECOVISION]='colecovision'
  [$COMMODORE_64]='c64'
  [$NEC_TURBOGRAFX_CD]='tg-cd'
  [$NEC_TURBOGRAFX_16]='tg16'
  [$NINTENDO_3DS]='n3ds'
  [$NINTENDO_DS]='nds'
  [$NINTENDO_FAMICOM_DISK_SYSTEM]='famicom'
  [$NINTENDO_GAME_BOY]='gb'
  [$NINTENDO_GAME_BOY_ADVANCE]='gba'
  [$NINTENDO_GAME_BOY_COLOR]='gbc'
  [$NINTENDO_GAMECUBE]='gc'
  [$NINTENDO_64]='n64'
  [$NINTENDO_NINTENDO_ENTERTAINMENT_SYSTEM]='nes'
  [$NINTENDO_POKEMON_MINI]='pokemini'
  [$NINTENDO_SUPER_NINTENDO_ENTERTAINMENT_SYSTEM]='snes'
  [$NINTENDO_SWITCH]='switch'
  [$NINTENDO_WII]='wii'
  [$NINTENDO_WIIU]='wiiu'
  [$PICO_8]='pico8'
  [$SEGA_DREAMCAST]='dreamcast'
  [$SEGA_GAME_GEAR]='gamegear'
  [$SEGA_GENESIS]='genesis'
  [$SEGA_MASTER_SYSTEM]='mastersystem'
  [$SEGA_32X]='sega32x'
  [$SEGA_CD]='segacd'
  [$SEGA_SATURN]='saturn'
  [$SEGA_SG_1000]='sg-1000'
  [$SNK_NEO_GEO]='neogeo'
  [$SNK_NEO_GEO_CD]='neogeocd'
  [$SNK_NEO_GEO_POCKET]='ngp'
  [$SNK_NEO_GEO_POCKET_COLOR]='ngpc'
  [$SONY_PLAYSTATION]='psx'
  [$SONY_PLAYSTATION_2]='ps2'
  [$SONY_PLAYSTATION_PORTABLE]='psp'
  [$SONY_PLAYSTATION_VITA]='psvita'
)

get_system_esde_roms_directory(){
  if [[ -v SYSTEM_TO_ESDE_ROMS_SUBDIR_MAP[$1] ]]; then
    echo "$ESDE_ROMS_DIR/${SYSTEM_TO_ESDE_ROMS_SUBDIR_MAP[$1]}"
    return 0
  fi
  return 1
}

copy_to_esde() {
  copy_rom_files ENABLED_ESDE_SYSTEMS "get_system_esde_roms_directory" false
}

# Main
destination_type=$(echo "$1" | tr '[:upper:]' '[:lower:]')

case "$destination_type" in
  "esde")
    copy_to_esde
    ;;
  "minui")
    copy_to_minui
    ;;
  "muos")
    copy_to_muos
    ;;
  *)
    echo "$1 is not a supported destination OS/application."
    ;;
esac
