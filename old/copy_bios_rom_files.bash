#!/usr/bin/env bash

shopt -s nocasematch

# Directory Paths
#################
LOCAL_SOURCE_BIOS_DIR="/mnt/storage/Games/BIOS Files"
LOCAL_SOURCE_ROMS_DIR="/mnt/storage/Games/ROMs/Curated"
LOCAL_SOURCE_BATOCERA_ART_DIR="/mnt/storage/Games/Art/Batocera/"
REMOTE_SOURCE_HOSTNAME="nas-01"
REMOTE_SOURCE_BIOS_DIR="$REMOTE_SOURCE_HOSTNAME:$LOCAL_SOURCE_BIOS_DIR"
REMOTE_SOURCE_ROMS_DIR="$REMOTE_SOURCE_HOSTNAME:$LOCAL_SOURCE_ROMS_DIR"
REMOTE_SOURCE_BATOCERA_ART_DIR="$REMOTE_SOURCE_HOSTNAME:$LOCAL_SOURCE_BATOCERA_ART_DIR"

SOURCE_BIOS_DIR="$REMOTE_SOURCE_BIOS_DIR"
SOURCE_ROMS_DIR="$REMOTE_SOURCE_ROMS_DIR"
SOURCE_BATOCERA_ART_DIR="$REMOTE_SOURCE_BATOCERA_ART_DIR"

EMUDECK_ROOT_DIR="/run/media/SDCARDNAME/"
ESDE_BIOS_DIR="/Volumes/Android_Emu/BIOS"
ESDE_ROMS_DIR="/Volumes/Android_Emu/ROMs"
# KNULLI_REMOTE_HOSTNAME="root@trimui-brick"
BATOCERA_ROOT_DIR="/Volumes/KNULLI_SD2 1"
#ESDE_ROMS_DIR="bazzite@192.168.1.49:/run/media/bazzite/Samsung SSD 860 EVO mSATA 1TB/Emulation/roms"
KNULLI_REMOTE_HOSTNAME="root@trimui-brick"
MUOS_ROOT_DIR="/Volumes/MUOS_SD2"
# MINUI_ROOT_DIR="/Volumes/MINUI"
MINUI_ROOT_DIR="/Volumes/TUI_BRICK"
ROCKNIX_REMOTE_HOSTNAME="root@retroid-pocket-5"
ONION_ROOT_DIR="/Volumes/ONION"
SPRUCE_ROOT_DIR="/Volumes/SPRUCE"

# System Constants
##################
readonly ARCADE_FINALBURNNEO="ARCADE_FINALBURNNEO"
readonly ARCADE_MAME="ARCADE_MAME"
readonly ARCADE_MAME2003PLUS="ARCADE_MAME2003PLUS"
readonly ATARI_2600="ATARI_2600"
readonly ATARI_5200="ATARI_5200"
readonly ATARI_7800="ATARI_7800"
readonly ATARI_JAGUAR="ATARI_JAGUAR"
readonly ATARI_LYNX="ATARI_LYNX"
readonly CBS_COLECOVISION="CBS_COLECOVISION"
readonly COMMODORE_64="COMMODORE_64"
readonly MICROSOFT_XBOX="MICROSOFT_XBOX"
readonly MICROSOFT_XBOX_360="MICROSOFT_XBOX_360"
readonly NEC_SUPERGRAFX="NEC_SUPERGRAFX"
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
readonly NINTENDO_VIRTUAL_BOY="NINTENDO_VIRTUAL_BOY"
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

# ROM Pack Systems
declare -ra LEVEL_1_SYSTEMS=(
  "$ARCADE_FINALBURNNEO"
  "$PICO_8"
  "$NEC_TURBOGRAFX_16"
  "$NEC_TURBOGRAFX_CD"
  "$NINTENDO_GAME_BOY"
  "$NINTENDO_GAME_BOY_ADVANCE"
  "$NINTENDO_GAME_BOY_COLOR"
  "$NINTENDO_NINTENDO_ENTERTAINMENT_SYSTEM"
  "$NINTENDO_SUPER_NINTENDO_ENTERTAINMENT_SYSTEM"
  "$SEGA_32X"
  "$SEGA_CD"
  "$SEGA_GAME_GEAR"
  "$SEGA_GENESIS"
  "$SNK_NEO_GEO_POCKET_COLOR"
)

declare -ra LEVEL_2_SYSTEMS=(
  "${LEVEL_1_SYSTEMS[@]}"
  "$SONY_PLAYSTATION"
)

declare -ra LEVEL_3_SYSTEMS=(
  "${LEVEL_2_SYSTEMS[@]}"
  "$NINTENDO_64"
  "$SEGA_DREAMCAST"
  "$SEGA_SATURN"
  "$SNK_NEO_GEO_CD"
)

declare -ra LEVEL_4_SYSTEMS=(
  "${LEVEL_3_SYSTEMS[@]}"
  "$NINTENDO_GAMECUBE"
  "$SONY_PLAYSTATION_2"
)

declare -ra LEVEL_5_SYSTEMS=(
  "${LEVEL_4_SYSTEMS[@]}"
  "$NINTENDO_SWITCH"
  "$NINTENDO_WIIU"
  "$SONY_PLAYSTATION_3"
)

rom_pack_to_systems_array() {
  case "$1" in
  "1" | "level-1" | "level_1")
    echo "LEVEL_1_SYSTEMS" ;;
  "2" | "level-2" | "level_2")
    echo "LEVEL_2_SYSTEMS" ;;
  "3" | "level-3" | "level_3")
    echo "LEVEL_3_SYSTEMS" ;;
  "4" | "level-4" | "level_4")
    echo "LEVEL_4_SYSTEMS" ;;
  "5" | "level-5" | "level_5")
    echo "LEVEL_5_SYSTEMS" ;;
  *)
    echo "$1 is not a supported ROM pack name."
    return 1
    ;;
  esac
}

# Source File Mappings
######################
declare -rA SYSTEM_TO_SOURCE_BIOS_FILES_SUBDIRECTORY_MAP=(
  [$ARCADE_FINALBURNNEO]='Arcade - Final Burn Neo'
  [$ARCADE_MAME2003PLUS]='Arcade - MAME 2003 Plus'
  [$NEC_TURBOGRAFX_16]='NEC - PC Engine - TurboGrafx 16'
  [$NEC_TURBOGRAFX_CD]='NEC - PC Engine CD - TurboGrafx-CD'
  [$NINTENDO_3DS]='Nintendo - 3DS'
  [$NINTENDO_DS]='Nintendo - DS'
  [$NINTENDO_GAME_BOY_ADVANCE]='Nintendo - Game Boy Advance'
  [$NINTENDO_GAME_BOY_COLOR]='Nintendo - Game Boy Color'
  [$NINTENDO_GAME_BOY]='Nintendo - Game Boy'
  [$NINTENDO_GAMECUBE]='Nintendo - GameCube'
  [$PICO_8]='PICO-8'
  [$SEGA_CD]='Sega - Sega CD'
  [$SEGA_DREAMCAST]='Sega - Dreamcast'
  [$SEGA_SATURN]='Sega - Saturn'
  [$SNK_NEO_GEO]='SNK - Neo Geo'
  [$SNK_NEO_GEO_CD]='SNK - Neo Geo CD'
  [$SONY_PLAYSTATION]='Sony - Playstation'
  [$SONY_PLAYSTATION_2]='Sony - Playstation 2'
  [$SONY_PLAYSTATION_VITA]='Sony - Playstation Vita'
)

declare -rA SYSTEM_TO_SOURCE_ROMS_SUBDIRECTORY_MAP=(
  [$ARCADE_FINALBURNNEO]='Arcade - Final Burn Neo (1.0.0.3 Best Set)'
  [$ARCADE_MAME2003PLUS]='Arcade - MAME 2003 Plus (Tiny Best Set)'
  [$ATARI_2600]='Atari - 2600'
  [$ATARI_5200]='Atari - 5200'
  [$ATARI_7800]='Atari - 7800'
  [$ATARI_JAGUAR]='Atari - Jaguar'
  [$ATARI_LYNX]='Atari - Lynx'
  [$CBS_COLECOVISION]='CBS - Colecovision'
  [$COMMODORE_64]='Commodore - 64'
  [$NEC_TURBOGRAFX_16]='NEC - TurboGrafx 16'
  [$NEC_TURBOGRAFX_CD]='NEC - TurboGrafx-CD (Tiny Best Set)'
  [$NINTENDO_64]='Nintendo - Nintendo 64'
  [$NINTENDO_DS]='Nintendo - Nintendo DS (Retro ROMs Best Set)'
  [$NINTENDO_FAMICOM_DISK_SYSTEM]='Nintendo - Famicom Disk System'
  [$NINTENDO_GAME_BOY_ADVANCE]='Nintendo - Game Boy Advance'
  [$NINTENDO_GAME_BOY_COLOR]='Nintendo - Game Boy Color'
  [$NINTENDO_GAME_BOY]='Nintendo - Game Boy'
  [$NINTENDO_GAMECUBE]='Nintendo - GameCube (Retro ROMs Best Set)'
  [$NINTENDO_NINTENDO_ENTERTAINMENT_SYSTEM]='Nintendo - Nintendo Entertainment System'
  [$NINTENDO_SUPER_NINTENDO_ENTERTAINMENT_SYSTEM]='Nintendo - Super Nintendo Entertainment System'
  [$NINTENDO_SWITCH]='Nintendo - Nintendo Switch'
  [$NINTENDO_WII]='Nintendo - Wii (Minimal)'
  [$PICO_8]='Lexaloffle - PICO-8'
  [$SEGA_32X]='Sega - Sega 32X'
  [$SEGA_CD]='Sega - Sega CD (Tiny Best Set)'
  [$SEGA_DREAMCAST]='Sega - Dreamcast (Retro ROMs Best Set)'
  [$SEGA_GAME_GEAR]='Sega - Game Gear'
  [$SEGA_GENESIS]='Sega - Genesis'
  [$SEGA_MASTER_SYSTEM]='Sega - Master System'
  [$SEGA_SATURN]='Sega - Saturn (Retro ROMs Best Set)'
  [$SEGA_SG_1000]='Sega - SG-1000'
  [$SNK_NEO_GEO]='SNK - Neo Geo'
  [$SNK_NEO_GEO_CD]='SNK - Neo Geo CD'
  [$SNK_NEO_GEO_POCKET]='SNK - Neo Geo Pocket'
  [$SNK_NEO_GEO_POCKET_COLOR]='SNK - Neo Geo Pocket Color'
  [$SONY_PLAYSTATION]='Sony - Playstation (Tiny Best Set)'
  [$SONY_PLAYSTATION_PORTABLE]='Sony - Playstation Portable (Retro ROMs Best Set)'
)

# Copy Functions
################

# Copies BIOS files for systems to destination directories
# Arguments:
#   1. Name of systems array
#   2. Name of function that inputs a system and outputs the destination directory for the system
copy_bios_files() {
  local -n systems="$1"
  local get_destination_system_bios_directory_function_name="$2"

  for system in "${systems[@]}"
  do
    if [[ ${SYSTEM_TO_SOURCE_BIOS_FILES_SUBDIRECTORY_MAP["$system"]+isset} ]]; then
      local source_system_bios_dir="${SYSTEM_TO_SOURCE_BIOS_FILES_SUBDIRECTORY_MAP["$system"]}/"
      local destination_system_bios_directory=$(eval "$get_destination_system_bios_directory_function_name" $system)
      echo "rsync -avP \"${SOURCE_BIOS_DIR}/${source_system_bios_dir}\" \"$destination_system_bios_directory/\""
      rsync -avP "${SOURCE_BIOS_DIR}/${source_system_bios_dir}" "$destination_system_bios_directory/"
    # else
    #   echo "No source BIOS files for $system."
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
    if [[ ${SYSTEM_TO_SOURCE_ROMS_SUBDIRECTORY_MAP["$system"]+isset} ]]; then
      local source_system_rom_dir="${SYSTEM_TO_SOURCE_ROMS_SUBDIRECTORY_MAP["$system"]}/"
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

display_source_rom_sizes() {
  local -n systems="$1"
  IFS=$'\n' sorted_systems=($(sort <<<"${systems[*]}"))
  unset IFS

  local system_roms_directories=""

  for system in "${sorted_systems[@]}"; do
    if [[ ${SYSTEM_TO_SOURCE_ROMS_SUBDIRECTORY_MAP["$system"]+isset} ]]; then
      local source_system_rom_dir="${SYSTEM_TO_SOURCE_ROMS_SUBDIRECTORY_MAP["$system"]}/"
      system_roms_directories+="${LOCAL_SOURCE_ROMS_DIR}/'${source_system_rom_dir}' "
    fi
  done

  ssh $REMOTE_SOURCE_HOSTNAME "du --total --summarize --human-readable $system_roms_directories"
}

# OS/Frontends
##############

# Batocera/Knulli
# https://wiki.batocera.org/systems
declare -rA SYSTEM_TO_BATOCERA_ROMS_SUBDIR_MAP=(
  [$ARCADE_FINALBURNNEO]='fbneo'
  [$ARCADE_MAME2003PLUS]='mame'
  [$ATARI_2600]='atari2600'
  [$ATARI_5200]='atari5200'
  [$ATARI_7800]='atari7800'
  [$ATARI_JAGUAR]='jaguar'
  [$ATARI_LYNX]='lynx'
  [$CBS_COLECOVISION]='colecovision'
  [$COMMODORE_64]='c64'
  [$MICROSOFT_XBOX]='xbox'
  [$MICROSOFT_XBOX_360]='xbox360'
  [$NEC_SUPERGRAFX]='supergrafx'
  [$NEC_TURBOGRAFX_CD]='pcenginecd'
  [$NEC_TURBOGRAFX_16]='pcengine'
  [$NINTENDO_3DS]='n3ds'
  [$NINTENDO_DS]='nds'
  [$NINTENDO_FAMICOM_DISK_SYSTEM]='fds'
  [$NINTENDO_GAME_BOY]='gb'
  [$NINTENDO_GAME_BOY_ADVANCE]='gba'
  [$NINTENDO_GAME_BOY_COLOR]='gbc'
  [$NINTENDO_GAMECUBE]='gamecube'
  [$NINTENDO_64]='n64'
  [$NINTENDO_NINTENDO_ENTERTAINMENT_SYSTEM]='nes'
  [$NINTENDO_POKEMON_MINI]='pokemini'
  [$NINTENDO_SUPER_GAME_BOY]='sgb'
  [$NINTENDO_SUPER_NINTENDO_ENTERTAINMENT_SYSTEM]='snes'
  [$NINTENDO_SWITCH]='switch'
  [$NINTENDO_WII]='wii'
  [$NINTENDO_WIIU]='wiiu'
  [$PICO_8]='pico8'
  [$SEGA_DREAMCAST]='dreamcast'
  [$SEGA_GAME_GEAR]='gamegear'
  [$SEGA_GENESIS]='megadrive'
  [$SEGA_MASTER_SYSTEM]='mastersystem'
  [$SEGA_32X]='sega32x'
  [$SEGA_CD]='segacd'
  [$SEGA_SATURN]='saturn'
  [$SEGA_SG_1000]='sg1000'
  [$SNK_NEO_GEO]='neogeo'
  [$SNK_NEO_GEO_CD]='neogeocd'
  [$SNK_NEO_GEO_POCKET]='ngp'
  [$SNK_NEO_GEO_POCKET_COLOR]='ngpc'
  [$SONY_PLAYSTATION]='psx'
  [$SONY_PLAYSTATION_2]='ps2'
  [$SONY_PLAYSTATION_PORTABLE]='psp'
  [$SONY_PLAYSTATION_VITA]='psvita'
)

get_system_batocera_bios_directory(){
  # echo "$BATOCERA_REMOTE_HOSTNAME:/userdata/bios"
  echo "$BATOCERA_ROOT_DIR/bios"
}

get_system_batocera_roms_directory(){
  if [[ -v SYSTEM_TO_BATOCERA_ROMS_SUBDIR_MAP["$1"] ]]; then
    # echo "$BATOCERA_REMOTE_HOSTNAME:/userdata/roms/${SYSTEM_TO_BATOCERA_ROMS_SUBDIR_MAP[$1]}"
    echo "$BATOCERA_ROOT_DIR/roms/${SYSTEM_TO_BATOCERA_ROMS_SUBDIR_MAP["$1"]}"
    return 0
  fi
  return 1
}

# EmuDeck (https://emudeck.github.io)
get_system_emudeck_bios_directory(){
  echo "$EMUDECK_ROOT_DIR/Emulation/bios"
}

# https://emudeck.github.io/cheat-sheet/
declare -rA SYSTEM_TO_EMUDECK_ROMS_SUBDIR_MAP=(
  [$ARCADE_MAME2003PLUS]='arcade'
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
  [$NINTENDO_GAMECUBE]='gamecube'
  [$NINTENDO_64]='n64'
  [$NINTENDO_NINTENDO_ENTERTAINMENT_SYSTEM]='nes'
  [$NINTENDO_POKEMON_MINI]='pokemini'
  [$NINTENDO_SUPER_NINTENDO_ENTERTAINMENT_SYSTEM]='snes'
  [$NINTENDO_SWITCH]='switch'
  [$NINTENDO_WII]='wii'
  [$NINTENDO_WIIU]='wiiu/roms'
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

get_system_emudeck_roms_directory(){
  if [[ -v SYSTEM_TO_EMUDECK_ROMS_SUBDIR_MAP[$1] ]]; then
    echo "$EMUDECK_ROOT_DIR/Emulation/roms/${SYSTEM_TO_EMUDECK_ROMS_SUBDIR_MAP[$1]}"
    return 0
  fi
  return 1
}

# ES-DE (EmulationStation Desktop Edition) (https://www.es-de.org)
get_system_esde_bios_directory(){
  echo "$ESDE_BIOS_DIR"
}

# systems.txt in ROMs directory
declare -rA SYSTEM_TO_ESDE_ROMS_SUBDIR_MAP=(
  [$ARCADE_FINALBURNNEO]='fbneo'
  [$ARCADE_MAME2003PLUS]='arcade'
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
  [$NINTENDO_GAMECUBE]='gamecube'
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

# MinUI (https://github.com/shauninman/MinUI)
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

# https://github.com/shauninman/MinUI/tree/main/skeleton/BASE/Roms
# https://github.com/shauninman/MinUI/tree/main/skeleton/EXTRAS/Roms
declare -rA SYSTEM_TO_MINUI_ROMS_SUBDIR_MAP=(
  [$PICO_8]='Pico-8 (P8)'
  [$NEC_TURBOGRAFX_16]='TurboGrafx-16 (PCE)'
  [$NINTENDO_GAME_BOY]='Game Boy (GB)'
  [$NINTENDO_GAME_BOY_ADVANCE]='Game Boy Advance (GBA)'
  [$NINTENDO_GAME_BOY_COLOR]='Game Boy Color (GBC)'
  [$NINTENDO_NINTENDO_ENTERTAINMENT_SYSTEM]='Nintendo Entertainment System (FC)'
  [$NINTENDO_POKEMON_MINI]='Pokémon mini (PKM)'
  [$NINTENDO_SUPER_NINTENDO_ENTERTAINMENT_SYSTEM]='Super Nintendo Entertainment System (SFC)'
  [$NINTENDO_VIRTUAL_BOY]='Virtual Boy (VB)'
  [$SEGA_GAME_GEAR]='Sega Game Gear (GG)'
  [$SEGA_GENESIS]='Sega Genesis (MD)'
  [$SEGA_MASTER_SYSTEM]='Sega Master System (SMS)'
  [$SEGA_CD]='Sega CD (MD)'
  [$SNK_NEO_GEO_POCKET_COLOR]='Neo Geo Pocket Color (NGPC)'
  [$SONY_PLAYSTATION]='Sony PlayStation (PS)'
)

get_system_minui_roms_directory(){
  if [[ -v SYSTEM_TO_MINUI_ROMS_SUBDIR_MAP[$1] ]]; then
    echo "$MINUI_ROOT_DIR/Roms/${SYSTEM_TO_MINUI_ROMS_SUBDIR_MAP[$1]}"
    return 0
  fi
  return 1
}

# MuOS (https://muos.dev)
get_system_muos_bios_directory(){
  echo "$MUOS_ROOT_DIR/MUOS/Bios"
}

declare -rA SYSTEM_TO_MUOS_ROMS_SUBDIR_MAP=(
  [$PICO_8]='PICO-8'
  [$NEC_TURBOGRAFX_16]='NEC PC Engine'
  [$NEC_TURBOGRAFX_CD]='NEC PC Engine CD'
  [$NINTENDO_GAME_BOY]='Nintendo Game Boy'
  [$NINTENDO_GAME_BOY_ADVANCE]='Nintendo Game Boy Advance'
  [$NINTENDO_GAME_BOY_COLOR]='Nintendo Game Boy Color'
  [$NINTENDO_NINTENDO_ENTERTAINMENT_SYSTEM]='Nintendo NES-Famicom'
  [$NINTENDO_SUPER_NINTENDO_ENTERTAINMENT_SYSTEM]='Nintendo SNES-SFC'
  [$SEGA_32X]='Sega 32X'
  [$SEGA_CD]='Sega Mega CD - Sega CD'
  [$SEGA_GAME_GEAR]='Sega Game Gear'
  [$SEGA_GENESIS]='Sega Mega Drive - Genesis'
  [$SEGA_MASTER_SYSTEM]='Sega Master System'
  [$SNK_NEO_GEO]='SNK Neo Geo'
  [$SNK_NEO_GEO_CD]='SNK Neo Geo CD'
  [$SNK_NEO_GEO_POCKET_COLOR]='SNK Neo Geo Pocket - Color'
  [$SONY_PLAYSTATION]='Sony PlayStation'
)

get_system_muos_roms_directory(){
    if [[ -v SYSTEM_TO_MUOS_ROMS_SUBDIR_MAP[$1] ]]; then
    echo "$MUOS_ROOT_DIR/ROMS/${SYSTEM_TO_MUOS_ROMS_SUBDIR_MAP[$1]}"
    return 0
  fi
  return 1
}

# ROCKNIX (https://rocknix.org)
get_system_rocknix_bios_directory(){
  echo "$ROCKNIX_REMOTE_HOSTNAME:/storage/roms/bios"
}

# https://rocknix.org/play/add-games/
get_system_rocknix_roms_directory(){
  if [[ -v SYSTEM_TO_ESDE_ROMS_SUBDIR_MAP[$1] ]]; then
    echo "$ROCKNIX_REMOTE_HOSTNAME:/storage/roms/${SYSTEM_TO_ESDE_ROMS_SUBDIR_MAP[$1]}"
    return 0
  fi
  return 1
}

# Onion (https://onionui.github.io)
get_system_onion_bios_directory(){
  echo "$ONION_ROOT_DIR/BIOS"
}

# https://onionui.github.io/docs/emulators/folders
declare -rA SYSTEM_TO_ONION_ROMS_SUBDIR_MAP=(
  [$ATARI_2600]='ATARI'
  [$ATARI_5200]='FIFTYTWOHUNDRED'
  [$ATARI_7800]='SEVENTYEIGHTHUNDRED'
  [$ATARI_LYNX]='LYNX'
  [$CBS_COLECOVISION]='COLECO'
  [$COMMODORE_64]='COMMODORE'
  [$ARCADE_MAME2003PLUS]='ARCADE'
  [$NEC_SUPERGRAFX]='SGFX'
  [$NEC_TURBOGRAFX_16]='PCE'
  [$NEC_TURBOGRAFX_CD]='PCECD'
  [$NINTENDO_64]='N64'
  [$NINTENDO_FAMICOM_DISK_SYSTEM]='FDS'
  [$NINTENDO_DS]='NDS'
  [$NINTENDO_GAME_BOY]='GB'
  [$NINTENDO_GAME_BOY_ADVANCE]='GBA'
  [$NINTENDO_GAME_BOY_COLOR]='GBC'
  [$NINTENDO_NINTENDO_ENTERTAINMENT_SYSTEM]='FC'
  [$NINTENDO_POKEMON_MINI]='POKE'
  [$NINTENDO_SUPER_GAME_BOY]='SGB'
  [$NINTENDO_SUPER_NINTENDO_ENTERTAINMENT_SYSTEM]='SFC'
  [$PICO_8]='PICO8'
  [$SEGA_32X]='THIRTYTWOX'
  [$SEGA_CD]='SEGACD'
  [$SEGA_DREAMCAST]='DC'
  [$SEGA_GAME_GEAR]='GG'
  [$SEGA_GENESIS]='MD'
  [$SEGA_MASTER_SYSTEM]='MS'
  [$SEGA_SG_1000]='SEGASGONE'
  [$SNK_NEO_GEO]='NEOGEO'
  [$SNK_NEO_GEO_CD]='NEOCD'
  [$SNK_NEO_GEO_POCKET]='NGP'
  [$SNK_NEO_GEO_POCKET_COLOR]='NGPC'
  [$SONY_PLAYSTATION]='PS'
  [$SONY_PLAYSTATION_PORTABLE]='PSP'
)

get_system_onion_roms_directory(){
  if [[ -v SYSTEM_TO_ONION_ROMS_SUBDIR_MAP[$1] ]]; then
    echo "$ONION_ROOT_DIR/Roms/${SYSTEM_TO_ONION_ROMS_SUBDIR_MAP[$1]}"
    return 0
  fi
  return 1
}

# Spruce (https://spruceui.github.io/)
get_system_spruce_bios_directory(){
  echo "$SPRUCE_ROOT_DIR/BIOS"
}

# https://github.com/spruceUI/spruceOS/wiki/11.-Adding-Games#rom-folder-chart
declare -rA SYSTEM_TO_SPRUCE_ROMS_SUBDIR_MAP=(
  [$ATARI_2600]='ATARI'
  [$ATARI_5200]='FIFTYTWOHUNDRED'
  [$ATARI_7800]='SEVENTYEIGHTHUNDRED'
  [$ATARI_LYNX]='LYNX'
  [$CBS_COLECOVISION]='COLECO'
  [$COMMODORE_64]='COMMODORE'
  [$ARCADE_MAME2003PLUS]='ARCADE_MAME2003PLUS'
  [$NEC_SUPERGRAFX]='SGFX'
  [$NEC_TURBOGRAFX_16]='PCE'
  [$NEC_TURBOGRAFX_CD]='PCECD'
  [$NINTENDO_64]='N64'
  [$NINTENDO_FAMICOM_DISK_SYSTEM]='FDS'
  [$NINTENDO_DS]='NDS'
  [$NINTENDO_GAME_BOY]='GB'
  [$NINTENDO_GAME_BOY_ADVANCE]='GBA'
  [$NINTENDO_GAME_BOY_COLOR]='GBC'
  [$NINTENDO_NINTENDO_ENTERTAINMENT_SYSTEM]='FC'
  [$NINTENDO_POKEMON_MINI]='POKE'
  [$NINTENDO_SUPER_GAME_BOY]='SGB'
  [$NINTENDO_SUPER_NINTENDO_ENTERTAINMENT_SYSTEM]='SFC'
  [$PICO_8]='PICO8'
  [$SEGA_32X]='THIRTYTWOX'
  [$SEGA_CD]='SEGACD'
  [$SEGA_DREAMCAST]='DC'
  [$SEGA_GAME_GEAR]='GG'
  [$SEGA_GENESIS]='MD'
  [$SEGA_MASTER_SYSTEM]='MS'
  [$SEGA_SG_1000]='SEGASGONE'
  [$SNK_NEO_GEO]='NEOGEO'
  [$SNK_NEO_GEO_CD]='NEOCD'
  [$SNK_NEO_GEO_POCKET]='NGP'
  [$SNK_NEO_GEO_POCKET_COLOR]='NGPC'
  [$SONY_PLAYSTATION]='PS'
  [$SONY_PLAYSTATION_PORTABLE]='PSP'
)

get_system_spruce_roms_directory(){
  if [[ -v SYSTEM_TO_SPRUCE_ROMS_SUBDIR_MAP[$1] ]]; then
    echo "$MINUI_ROOT_DIR/Roms/${SYSTEM_TO_MINUI_ROMS_SUBDIR_MAP[$1]}"
    return 0
  fi
  return 1
}

# Main
destination_type=$(echo "$1" | tr '[:upper:]' '[:lower:]')

systems_array_name=""
if [ -n "$2" ]; then
  device=$(echo "$2" | tr '[:upper:]' '[:lower:]')
  systems_array_name=$(rom_pack_to_systems_array $device)
fi

destination_root_dir="$3"

case "$destination_type" in
  "batocera" | "knulli")
    copy_bios_files $systems_array_name "get_system_batocera_bios_directory"
    copy_rom_files $systems_array_name "get_system_batocera_roms_directory" false
    ;;
  "emudeck")
    copy_bios_files $systems_array_name "get_system_emudeck_bios_directory"
    copy_rom_files $systems_array_name "get_system_emudeck_roms_directory" false
    ;;
  "esde")
    copy_bios_files $systems_array_name "get_system_esde_bios_directory"
    copy_rom_files $systems_array_name "get_system_esde_roms_directory" false
    ;;
  "minui")
    copy_bios_files $systems_array_name "get_system_minui_bios_directory"
    copy_rom_files $systems_array_name "get_system_minui_roms_directory" false
    ;;
  "muos")
    copy_bios_files $systems_array_name "get_system_muos_bios_directory"
    copy_rom_files $systems_array_name "get_system_muos_roms_directory" false
    ;;
  "onion")
    copy_bios_files "$systems_array_name" "get_system_onion_bios_directory"
    copy_rom_files "$systems_array_name" "get_system_onion_roms_directory" false
    ;;
  "rocknix")
    copy_bios_files $systems_array_name "get_system_rocknix_bios_directory"
    copy_rom_files $systems_array_name "get_system_rocknix_roms_directory" false
    ;;
  "spruce")
    copy_bios_files "$systems_array_name" "get_system_spruce_bios_directory"
    copy_rom_files "$systems_array_name" "get_system_spruce_roms_directory" false
    ;;
  "sizes" | "rom-sizes" | "rom_sizes")
    display_source_rom_sizes "$systems_array_name" ;;
  *)
    echo "$1 is not a supported destination OS/application."
    exit 1
    ;;
esac
