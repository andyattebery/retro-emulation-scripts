#!/usr/bin/env python3
# /// script
# requires-python = ">=3.12"
# dependencies = ["pyyaml"]
# ///
"""Copy BIOS and ROM files to various emulation frontends and operating systems."""

import argparse
import subprocess
import sys
from abc import ABC, abstractmethod
from enum import Enum
from pathlib import Path, PurePosixPath

import yaml


class System(Enum):
    """Gaming system identifiers."""

    ARCADE_FINALBURNNEO = "arcade_finalburnneo"
    ARCADE_MAME = "arcade_mame"
    ARCADE_MAME2003PLUS = "arcade_mame2003plus"
    ATARI_2600 = "atari_2600"
    ATARI_5200 = "atari_5200"
    ATARI_7800 = "atari_7800"
    ATARI_JAGUAR = "atari_jaguar"
    ATARI_LYNX = "atari_lynx"
    CBS_COLECOVISION = "cbs_colecovision"
    COMMODORE_64 = "commodore_64"
    MICROSOFT_XBOX = "microsoft_xbox"
    MICROSOFT_XBOX_360 = "microsoft_xbox_360"
    NEC_SUPERGRAFX = "nec_supergrafx"
    NEC_TURBOGRAFX_16 = "nec_turbografx_16"
    NEC_TURBOGRAFX_CD = "nec_turbografx_cd"
    NINTENDO_3DS = "nintendo_3ds"
    NINTENDO_64 = "nintendo_64"
    NINTENDO_DS = "nintendo_ds"
    NINTENDO_FAMICOM_DISK_SYSTEM = "nintendo_famicom_disk_system"
    NINTENDO_GAME_BOY_ADVANCE = "nintendo_game_boy_advance"
    NINTENDO_GAME_BOY_COLOR = "nintendo_game_boy_color"
    NINTENDO_GAME_BOY = "nintendo_game_boy"
    NINTENDO_GAMECUBE = "nintendo_gamecube"
    NINTENDO_NES = "nintendo_nes"
    NINTENDO_POKEMON_MINI = "nintendo_pokemon_mini"
    NINTENDO_SNES = "nintendo_snes"
    NINTENDO_SUPER_GAME_BOY = "nintendo_super_game_boy"
    NINTENDO_SWITCH = "nintendo_switch"
    NINTENDO_VIRTUAL_BOY = "nintendo_virtual_boy"
    NINTENDO_WIIU = "nintendo_wiiu"
    NINTENDO_WII = "nintendo_wii"
    PICO_8 = "pico_8"
    SEGA_32X = "sega_32x"
    SEGA_CD = "sega_cd"
    SEGA_DREAMCAST = "sega_dreamcast"
    SEGA_GAME_GEAR = "sega_game_gear"
    SEGA_GENESIS = "sega_genesis"
    SEGA_MASTER_SYSTEM = "sega_master_system"
    SEGA_NAOMI = "sega_naomi"
    SEGA_SATURN = "sega_saturn"
    SEGA_SG_1000 = "sega_sg_1000"
    SNK_NEO_GEO = "snk_neo_geo"
    SNK_NEO_GEO_CD = "snk_neo_geo_cd"
    SNK_NEO_GEO_POCKET = "snk_neo_geo_pocket"
    SNK_NEO_GEO_POCKET_COLOR = "snk_neo_geo_pocket_color"
    SONY_PLAYSTATION_2 = "sony_playstation_2"
    SONY_PLAYSTATION_3 = "sony_playstation_3"
    SONY_PLAYSTATION_PORTABLE = "sony_playstation_portable"
    SONY_PLAYSTATION_VITA = "sony_playstation_vita"
    SONY_PLAYSTATION = "sony_playstation"


class SourceConfig:
    """Source directory configuration."""

    def __init__(
        self,
        source_bios_dir: str,
        source_roms_dir: str,
        source_batocera_art_dir: str,
        remote_hostname: str,
        remote_source: bool,
        bios_subdirs: dict[System, str],
        roms_subdirs: dict[System, str],
    ):
        self.source_bios_dir = source_bios_dir
        self.source_roms_dir = source_roms_dir
        self.source_batocera_art_dir = source_batocera_art_dir
        self.remote_hostname = remote_hostname
        self._remote_source = remote_source
        self.bios_subdirs = bios_subdirs
        self.roms_subdirs = roms_subdirs

    @classmethod
    def from_yaml(cls, path: str | Path, remote_source: bool = True) -> "SourceConfig":
        """Load source configuration from a YAML file."""
        with open(path) as f:
            data = yaml.safe_load(f)
        bios_subdirs = {System(k): v for k, v in data["bios_subdirs"].items()}
        roms_subdirs = {System(k): v for k, v in data["roms_subdirs"].items()}
        return cls(
            source_bios_dir=data["source_bios_dir"],
            source_roms_dir=data["source_roms_dir"],
            source_batocera_art_dir=data["source_batocera_art_dir"],
            remote_hostname=data["remote_hostname"],
            remote_source=remote_source,
            bios_subdirs=bios_subdirs,
            roms_subdirs=roms_subdirs,
        )

    def _prefix(self, path: str) -> str:
        if self._remote_source:
            return f"{self.remote_hostname}:{path}"
        return path

    @property
    def bios_dir(self) -> str:
        """BIOS directory path."""
        return self._prefix(self.source_bios_dir)

    @property
    def roms_dir(self) -> str:
        """ROMs directory path."""
        return self._prefix(self.source_roms_dir)

    @property
    def batocera_art_dir(self) -> str:
        """Batocera art directory path."""
        return self._prefix(self.source_batocera_art_dir)


class Frontend(ABC):
    """Abstract base class for emulation frontends."""

    def __init__(self, destination_dir: str):
        self._destination_dir = destination_dir

    @property
    @abstractmethod
    def name(self) -> str:
        """Return the frontend name."""

    @abstractmethod
    def bios_directory(self, system: System) -> str | None:
        """Return the BIOS directory for a system."""

    @abstractmethod
    def roms_directory(self, system: System) -> str | None:
        """Return the ROMs directory for a system."""

    @property
    def supported_systems(self) -> list[System]:
        """Return list of supported systems."""
        return list(self._roms_subdirs.keys())

    @property
    @abstractmethod
    def _roms_subdirs(self) -> dict[System, str]:
        """Return the ROMs subdirectory mapping."""


class Batocera(Frontend):
    """Batocera/Knulli frontend (https://wiki.batocera.org/systems)."""

    ROMS_SUBDIRS: dict[System, str] = {
        System.ARCADE_FINALBURNNEO: "fbneo",
        System.ARCADE_MAME2003PLUS: "mame",
        System.ATARI_2600: "atari2600",
        System.ATARI_5200: "atari5200",
        System.ATARI_7800: "atari7800",
        System.ATARI_JAGUAR: "jaguar",
        System.ATARI_LYNX: "lynx",
        System.CBS_COLECOVISION: "colecovision",
        System.COMMODORE_64: "c64",
        System.MICROSOFT_XBOX: "xbox",
        System.MICROSOFT_XBOX_360: "xbox360",
        System.NEC_SUPERGRAFX: "supergrafx",
        System.NEC_TURBOGRAFX_CD: "pcenginecd",
        System.NEC_TURBOGRAFX_16: "pcengine",
        System.NINTENDO_3DS: "3ds",
        System.NINTENDO_DS: "nds",
        System.NINTENDO_FAMICOM_DISK_SYSTEM: "fds",
        System.NINTENDO_GAME_BOY: "gb",
        System.NINTENDO_GAME_BOY_ADVANCE: "gba",
        System.NINTENDO_GAME_BOY_COLOR: "gbc",
        System.NINTENDO_GAMECUBE: "gamecube",
        System.NINTENDO_64: "n64",
        System.NINTENDO_NES: "nes",
        System.NINTENDO_POKEMON_MINI: "pokemini",
        System.NINTENDO_SUPER_GAME_BOY: "sgb",
        System.NINTENDO_SNES: "snes",
        System.NINTENDO_SWITCH: "switch",
        System.NINTENDO_WII: "wii",
        System.NINTENDO_WIIU: "wiiu",
        System.PICO_8: "pico8",
        System.SEGA_DREAMCAST: "dreamcast",
        System.SEGA_GAME_GEAR: "gamegear",
        System.SEGA_GENESIS: "megadrive",
        System.SEGA_MASTER_SYSTEM: "mastersystem",
        System.SEGA_32X: "sega32x",
        System.SEGA_CD: "segacd",
        System.SEGA_SATURN: "saturn",
        System.SEGA_SG_1000: "sg1000",
        System.SNK_NEO_GEO: "neogeo",
        System.SNK_NEO_GEO_CD: "neogeocd",
        System.SNK_NEO_GEO_POCKET: "ngp",
        System.SNK_NEO_GEO_POCKET_COLOR: "ngpc",
        System.SONY_PLAYSTATION: "psx",
        System.SONY_PLAYSTATION_2: "ps2",
        System.SONY_PLAYSTATION_PORTABLE: "psp",
        System.SONY_PLAYSTATION_VITA: "psvita",
    }

    def __init__(self, destination_dir: str):
        self._destination_dir = destination_dir

    @property
    def name(self) -> str:
        return "Batocera"

    def bios_directory(self, system: System) -> str | None:
        return str(PurePosixPath(self._destination_dir) / "bios")

    def roms_directory(self, system: System) -> str | None:
        subdir = self.ROMS_SUBDIRS.get(system)
        if not subdir:
            return None
        return str(PurePosixPath(self._destination_dir) / "roms" / subdir)

    @property
    def _roms_subdirs(self) -> dict[System, str]:
        return self.ROMS_SUBDIRS


class Knulli(Batocera):
    """Knulli frontend (uses Batocera structure)."""

    @property
    def name(self) -> str:
        return "Knulli"


class EmuDeck(Frontend):
    """EmuDeck frontend (https://emudeck.github.io)."""

    ROMS_SUBDIRS: dict[System, str] = {
        System.ARCADE_MAME2003PLUS: "arcade",
        System.ATARI_2600: "atari2600",
        System.ATARI_5200: "atari5200",
        System.ATARI_7800: "atari7800",
        System.ATARI_JAGUAR: "atarijaguar",
        System.ATARI_LYNX: "atarilynx",
        System.CBS_COLECOVISION: "colecovision",
        System.COMMODORE_64: "c64",
        System.NEC_TURBOGRAFX_CD: "tg-cd",
        System.NEC_TURBOGRAFX_16: "tg16",
        System.NINTENDO_3DS: "n3ds",
        System.NINTENDO_DS: "nds",
        System.NINTENDO_FAMICOM_DISK_SYSTEM: "famicom",
        System.NINTENDO_GAME_BOY: "gb",
        System.NINTENDO_GAME_BOY_ADVANCE: "gba",
        System.NINTENDO_GAME_BOY_COLOR: "gbc",
        System.NINTENDO_GAMECUBE: "gamecube",
        System.NINTENDO_64: "n64",
        System.NINTENDO_NES: "nes",
        System.NINTENDO_POKEMON_MINI: "pokemini",
        System.NINTENDO_SNES: "snes",
        System.NINTENDO_SWITCH: "switch",
        System.NINTENDO_WII: "wii",
        System.NINTENDO_WIIU: "wiiu/roms",
        System.PICO_8: "pico8",
        System.SEGA_DREAMCAST: "dreamcast",
        System.SEGA_GAME_GEAR: "gamegear",
        System.SEGA_GENESIS: "genesis",
        System.SEGA_MASTER_SYSTEM: "mastersystem",
        System.SEGA_32X: "sega32x",
        System.SEGA_CD: "segacd",
        System.SEGA_SATURN: "saturn",
        System.SEGA_SG_1000: "sg-1000",
        System.SNK_NEO_GEO: "neogeo",
        System.SNK_NEO_GEO_CD: "neogeocd",
        System.SNK_NEO_GEO_POCKET: "ngp",
        System.SNK_NEO_GEO_POCKET_COLOR: "ngpc",
        System.SONY_PLAYSTATION: "psx",
        System.SONY_PLAYSTATION_2: "ps2",
        System.SONY_PLAYSTATION_PORTABLE: "psp",
        System.SONY_PLAYSTATION_VITA: "psvita",
    }

    def __init__(self, destination_dir: str):
        self._destination_dir = destination_dir

    @property
    def name(self) -> str:
        return "EmuDeck"

    def bios_directory(self, system: System) -> str | None:
        return str(PurePosixPath(self._destination_dir) / "Emulation" / "bios")

    def roms_directory(self, system: System) -> str | None:
        subdir = self.ROMS_SUBDIRS.get(system)
        if not subdir:
            return None
        return str(PurePosixPath(self._destination_dir) / "Emulation" / "roms" / subdir)

    @property
    def _roms_subdirs(self) -> dict[System, str]:
        return self.ROMS_SUBDIRS


class EsDe(Frontend):
    """ES-DE (EmulationStation Desktop Edition) frontend (https://www.es-de.org)."""

    ROMS_SUBDIRS: dict[System, str] = {
        System.ARCADE_FINALBURNNEO: "fbneo",
        System.ARCADE_MAME2003PLUS: "arcade",
        System.ATARI_2600: "atari2600",
        System.ATARI_5200: "atari5200",
        System.ATARI_7800: "atari7800",
        System.ATARI_JAGUAR: "atarijaguar",
        System.ATARI_LYNX: "atarilynx",
        System.CBS_COLECOVISION: "colecovision",
        System.COMMODORE_64: "c64",
        System.NEC_TURBOGRAFX_CD: "tg-cd",
        System.NEC_TURBOGRAFX_16: "tg16",
        System.NINTENDO_3DS: "n3ds",
        System.NINTENDO_DS: "nds",
        System.NINTENDO_FAMICOM_DISK_SYSTEM: "fds",
        System.NINTENDO_GAME_BOY: "gb",
        System.NINTENDO_GAME_BOY_ADVANCE: "gba",
        System.NINTENDO_GAME_BOY_COLOR: "gbc",
        System.NINTENDO_GAMECUBE: "gc",
        System.NINTENDO_64: "n64",
        System.NINTENDO_NES: "nes",
        System.NINTENDO_POKEMON_MINI: "pokemini",
        System.NINTENDO_SNES: "snes",
        System.NINTENDO_SWITCH: "switch",
        System.NINTENDO_WII: "wii",
        System.NINTENDO_WIIU: "wiiu",
        System.PICO_8: "pico8",
        System.SEGA_DREAMCAST: "dreamcast",
        System.SEGA_GAME_GEAR: "gamegear",
        System.SEGA_GENESIS: "genesis",
        System.SEGA_MASTER_SYSTEM: "mastersystem",
        System.SEGA_32X: "sega32x",
        System.SEGA_CD: "segacd",
        System.SEGA_SATURN: "saturn",
        System.SEGA_SG_1000: "sg-1000",
        System.SNK_NEO_GEO: "neogeo",
        System.SNK_NEO_GEO_CD: "neogeocd",
        System.SNK_NEO_GEO_POCKET: "ngp",
        System.SNK_NEO_GEO_POCKET_COLOR: "ngpc",
        System.SONY_PLAYSTATION: "psx",
        System.SONY_PLAYSTATION_2: "ps2",
        System.SONY_PLAYSTATION_PORTABLE: "psp",
        System.SONY_PLAYSTATION_VITA: "psvita",
    }

    def __init__(self, destination_dir: str):
        self._destination_dir = destination_dir

    @property
    def name(self) -> str:
        return "ES-DE"

    def bios_directory(self, system: System) -> str | None:
        return str(PurePosixPath(self._destination_dir) / "BIOS")

    def roms_directory(self, system: System) -> str | None:
        subdir = self.ROMS_SUBDIRS.get(system)
        if not subdir:
            return None
        return str(PurePosixPath(self._destination_dir) / "ROMs" / subdir)

    @property
    def _roms_subdirs(self) -> dict[System, str]:
        return self.ROMS_SUBDIRS


class MinUI(Frontend):
    """MinUI frontend (https://github.com/shauninman/MinUI)."""

    BIOS_SUBDIRS: dict[System, str] = {
        System.NEC_TURBOGRAFX_CD: "PCE",
        System.NINTENDO_GAME_BOY_ADVANCE: "GBA",
        System.NINTENDO_GAME_BOY_COLOR: "GBC",
        System.NINTENDO_GAME_BOY: "GB",
        System.NINTENDO_POKEMON_MINI: "PKM",
        System.NINTENDO_SUPER_GAME_BOY: "SGB",
        System.SEGA_DREAMCAST: ".",
        System.SONY_PLAYSTATION: "PS",
    }

    ROMS_SUBDIRS: dict[System, str] = {
        System.PICO_8: "Pico-8 (P8)",
        System.NEC_TURBOGRAFX_16: "TurboGrafx-16 (PCE)",
        System.NINTENDO_GAME_BOY: "Game Boy (GB)",
        System.NINTENDO_GAME_BOY_ADVANCE: "Game Boy Advance (GBA)",
        System.NINTENDO_GAME_BOY_COLOR: "Game Boy Color (GBC)",
        System.NINTENDO_NES: "Nintendo Entertainment System (FC)",
        System.NINTENDO_POKEMON_MINI: "Pokémon mini (PKM)",
        System.NINTENDO_SNES: "Super Nintendo Entertainment System (SFC)",
        System.NINTENDO_VIRTUAL_BOY: "Virtual Boy (VB)",
        System.SEGA_GAME_GEAR: "Sega Game Gear (GG)",
        System.SEGA_GENESIS: "Sega Genesis (MD)",
        System.SEGA_MASTER_SYSTEM: "Sega Master System (SMS)",
        System.SEGA_CD: "Sega CD (MD)",
        System.SNK_NEO_GEO_POCKET_COLOR: "Neo Geo Pocket Color (NGPC)",
        System.SONY_PLAYSTATION: "Sony PlayStation (PS)",
    }

    def __init__(self, destination_dir: str):
        self._destination_dir = destination_dir

    @property
    def name(self) -> str:
        return "MinUI"

    def bios_directory(self, system: System) -> str | None:
        subdir = self.BIOS_SUBDIRS.get(system)
        if not subdir:
            return None
        return str(PurePosixPath(self._destination_dir) / "Bios" / subdir)

    def roms_directory(self, system: System) -> str | None:
        subdir = self.ROMS_SUBDIRS.get(system)
        if not subdir:
            return None
        return str(PurePosixPath(self._destination_dir) / "Roms" / subdir)

    @property
    def _roms_subdirs(self) -> dict[System, str]:
        return self.ROMS_SUBDIRS


class MuOS(Frontend):
    """MuOS frontend (https://muos.dev)."""

    ROMS_SUBDIRS: dict[System, str] = {
        System.PICO_8: "PICO-8",
        System.NEC_TURBOGRAFX_16: "NEC PC Engine",
        System.NEC_TURBOGRAFX_CD: "NEC PC Engine CD",
        System.NINTENDO_GAME_BOY: "Nintendo Game Boy",
        System.NINTENDO_GAME_BOY_ADVANCE: "Nintendo Game Boy Advance",
        System.NINTENDO_GAME_BOY_COLOR: "Nintendo Game Boy Color",
        System.NINTENDO_NES: "Nintendo NES-Famicom",
        System.NINTENDO_SNES: "Nintendo SNES-SFC",
        System.SEGA_32X: "Sega 32X",
        System.SEGA_CD: "Sega Mega CD - Sega CD",
        System.SEGA_GAME_GEAR: "Sega Game Gear",
        System.SEGA_GENESIS: "Sega Mega Drive - Genesis",
        System.SEGA_MASTER_SYSTEM: "Sega Master System",
        System.SNK_NEO_GEO: "SNK Neo Geo",
        System.SNK_NEO_GEO_CD: "SNK Neo Geo CD",
        System.SNK_NEO_GEO_POCKET_COLOR: "SNK Neo Geo Pocket - Color",
        System.SONY_PLAYSTATION: "Sony PlayStation",
    }

    def __init__(self, destination_dir: str):
        self._destination_dir = destination_dir

    @property
    def name(self) -> str:
        return "MuOS"

    def bios_directory(self, system: System) -> str | None:
        return str(PurePosixPath(self._destination_dir) / "MUOS" / "Bios")

    def roms_directory(self, system: System) -> str | None:
        subdir = self.ROMS_SUBDIRS.get(system)
        if not subdir:
            return None
        return str(PurePosixPath(self._destination_dir) / "ROMS" / subdir)

    @property
    def _roms_subdirs(self) -> dict[System, str]:
        return self.ROMS_SUBDIRS


class Rocknix(Frontend):
    """ROCKNIX frontend (https://rocknix.org)."""

    def __init__(self, destination_dir: str):
        self._destination_dir = destination_dir

    @property
    def name(self) -> str:
        return "ROCKNIX"

    def bios_directory(self, system: System) -> str | None:
        return str(PurePosixPath(self._destination_dir) / "bios")

    def roms_directory(self, system: System) -> str | None:
        subdir = EsDe.ROMS_SUBDIRS.get(system)
        if not subdir:
            return None
        return str(PurePosixPath(self._destination_dir) / subdir)

    @property
    def _roms_subdirs(self) -> dict[System, str]:
        return EsDe.ROMS_SUBDIRS


class Onion(Frontend):
    """Onion frontend (https://onionui.github.io)."""

    ROMS_SUBDIRS: dict[System, str] = {
        System.ATARI_2600: "ATARI",
        System.ATARI_5200: "FIFTYTWOHUNDRED",
        System.ATARI_7800: "SEVENTYEIGHTHUNDRED",
        System.ATARI_LYNX: "LYNX",
        System.CBS_COLECOVISION: "COLECO",
        System.COMMODORE_64: "COMMODORE",
        System.ARCADE_MAME2003PLUS: "ARCADE",
        System.NEC_SUPERGRAFX: "SGFX",
        System.NEC_TURBOGRAFX_16: "PCE",
        System.NEC_TURBOGRAFX_CD: "PCECD",
        System.NINTENDO_64: "N64",
        System.NINTENDO_FAMICOM_DISK_SYSTEM: "FDS",
        System.NINTENDO_DS: "NDS",
        System.NINTENDO_GAME_BOY: "GB",
        System.NINTENDO_GAME_BOY_ADVANCE: "GBA",
        System.NINTENDO_GAME_BOY_COLOR: "GBC",
        System.NINTENDO_NES: "FC",
        System.NINTENDO_POKEMON_MINI: "POKE",
        System.NINTENDO_SUPER_GAME_BOY: "SGB",
        System.NINTENDO_SNES: "SFC",
        System.PICO_8: "PICO",
        System.SEGA_32X: "THIRTYTWOX",
        System.SEGA_CD: "SEGACD",
        System.SEGA_DREAMCAST: "DC",
        System.SEGA_GAME_GEAR: "GG",
        System.SEGA_GENESIS: "MD",
        System.SEGA_MASTER_SYSTEM: "MS",
        System.SEGA_SG_1000: "SEGASGONE",
        System.SNK_NEO_GEO: "NEOGEO",
        System.SNK_NEO_GEO_CD: "NEOCD",
        System.SNK_NEO_GEO_POCKET: "NGP",
        System.SNK_NEO_GEO_POCKET_COLOR: "NGPC",
        System.SONY_PLAYSTATION: "PS",
        System.SONY_PLAYSTATION_PORTABLE: "PSP",
    }

    def __init__(self, destination_dir: str):
        self._destination_dir = destination_dir

    @property
    def name(self) -> str:
        return "Onion"

    def bios_directory(self, system: System) -> str | None:
        return str(PurePosixPath(self._destination_dir) / "BIOS")

    def roms_directory(self, system: System) -> str | None:
        subdir = self.ROMS_SUBDIRS.get(system)
        if not subdir:
            return None
        return str(PurePosixPath(self._destination_dir) / "Roms" / subdir)

    @property
    def _roms_subdirs(self) -> dict[System, str]:
        return self.ROMS_SUBDIRS


class Spruce(Frontend):
    """Spruce frontend (https://spruceui.github.io/)."""

    ROMS_SUBDIRS: dict[System, str] = {
        System.ATARI_2600: "ATARI",
        System.ATARI_5200: "FIFTYTWOHUNDRED",
        System.ATARI_7800: "SEVENTYEIGHTHUNDRED",
        System.ATARI_LYNX: "LYNX",
        System.CBS_COLECOVISION: "COLECO",
        System.COMMODORE_64: "COMMODORE",
        System.ARCADE_MAME2003PLUS: "MAME2003PLUS",
        System.NEC_SUPERGRAFX: "SGFX",
        System.NEC_TURBOGRAFX_16: "PCE",
        System.NEC_TURBOGRAFX_CD: "PCECD",
        System.NINTENDO_64: "N64",
        System.NINTENDO_FAMICOM_DISK_SYSTEM: "FDS",
        System.NINTENDO_DS: "NDS",
        System.NINTENDO_GAME_BOY: "GB",
        System.NINTENDO_GAME_BOY_ADVANCE: "GBA",
        System.NINTENDO_GAME_BOY_COLOR: "GBC",
        System.NINTENDO_NES: "FC",
        System.NINTENDO_POKEMON_MINI: "POKE",
        System.NINTENDO_SUPER_GAME_BOY: "SGB",
        System.NINTENDO_SNES: "SFC",
        System.PICO_8: "PICO8",
        System.SEGA_32X: "THIRTYTWOX",
        System.SEGA_CD: "SEGACD",
        System.SEGA_DREAMCAST: "DC",
        System.SEGA_GAME_GEAR: "GG",
        System.SEGA_GENESIS: "MD",
        System.SEGA_MASTER_SYSTEM: "MS",
        System.SEGA_SG_1000: "SEGASGONE",
        System.SNK_NEO_GEO: "NEOGEO",
        System.SNK_NEO_GEO_CD: "NEOCD",
        System.SNK_NEO_GEO_POCKET: "NGP",
        System.SNK_NEO_GEO_POCKET_COLOR: "NGPC",
        System.SONY_PLAYSTATION: "PS",
        System.SONY_PLAYSTATION_PORTABLE: "PSP",
    }

    def __init__(self, destination_dir: str):
        self._destination_dir = destination_dir

    @property
    def name(self) -> str:
        return "Spruce"

    def bios_directory(self, system: System) -> str | None:
        return str(PurePosixPath(self._destination_dir) / "BIOS")

    def roms_directory(self, system: System) -> str | None:
        subdir = self.ROMS_SUBDIRS.get(system)
        if not subdir:
            return None
        return str(PurePosixPath(self._destination_dir) / "Roms" / subdir)

    @property
    def _roms_subdirs(self) -> dict[System, str]:
        return self.ROMS_SUBDIRS


class FileCopier:
    """Service for copying BIOS and ROM files to a frontend."""

    def __init__(
        self,
        frontend: Frontend,
        source_config: SourceConfig,
        dry_run: bool = False,
    ):
        self._frontend = frontend
        self._source_config = source_config
        self._dry_run = dry_run

    def copy_bios_files(self, systems: list[System]) -> None:
        """Copy BIOS files for the given systems."""
        for system in systems:
            source_subdir = self._source_config.bios_subdirs.get(system)
            if not source_subdir:
                continue

            destination_dir = self._frontend.bios_directory(system)
            if not destination_dir:
                continue

            source_path = str(PurePosixPath(self._source_config.bios_dir) / source_subdir) + "/"
            destination_path = destination_dir + "/"

            self._rsync(source_path, destination_path)

    def copy_rom_files(
        self, systems: list[System], copy_source_directory: bool = False
    ) -> None:
        """Copy ROM files for the given systems."""
        for system in systems:
            source_subdir = self._source_config.roms_subdirs.get(system)

            if not source_subdir:
                print(f"No source ROMS for {system.value}.")
                continue

            destination_dir = self._frontend.roms_directory(system)

            if not destination_dir:
                print(
                    f"No destination directory for {system.value} on {self._frontend.name}."
                )
                continue

            source_path = str(PurePosixPath(self._source_config.roms_dir) / source_subdir) + "/"
            if not copy_source_directory:
                source_path += "/"
            destination_path = destination_dir

            self._rsync(source_path, destination_path)

    def _rsync(self, source: str, destination: str) -> None:
        """Execute rsync command."""
        print(f'rsync -avP --size-only "{source}" "{destination}"')

        if self._dry_run:
            return

        subprocess.run(
            ["rsync", "-avP", "--size-only", source, destination], check=False
        )


class RomSizeDisplay:
    """Utility for displaying ROM directory sizes."""

    @staticmethod
    def display(systems: list[System], source_config: SourceConfig) -> None:
        """Display sizes of source ROM directories."""
        sorted_systems = sorted(systems, key=lambda s: s.value)
        rom_directories: list[str] = []

        for system in sorted_systems:
            source_subdir = source_config.roms_subdirs.get(system)
            if not source_subdir:
                continue
            path = PurePosixPath(source_config.source_roms_dir) / source_subdir
            rom_directories.append(f"'{path}/'")


        if not rom_directories:
            return

        directories_str = " ".join(rom_directories)
        command = f"du --total --summarize --human-readable {directories_str}"

        subprocess.run(
            ["ssh", source_config.remote_hostname, command],
            check=False,
        )


class FrontendFactory:
    """Factory for creating frontend instances."""

    _FRONTENDS: dict[str, type[Frontend]] = {
        "batocera": Batocera,
        "knulli": Knulli,
        "emudeck": EmuDeck,
        "esde": EsDe,
        "minui": MinUI,
        "muos": MuOS,
        "rocknix": Rocknix,
        "onion": Onion,
        "spruce": Spruce,
    }

    @classmethod
    def create(cls, name: str, destination_dir: str) -> Frontend | None:
        """Create a frontend instance by name."""
        frontend_class = cls._FRONTENDS.get(name.lower())
        if not frontend_class:
            return None
        return frontend_class(destination_dir)

    @classmethod
    def available_frontends(cls) -> list[str]:
        """Return list of available frontend names."""
        return list(cls._FRONTENDS.keys())


class LevelConfig:
    """ROM pack level configuration."""

    _LEVEL_1_SYSTEMS: list[System] = [
        System.ARCADE_FINALBURNNEO,
        System.PICO_8,
        System.NEC_TURBOGRAFX_16,
        System.NEC_TURBOGRAFX_CD,
        System.NINTENDO_GAME_BOY,
        System.NINTENDO_GAME_BOY_ADVANCE,
        System.NINTENDO_GAME_BOY_COLOR,
        System.NINTENDO_NES,
        System.NINTENDO_SNES,
        System.SEGA_32X,
        System.SEGA_CD,
        System.SEGA_GAME_GEAR,
        System.SEGA_GENESIS,
        System.SNK_NEO_GEO_POCKET_COLOR,
    ]

    _LEVEL_2_SYSTEMS: list[System] = _LEVEL_1_SYSTEMS + [
        System.SONY_PLAYSTATION,
    ]

    _LEVEL_3_SYSTEMS: list[System] = _LEVEL_2_SYSTEMS + [
        System.NINTENDO_64,
        System.SEGA_DREAMCAST,
        System.SEGA_SATURN,
        System.SNK_NEO_GEO_CD,
    ]

    _LEVEL_4_SYSTEMS: list[System] = _LEVEL_3_SYSTEMS + [
        System.NINTENDO_GAMECUBE,
        System.SONY_PLAYSTATION_2,
    ]

    _LEVEL_5_SYSTEMS: list[System] = _LEVEL_4_SYSTEMS + [
        System.NINTENDO_SWITCH,
        System.NINTENDO_WIIU,
        System.SONY_PLAYSTATION_3,
    ]

    _LEVELS: dict[str, list[System]] = {
        "1": _LEVEL_1_SYSTEMS,
        "2": _LEVEL_2_SYSTEMS,
        "3": _LEVEL_3_SYSTEMS,
        "4": _LEVEL_4_SYSTEMS,
        "5": _LEVEL_5_SYSTEMS,
    }

    @classmethod
    def systems_for_level(cls, level: str) -> list[System] | None:
        """Get systems for a given level."""
        normalized = level.lower().replace("level-", "").replace("level_", "")
        return cls._LEVELS.get(normalized)

    @classmethod
    def is_valid_level(cls, level: str) -> bool:
        """Check if a level is valid."""
        normalized = level.lower().replace("level-", "").replace("level_", "")
        return normalized in cls._LEVELS


def main() -> int:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Copy BIOS and ROM files to emulation frontends."
    )
    parser.add_argument(
        "destination",
        type=str,
        help=f"Destination OS/application ({', '.join(FrontendFactory.available_frontends())}, sizes)",
    )
    parser.add_argument(
        "destination_dir",
        type=str,
        nargs="?",
        default="",
        help="Destination root directory (required for all destinations except sizes)",
    )
    parser.add_argument(
        "level",
        type=str,
        nargs="?",
        default="",
        help="ROM pack level (1-5 or level-1 through level-5)",
    )

    args = parser.parse_args()
    destination_type = args.destination.lower()

    remote_destination = ":" in (args.destination_dir or "")
    yaml_path = Path(__file__).parent / "source_config.yaml"
    source_config = SourceConfig.from_yaml(yaml_path, remote_source=not remote_destination)

    # For sizes, destination_dir is unused; treat it as the level if provided.
    if destination_type in ("sizes", "rom-sizes", "rom_sizes"):
        level = args.destination_dir or args.level
        systems: list[System] = []
        if level:
            if not LevelConfig.is_valid_level(level):
                print(f"{level} is not a supported ROM pack name.")
                return 1
            systems = LevelConfig.systems_for_level(level) or []
        RomSizeDisplay.display(systems, source_config)
        return 0

    if not args.destination_dir:
        print("destination_dir is required.")
        parser.print_usage()
        return 1

    level = args.level
    systems: list[System] = []
    if level:
        if not LevelConfig.is_valid_level(level):
            print(f"{level} is not a supported ROM pack name.")
            return 1
        systems = LevelConfig.systems_for_level(level) or []

    frontend = FrontendFactory.create(destination_type, args.destination_dir)
    if not frontend:
        print(f"{args.destination} is not a supported destination OS/application.")
        print(f"Available: {', '.join(FrontendFactory.available_frontends())}")
        return 1

    copier = FileCopier(frontend, source_config)
    copier.copy_bios_files(systems)
    copier.copy_rom_files(systems)

    return 0


if __name__ == "__main__":
    sys.exit(main())
