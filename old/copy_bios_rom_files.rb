#!/usr/bin/env ruby
# frozen_string_literal: true

# Copy BIOS and ROM files to various emulation frontends and operating systems.

require 'open3'

# Gaming system identifiers
module System
  ARCADE_FINALBURNNEO = :arcade_finalburnneo
  ARCADE_MAME = :arcade_mame
  ARCADE_MAME2003PLUS = :arcade_mame2003plus
  ATARI_2600 = :atari_2600
  ATARI_5200 = :atari_5200
  ATARI_7800 = :atari_7800
  ATARI_JAGUAR = :atari_jaguar
  ATARI_LYNX = :atari_lynx
  CBS_COLECOVISION = :cbs_colecovision
  COMMODORE_64 = :commodore_64
  MICROSOFT_XBOX = :microsoft_xbox
  MICROSOFT_XBOX_360 = :microsoft_xbox_360
  NEC_SUPERGRAFX = :nec_supergrafx
  NEC_TURBOGRAFX_16 = :nec_turbografx_16
  NEC_TURBOGRAFX_CD = :nec_turbografx_cd
  NINTENDO_3DS = :nintendo_3ds
  NINTENDO_64 = :nintendo_64
  NINTENDO_DS = :nintendo_ds
  NINTENDO_FAMICOM_DISK_SYSTEM = :nintendo_famicom_disk_system
  NINTENDO_GAME_BOY_ADVANCE = :nintendo_game_boy_advance
  NINTENDO_GAME_BOY_COLOR = :nintendo_game_boy_color
  NINTENDO_GAME_BOY = :nintendo_game_boy
  NINTENDO_GAMECUBE = :nintendo_gamecube
  NINTENDO_NES = :nintendo_nes
  NINTENDO_POKEMON_MINI = :nintendo_pokemon_mini
  NINTENDO_SNES = :nintendo_snes
  NINTENDO_SUPER_GAME_BOY = :nintendo_super_game_boy
  NINTENDO_SWITCH = :nintendo_switch
  NINTENDO_VIRTUAL_BOY = :nintendo_virtual_boy
  NINTENDO_WIIU = :nintendo_wiiu
  NINTENDO_WII = :nintendo_wii
  PICO_8 = :pico_8
  SEGA_32X = :sega_32x
  SEGA_CD = :sega_cd
  SEGA_DREAMCAST = :sega_dreamcast
  SEGA_GAME_GEAR = :sega_game_gear
  SEGA_GENESIS = :sega_genesis
  SEGA_MASTER_SYSTEM = :sega_master_system
  SEGA_NAOMI = :sega_naomi
  SEGA_SATURN = :sega_saturn
  SEGA_SG_1000 = :sega_sg_1000
  SNK_NEO_GEO = :snk_neo_geo
  SNK_NEO_GEO_CD = :snk_neo_geo_cd
  SNK_NEO_GEO_POCKET = :snk_neo_geo_pocket
  SNK_NEO_GEO_POCKET_COLOR = :snk_neo_geo_pocket_color
  SONY_PLAYSTATION_2 = :sony_playstation_2
  SONY_PLAYSTATION_3 = :sony_playstation_3
  SONY_PLAYSTATION_PORTABLE = :sony_playstation_portable
  SONY_PLAYSTATION_VITA = :sony_playstation_vita
  SONY_PLAYSTATION = :sony_playstation

  ALL = constants.map { |c| const_get(c) }.freeze
end

# Source directory configuration
module SourceConfig
  LOCAL_BIOS_DIR = '/mnt/storage/Games/BIOS Files'
  LOCAL_ROMS_DIR = '/mnt/storage/Games/ROMs/Curated'
  LOCAL_BATOCERA_ART_DIR = '/mnt/storage/Games/Art/Batocera/'
  REMOTE_HOSTNAME = 'nas-01'

  BIOS_DIR = "#{REMOTE_HOSTNAME}:#{LOCAL_BIOS_DIR}"
  ROMS_DIR = "#{REMOTE_HOSTNAME}:#{LOCAL_ROMS_DIR}"
  BATOCERA_ART_DIR = "#{REMOTE_HOSTNAME}:#{LOCAL_BATOCERA_ART_DIR}"

  BIOS_SUBDIRS = {
    System::ARCADE_FINALBURNNEO => 'Arcade - Final Burn Neo',
    System::ARCADE_MAME2003PLUS => 'Arcade - MAME 2003 Plus',
    System::NEC_TURBOGRAFX_16 => 'NEC - PC Engine - TurboGrafx 16',
    System::NEC_TURBOGRAFX_CD => 'NEC - PC Engine CD - TurboGrafx-CD',
    System::NINTENDO_3DS => 'Nintendo - 3DS',
    System::NINTENDO_DS => 'Nintendo - DS',
    System::NINTENDO_GAME_BOY_ADVANCE => 'Nintendo - Game Boy Advance',
    System::NINTENDO_GAME_BOY_COLOR => 'Nintendo - Game Boy Color',
    System::NINTENDO_GAME_BOY => 'Nintendo - Game Boy',
    System::NINTENDO_GAMECUBE => 'Nintendo - GameCube',
    System::PICO_8 => 'PICO-8',
    System::SEGA_CD => 'Sega - Sega CD',
    System::SEGA_DREAMCAST => 'Sega - Dreamcast',
    System::SEGA_SATURN => 'Sega - Saturn',
    System::SNK_NEO_GEO => 'SNK - Neo Geo',
    System::SNK_NEO_GEO_CD => 'SNK - Neo Geo CD',
    System::SONY_PLAYSTATION => 'Sony - Playstation',
    System::SONY_PLAYSTATION_2 => 'Sony - Playstation 2',
    System::SONY_PLAYSTATION_VITA => 'Sony - Playstation Vita'
  }.freeze

  ROMS_SUBDIRS = {
    System::ARCADE_FINALBURNNEO => 'Arcade - Final Burn Neo (1.0.0.3 Best Set)',
    System::ARCADE_MAME2003PLUS => 'Arcade - MAME 2003 Plus (Tiny Best Set)',
    System::ATARI_2600 => 'Atari - 2600',
    System::ATARI_5200 => 'Atari - 5200',
    System::ATARI_7800 => 'Atari - 7800',
    System::ATARI_JAGUAR => 'Atari - Jaguar',
    System::ATARI_LYNX => 'Atari - Lynx',
    System::CBS_COLECOVISION => 'CBS - Colecovision',
    System::COMMODORE_64 => 'Commodore - 64',
    System::NEC_TURBOGRAFX_16 => 'NEC - TurboGrafx 16',
    System::NEC_TURBOGRAFX_CD => 'NEC - TurboGrafx-CD (Tiny Best Set)',
    System::NINTENDO_64 => 'Nintendo - Nintendo 64',
    System::NINTENDO_DS => 'Nintendo - Nintendo DS (Retro ROMs Best Set)',
    System::NINTENDO_FAMICOM_DISK_SYSTEM => 'Nintendo - Famicom Disk System',
    System::NINTENDO_GAME_BOY_ADVANCE => 'Nintendo - Game Boy Advance',
    System::NINTENDO_GAME_BOY_COLOR => 'Nintendo - Game Boy Color',
    System::NINTENDO_GAME_BOY => 'Nintendo - Game Boy',
    System::NINTENDO_GAMECUBE => 'Nintendo - GameCube (Retro ROMs Best Set)',
    System::NINTENDO_NES => 'Nintendo - Nintendo Entertainment System',
    System::NINTENDO_SNES => 'Nintendo - Super Nintendo Entertainment System',
    System::NINTENDO_SWITCH => 'Nintendo - Nintendo Switch',
    System::NINTENDO_WII => 'Nintendo - Wii (Minimal)',
    System::PICO_8 => 'Lexaloffle - PICO-8',
    System::SEGA_32X => 'Sega - Sega 32X',
    System::SEGA_CD => 'Sega - Sega CD (Tiny Best Set)',
    System::SEGA_DREAMCAST => 'Sega - Dreamcast (Retro ROMs Best Set)',
    System::SEGA_GAME_GEAR => 'Sega - Game Gear',
    System::SEGA_GENESIS => 'Sega - Genesis',
    System::SEGA_MASTER_SYSTEM => 'Sega - Master System',
    System::SEGA_SATURN => 'Sega - Saturn (Retro ROMs Best Set)',
    System::SEGA_SG_1000 => 'Sega - SG-1000',
    System::SNK_NEO_GEO => 'SNK - Neo Geo',
    System::SNK_NEO_GEO_CD => 'SNK - Neo Geo CD',
    System::SNK_NEO_GEO_POCKET => 'SNK - Neo Geo Pocket',
    System::SNK_NEO_GEO_POCKET_COLOR => 'SNK - Neo Geo Pocket Color',
    System::SONY_PLAYSTATION => 'Sony - Playstation (Tiny Best Set)',
    System::SONY_PLAYSTATION_PORTABLE => 'Sony - Playstation Portable (Retro ROMs Best Set)'
  }.freeze
end

# Interface for emulation frontends
module Frontend
  def name
    raise NotImplementedError, "#{self.class} must implement #name"
  end

  def bios_directory(_system)
    raise NotImplementedError, "#{self.class} must implement #bios_directory"
  end

  def roms_directory(_system)
    raise NotImplementedError, "#{self.class} must implement #roms_directory"
  end

  def supported_systems
    roms_subdirs.keys
  end

  protected

  def roms_subdirs
    raise NotImplementedError, "#{self.class} must implement #roms_subdirs"
  end
end

# Batocera/Knulli frontend (https://wiki.batocera.org/systems)
class Batocera
  include Frontend

  ROOT_DIR = '/Volumes/KNULLI_SD2 1'

  ROMS_SUBDIRS = {
    System::ARCADE_FINALBURNNEO => 'fbneo',
    System::ARCADE_MAME2003PLUS => 'mame',
    System::ATARI_2600 => 'atari2600',
    System::ATARI_5200 => 'atari5200',
    System::ATARI_7800 => 'atari7800',
    System::ATARI_JAGUAR => 'jaguar',
    System::ATARI_LYNX => 'lynx',
    System::CBS_COLECOVISION => 'colecovision',
    System::COMMODORE_64 => 'c64',
    System::MICROSOFT_XBOX => 'xbox',
    System::MICROSOFT_XBOX_360 => 'xbox360',
    System::NEC_SUPERGRAFX => 'supergrafx',
    System::NEC_TURBOGRAFX_CD => 'pcenginecd',
    System::NEC_TURBOGRAFX_16 => 'pcengine',
    System::NINTENDO_3DS => 'n3ds',
    System::NINTENDO_DS => 'nds',
    System::NINTENDO_FAMICOM_DISK_SYSTEM => 'fds',
    System::NINTENDO_GAME_BOY => 'gb',
    System::NINTENDO_GAME_BOY_ADVANCE => 'gba',
    System::NINTENDO_GAME_BOY_COLOR => 'gbc',
    System::NINTENDO_GAMECUBE => 'gamecube',
    System::NINTENDO_64 => 'n64',
    System::NINTENDO_NES => 'nes',
    System::NINTENDO_POKEMON_MINI => 'pokemini',
    System::NINTENDO_SUPER_GAME_BOY => 'sgb',
    System::NINTENDO_SNES => 'snes',
    System::NINTENDO_SWITCH => 'switch',
    System::NINTENDO_WII => 'wii',
    System::NINTENDO_WIIU => 'wiiu',
    System::PICO_8 => 'pico8',
    System::SEGA_DREAMCAST => 'dreamcast',
    System::SEGA_GAME_GEAR => 'gamegear',
    System::SEGA_GENESIS => 'megadrive',
    System::SEGA_MASTER_SYSTEM => 'mastersystem',
    System::SEGA_32X => 'sega32x',
    System::SEGA_CD => 'segacd',
    System::SEGA_SATURN => 'saturn',
    System::SEGA_SG_1000 => 'sg1000',
    System::SNK_NEO_GEO => 'neogeo',
    System::SNK_NEO_GEO_CD => 'neogeocd',
    System::SNK_NEO_GEO_POCKET => 'ngp',
    System::SNK_NEO_GEO_POCKET_COLOR => 'ngpc',
    System::SONY_PLAYSTATION => 'psx',
    System::SONY_PLAYSTATION_2 => 'ps2',
    System::SONY_PLAYSTATION_PORTABLE => 'psp',
    System::SONY_PLAYSTATION_VITA => 'psvita'
  }.freeze

  def initialize(root_dir: ROOT_DIR)
    @root_dir = root_dir
  end

  def name
    'Batocera'
  end

  def bios_directory(_system)
    "#{@root_dir}/bios"
  end

  def roms_directory(system)
    subdir = ROMS_SUBDIRS[system]
    return nil unless subdir

    "#{@root_dir}/roms/#{subdir}"
  end

  protected

  def roms_subdirs
    ROMS_SUBDIRS
  end
end

# Knulli frontend (uses Batocera structure)
class Knulli < Batocera
  def name
    'Knulli'
  end
end

# EmuDeck frontend (https://emudeck.github.io)
class EmuDeck
  include Frontend

  ROOT_DIR = '/run/media/SDCARDNAME/'

  ROMS_SUBDIRS = {
    System::ARCADE_MAME2003PLUS => 'arcade',
    System::ATARI_2600 => 'atari2600',
    System::ATARI_5200 => 'atari5200',
    System::ATARI_7800 => 'atari7800',
    System::ATARI_JAGUAR => 'atarijaguar',
    System::ATARI_LYNX => 'atarilynx',
    System::CBS_COLECOVISION => 'colecovision',
    System::COMMODORE_64 => 'c64',
    System::NEC_TURBOGRAFX_CD => 'tg-cd',
    System::NEC_TURBOGRAFX_16 => 'tg16',
    System::NINTENDO_3DS => 'n3ds',
    System::NINTENDO_DS => 'nds',
    System::NINTENDO_FAMICOM_DISK_SYSTEM => 'famicom',
    System::NINTENDO_GAME_BOY => 'gb',
    System::NINTENDO_GAME_BOY_ADVANCE => 'gba',
    System::NINTENDO_GAME_BOY_COLOR => 'gbc',
    System::NINTENDO_GAMECUBE => 'gamecube',
    System::NINTENDO_64 => 'n64',
    System::NINTENDO_NES => 'nes',
    System::NINTENDO_POKEMON_MINI => 'pokemini',
    System::NINTENDO_SNES => 'snes',
    System::NINTENDO_SWITCH => 'switch',
    System::NINTENDO_WII => 'wii',
    System::NINTENDO_WIIU => 'wiiu/roms',
    System::PICO_8 => 'pico8',
    System::SEGA_DREAMCAST => 'dreamcast',
    System::SEGA_GAME_GEAR => 'gamegear',
    System::SEGA_GENESIS => 'genesis',
    System::SEGA_MASTER_SYSTEM => 'mastersystem',
    System::SEGA_32X => 'sega32x',
    System::SEGA_CD => 'segacd',
    System::SEGA_SATURN => 'saturn',
    System::SEGA_SG_1000 => 'sg-1000',
    System::SNK_NEO_GEO => 'neogeo',
    System::SNK_NEO_GEO_CD => 'neogeocd',
    System::SNK_NEO_GEO_POCKET => 'ngp',
    System::SNK_NEO_GEO_POCKET_COLOR => 'ngpc',
    System::SONY_PLAYSTATION => 'psx',
    System::SONY_PLAYSTATION_2 => 'ps2',
    System::SONY_PLAYSTATION_PORTABLE => 'psp',
    System::SONY_PLAYSTATION_VITA => 'psvita'
  }.freeze

  def initialize(root_dir: ROOT_DIR)
    @root_dir = root_dir
  end

  def name
    'EmuDeck'
  end

  def bios_directory(_system)
    "#{@root_dir}/Emulation/bios"
  end

  def roms_directory(system)
    subdir = ROMS_SUBDIRS[system]
    return nil unless subdir

    "#{@root_dir}/Emulation/roms/#{subdir}"
  end

  protected

  def roms_subdirs
    ROMS_SUBDIRS
  end
end

# ES-DE (EmulationStation Desktop Edition) frontend (https://www.es-de.org)
class Esde
  include Frontend

  BIOS_DIR = '/Volumes/Android_Emu/BIOS'
  ROMS_DIR = '/Volumes/Android_Emu/ROMs'

  ROMS_SUBDIRS = {
    System::ARCADE_FINALBURNNEO => 'fbneo',
    System::ARCADE_MAME2003PLUS => 'arcade',
    System::ATARI_2600 => 'atari2600',
    System::ATARI_5200 => 'atari5200',
    System::ATARI_7800 => 'atari7800',
    System::ATARI_JAGUAR => 'atarijaguar',
    System::ATARI_LYNX => 'atarilynx',
    System::CBS_COLECOVISION => 'colecovision',
    System::COMMODORE_64 => 'c64',
    System::NEC_TURBOGRAFX_CD => 'tg-cd',
    System::NEC_TURBOGRAFX_16 => 'tg16',
    System::NINTENDO_3DS => 'n3ds',
    System::NINTENDO_DS => 'nds',
    System::NINTENDO_FAMICOM_DISK_SYSTEM => 'famicom',
    System::NINTENDO_GAME_BOY => 'gb',
    System::NINTENDO_GAME_BOY_ADVANCE => 'gba',
    System::NINTENDO_GAME_BOY_COLOR => 'gbc',
    System::NINTENDO_GAMECUBE => 'gamecube',
    System::NINTENDO_64 => 'n64',
    System::NINTENDO_NES => 'nes',
    System::NINTENDO_POKEMON_MINI => 'pokemini',
    System::NINTENDO_SNES => 'snes',
    System::NINTENDO_SWITCH => 'switch',
    System::NINTENDO_WII => 'wii',
    System::NINTENDO_WIIU => 'wiiu',
    System::PICO_8 => 'pico8',
    System::SEGA_DREAMCAST => 'dreamcast',
    System::SEGA_GAME_GEAR => 'gamegear',
    System::SEGA_GENESIS => 'genesis',
    System::SEGA_MASTER_SYSTEM => 'mastersystem',
    System::SEGA_32X => 'sega32x',
    System::SEGA_CD => 'segacd',
    System::SEGA_SATURN => 'saturn',
    System::SEGA_SG_1000 => 'sg-1000',
    System::SNK_NEO_GEO => 'neogeo',
    System::SNK_NEO_GEO_CD => 'neogeocd',
    System::SNK_NEO_GEO_POCKET => 'ngp',
    System::SNK_NEO_GEO_POCKET_COLOR => 'ngpc',
    System::SONY_PLAYSTATION => 'psx',
    System::SONY_PLAYSTATION_2 => 'ps2',
    System::SONY_PLAYSTATION_PORTABLE => 'psp',
    System::SONY_PLAYSTATION_VITA => 'psvita'
  }.freeze

  def initialize(bios_dir: BIOS_DIR, roms_dir: ROMS_DIR)
    @bios_dir = bios_dir
    @roms_dir = roms_dir
  end

  def name
    'ES-DE'
  end

  def bios_directory(_system)
    @bios_dir
  end

  def roms_directory(system)
    subdir = ROMS_SUBDIRS[system]
    return nil unless subdir

    "#{@roms_dir}/#{subdir}"
  end

  protected

  def roms_subdirs
    ROMS_SUBDIRS
  end
end

# MinUI frontend (https://github.com/shauninman/MinUI)
class MinUI
  include Frontend

  ROOT_DIR = '/Volumes/TUI_BRICK'

  BIOS_SUBDIRS = {
    System::NEC_TURBOGRAFX_CD => 'PCE',
    System::NINTENDO_GAME_BOY_ADVANCE => 'GBA',
    System::NINTENDO_GAME_BOY_COLOR => 'GBC',
    System::NINTENDO_GAME_BOY => 'GB',
    System::NINTENDO_POKEMON_MINI => 'PKM',
    System::NINTENDO_SUPER_GAME_BOY => 'SGB',
    System::SEGA_DREAMCAST => '.',
    System::SONY_PLAYSTATION => 'PS'
  }.freeze

  ROMS_SUBDIRS = {
    System::PICO_8 => 'Pico-8 (P8)',
    System::NEC_TURBOGRAFX_16 => 'TurboGrafx-16 (PCE)',
    System::NINTENDO_GAME_BOY => 'Game Boy (GB)',
    System::NINTENDO_GAME_BOY_ADVANCE => 'Game Boy Advance (GBA)',
    System::NINTENDO_GAME_BOY_COLOR => 'Game Boy Color (GBC)',
    System::NINTENDO_NES => 'Nintendo Entertainment System (FC)',
    System::NINTENDO_POKEMON_MINI => 'Pokémon mini (PKM)',
    System::NINTENDO_SNES => 'Super Nintendo Entertainment System (SFC)',
    System::NINTENDO_VIRTUAL_BOY => 'Virtual Boy (VB)',
    System::SEGA_GAME_GEAR => 'Sega Game Gear (GG)',
    System::SEGA_GENESIS => 'Sega Genesis (MD)',
    System::SEGA_MASTER_SYSTEM => 'Sega Master System (SMS)',
    System::SEGA_CD => 'Sega CD (MD)',
    System::SNK_NEO_GEO_POCKET_COLOR => 'Neo Geo Pocket Color (NGPC)',
    System::SONY_PLAYSTATION => 'Sony PlayStation (PS)'
  }.freeze

  def initialize(root_dir: ROOT_DIR)
    @root_dir = root_dir
  end

  def name
    'MinUI'
  end

  def bios_directory(system)
    subdir = BIOS_SUBDIRS[system]
    return nil unless subdir

    "#{@root_dir}/Bios/#{subdir}"
  end

  def roms_directory(system)
    subdir = ROMS_SUBDIRS[system]
    return nil unless subdir

    "#{@root_dir}/Roms/#{subdir}"
  end

  protected

  def roms_subdirs
    ROMS_SUBDIRS
  end
end

# MuOS frontend (https://muos.dev)
class MuOS
  include Frontend

  ROOT_DIR = '/Volumes/MUOS_SD2'

  ROMS_SUBDIRS = {
    System::PICO_8 => 'PICO-8',
    System::NEC_TURBOGRAFX_16 => 'NEC PC Engine',
    System::NEC_TURBOGRAFX_CD => 'NEC PC Engine CD',
    System::NINTENDO_GAME_BOY => 'Nintendo Game Boy',
    System::NINTENDO_GAME_BOY_ADVANCE => 'Nintendo Game Boy Advance',
    System::NINTENDO_GAME_BOY_COLOR => 'Nintendo Game Boy Color',
    System::NINTENDO_NES => 'Nintendo NES-Famicom',
    System::NINTENDO_SNES => 'Nintendo SNES-SFC',
    System::SEGA_32X => 'Sega 32X',
    System::SEGA_CD => 'Sega Mega CD - Sega CD',
    System::SEGA_GAME_GEAR => 'Sega Game Gear',
    System::SEGA_GENESIS => 'Sega Mega Drive - Genesis',
    System::SEGA_MASTER_SYSTEM => 'Sega Master System',
    System::SNK_NEO_GEO => 'SNK Neo Geo',
    System::SNK_NEO_GEO_CD => 'SNK Neo Geo CD',
    System::SNK_NEO_GEO_POCKET_COLOR => 'SNK Neo Geo Pocket - Color',
    System::SONY_PLAYSTATION => 'Sony PlayStation'
  }.freeze

  def initialize(root_dir: ROOT_DIR)
    @root_dir = root_dir
  end

  def name
    'MuOS'
  end

  def bios_directory(_system)
    "#{@root_dir}/MUOS/Bios"
  end

  def roms_directory(system)
    subdir = ROMS_SUBDIRS[system]
    return nil unless subdir

    "#{@root_dir}/ROMS/#{subdir}"
  end

  protected

  def roms_subdirs
    ROMS_SUBDIRS
  end
end

# ROCKNIX frontend (https://rocknix.org)
class Rocknix
  include Frontend

  REMOTE_HOSTNAME = 'root@retroid-pocket-5'

  def initialize(remote_hostname: REMOTE_HOSTNAME)
    @remote_hostname = remote_hostname
  end

  def name
    'ROCKNIX'
  end

  def bios_directory(_system)
    "#{@remote_hostname}:/storage/roms/bios"
  end

  def roms_directory(system)
    subdir = Esde::ROMS_SUBDIRS[system]
    return nil unless subdir

    "#{@remote_hostname}:/storage/roms/#{subdir}"
  end

  protected

  def roms_subdirs
    Esde::ROMS_SUBDIRS
  end
end

# Onion frontend (https://onionui.github.io)
class Onion
  include Frontend

  ROOT_DIR = '/Volumes/ONION'

  ROMS_SUBDIRS = {
    System::ATARI_2600 => 'ATARI',
    System::ATARI_5200 => 'FIFTYTWOHUNDRED',
    System::ATARI_7800 => 'SEVENTYEIGHTHUNDRED',
    System::ATARI_LYNX => 'LYNX',
    System::CBS_COLECOVISION => 'COLECO',
    System::COMMODORE_64 => 'COMMODORE',
    System::ARCADE_MAME2003PLUS => 'ARCADE',
    System::NEC_SUPERGRAFX => 'SGFX',
    System::NEC_TURBOGRAFX_16 => 'PCE',
    System::NEC_TURBOGRAFX_CD => 'PCECD',
    System::NINTENDO_64 => 'N64',
    System::NINTENDO_FAMICOM_DISK_SYSTEM => 'FDS',
    System::NINTENDO_DS => 'NDS',
    System::NINTENDO_GAME_BOY => 'GB',
    System::NINTENDO_GAME_BOY_ADVANCE => 'GBA',
    System::NINTENDO_GAME_BOY_COLOR => 'GBC',
    System::NINTENDO_NES => 'FC',
    System::NINTENDO_POKEMON_MINI => 'POKE',
    System::NINTENDO_SUPER_GAME_BOY => 'SGB',
    System::NINTENDO_SNES => 'SFC',
    System::PICO_8 => 'PICO8',
    System::SEGA_32X => 'THIRTYTWOX',
    System::SEGA_CD => 'SEGACD',
    System::SEGA_DREAMCAST => 'DC',
    System::SEGA_GAME_GEAR => 'GG',
    System::SEGA_GENESIS => 'MD',
    System::SEGA_MASTER_SYSTEM => 'MS',
    System::SEGA_SG_1000 => 'SEGASGONE',
    System::SNK_NEO_GEO => 'NEOGEO',
    System::SNK_NEO_GEO_CD => 'NEOCD',
    System::SNK_NEO_GEO_POCKET => 'NGP',
    System::SNK_NEO_GEO_POCKET_COLOR => 'NGPC',
    System::SONY_PLAYSTATION => 'PS',
    System::SONY_PLAYSTATION_PORTABLE => 'PSP'
  }.freeze

  def initialize(root_dir: ROOT_DIR)
    @root_dir = root_dir
  end

  def name
    'Onion'
  end

  def bios_directory(_system)
    "#{@root_dir}/BIOS"
  end

  def roms_directory(system)
    subdir = ROMS_SUBDIRS[system]
    return nil unless subdir

    "#{@root_dir}/Roms/#{subdir}"
  end

  protected

  def roms_subdirs
    ROMS_SUBDIRS
  end
end

# Spruce frontend (https://spruceui.github.io/)
class Spruce
  include Frontend

  ROOT_DIR = '/Volumes/SPRUCE'

  ROMS_SUBDIRS = {
    System::ATARI_2600 => 'ATARI',
    System::ATARI_5200 => 'FIFTYTWOHUNDRED',
    System::ATARI_7800 => 'SEVENTYEIGHTHUNDRED',
    System::ATARI_LYNX => 'LYNX',
    System::CBS_COLECOVISION => 'COLECO',
    System::COMMODORE_64 => 'COMMODORE',
    System::ARCADE_MAME2003PLUS => 'ARCADE_MAME2003PLUS',
    System::NEC_SUPERGRAFX => 'SGFX',
    System::NEC_TURBOGRAFX_16 => 'PCE',
    System::NEC_TURBOGRAFX_CD => 'PCECD',
    System::NINTENDO_64 => 'N64',
    System::NINTENDO_FAMICOM_DISK_SYSTEM => 'FDS',
    System::NINTENDO_DS => 'NDS',
    System::NINTENDO_GAME_BOY => 'GB',
    System::NINTENDO_GAME_BOY_ADVANCE => 'GBA',
    System::NINTENDO_GAME_BOY_COLOR => 'GBC',
    System::NINTENDO_NES => 'FC',
    System::NINTENDO_POKEMON_MINI => 'POKE',
    System::NINTENDO_SUPER_GAME_BOY => 'SGB',
    System::NINTENDO_SNES => 'SFC',
    System::PICO_8 => 'PICO8',
    System::SEGA_32X => 'THIRTYTWOX',
    System::SEGA_CD => 'SEGACD',
    System::SEGA_DREAMCAST => 'DC',
    System::SEGA_GAME_GEAR => 'GG',
    System::SEGA_GENESIS => 'MD',
    System::SEGA_MASTER_SYSTEM => 'MS',
    System::SEGA_SG_1000 => 'SEGASGONE',
    System::SNK_NEO_GEO => 'NEOGEO',
    System::SNK_NEO_GEO_CD => 'NEOCD',
    System::SNK_NEO_GEO_POCKET => 'NGP',
    System::SNK_NEO_GEO_POCKET_COLOR => 'NGPC',
    System::SONY_PLAYSTATION => 'PS',
    System::SONY_PLAYSTATION_PORTABLE => 'PSP'
  }.freeze

  def initialize(root_dir: ROOT_DIR)
    @root_dir = root_dir
  end

  def name
    'Spruce'
  end

  def bios_directory(_system)
    "#{@root_dir}/BIOS"
  end

  def roms_directory(system)
    subdir = ROMS_SUBDIRS[system]
    return nil unless subdir

    "#{@root_dir}/Roms/#{subdir}"
  end

  protected

  def roms_subdirs
    ROMS_SUBDIRS
  end
end

# File copier service
class FileCopier
  def initialize(frontend, dry_run: false)
    @frontend = frontend
    @dry_run = dry_run
  end

  def copy_bios_files(systems)
    systems.each do |system|
      source_subdir = SourceConfig::BIOS_SUBDIRS[system]
      next unless source_subdir

      destination_dir = @frontend.bios_directory(system)
      next unless destination_dir

      source_path = "#{SourceConfig::BIOS_DIR}/#{source_subdir}/"
      destination_path = "#{destination_dir}/"

      rsync(source_path, destination_path)
    end
  end

  def copy_rom_files(systems, copy_source_directory: false)
    systems.each do |system|
      source_subdir = SourceConfig::ROMS_SUBDIRS[system]

      unless source_subdir
        puts "No source ROMS for #{system}."
        next
      end

      destination_dir = @frontend.roms_directory(system)

      unless destination_dir
        puts "No destination directory for #{system} on #{@frontend.name}."
        next
      end

      source_path = "#{SourceConfig::ROMS_DIR}/#{source_subdir}/"
      source_path += '/' unless copy_source_directory
      destination_path = "#{destination_dir}/"

      rsync(source_path, destination_path)
    end
  end

  private

  def rsync(source, destination)
    command = ['rsync', '-avP', source, destination]
    puts "rsync -avP \"#{source}\" \"#{destination}\""

    return if @dry_run

    system(*command)
  end
end

# Display ROM sizes utility
class RomSizeDisplay
  def self.display(systems)
    sorted_systems = systems.sort_by(&:to_s)
    rom_directories = []

    sorted_systems.each do |system|
      source_subdir = SourceConfig::ROMS_SUBDIRS[system]
      next unless source_subdir

      rom_directories << "#{SourceConfig::LOCAL_ROMS_DIR}/'#{source_subdir}/'"
    end

    return if rom_directories.empty?

    directories_str = rom_directories.join(' ')
    command = "du --total --summarize --human-readable #{directories_str}"

    system('ssh', SourceConfig::REMOTE_HOSTNAME, command)
  end
end

# Frontend factory
class FrontendFactory
  FRONTENDS = {
    'batocera' => Batocera,
    'knulli' => Knulli,
    'emudeck' => EmuDeck,
    'esde' => Esde,
    'minui' => MinUI,
    'muos' => MuOS,
    'rocknix' => Rocknix,
    'onion' => Onion,
    'spruce' => Spruce
  }.freeze

  def self.create(name)
    frontend_class = FRONTENDS[name.downcase]
    return nil unless frontend_class

    frontend_class.new
  end

  def self.available_frontends
    FRONTENDS.keys
  end
end

# Level/ROM pack configuration
class LevelConfig
  LEVELS = {
    '1' => [],
    '2' => [],
    '3' => [],
    '4' => [],
    '5' => []
  }.freeze

  def self.systems_for_level(level)
    normalized = level.to_s.downcase.gsub(/level[-_]?/, '')
    LEVELS[normalized]
  end

  def self.valid_level?(level)
    normalized = level.to_s.downcase.gsub(/level[-_]?/, '')
    LEVELS.key?(normalized)
  end
end

# Command-line interface
class CLI
  def initialize(args)
    @args = args
  end

  def run
    if @args.empty? || @args.include?('--help') || @args.include?('-h')
      print_usage
      return 0
    end

    destination = @args[0]&.downcase
    level = @args[1]
    _root_dir = @args[2]

    systems = parse_systems(level)
    return 1 if systems.nil?

    if %w[sizes rom-sizes rom_sizes].include?(destination)
      RomSizeDisplay.display(systems)
      return 0
    end

    frontend = FrontendFactory.create(destination)

    unless frontend
      puts "#{@args[0]} is not a supported destination OS/application."
      puts "Available: #{FrontendFactory.available_frontends.join(', ')}"
      return 1
    end

    copier = FileCopier.new(frontend)
    copier.copy_bios_files(systems)
    copier.copy_rom_files(systems)

    0
  end

  private

  def parse_systems(level)
    return [] if level.nil? || level.empty?

    unless LevelConfig.valid_level?(level)
      puts "#{level} is not a supported ROM pack name."
      return nil
    end

    LevelConfig.systems_for_level(level)
  end

  def print_usage
    puts <<~USAGE
      Usage: #{$PROGRAM_NAME} DESTINATION [LEVEL] [ROOT_DIR]

      Copy BIOS and ROM files to emulation frontends.

      Arguments:
        DESTINATION  Target OS/application (#{FrontendFactory.available_frontends.join(', ')}, sizes)
        LEVEL        ROM pack level (1-5 or level-1 through level-5)
        ROOT_DIR     Optional destination root directory

      Examples:
        #{$PROGRAM_NAME} batocera level-1
        #{$PROGRAM_NAME} sizes level-2
        #{$PROGRAM_NAME} esde 3
    USAGE
  end
end

# Main entry point
if __FILE__ == $PROGRAM_NAME
  exit CLI.new(ARGV).run
end
