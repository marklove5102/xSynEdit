#!/usr/bin/env python3
"""
xSynEdit 2025.03 Manager for RAD Studio
========================================
Installs and uninstalls SynEdit packages for Win32, Win64, and Win64x.
Registers design-time packages in both 32-bit and 64-bit IDE.

Usage:
    python synedit_manager.py                                  # interactive install
    python synedit_manager.py --uninstall                      # interactive uninstall
    python synedit_manager.py --ide 37.0 --platforms Win32,Win64
    python synedit_manager.py --uninstall --ide 37.0 --yes
    python synedit_manager.py --dry-run --ide 37.0 --platforms Win32,Win64,Win64x
"""

import argparse
import os
import subprocess
import sys
import winreg
from datetime import datetime
from pathlib import Path

# =============================================================================
# Constants
# =============================================================================

SUPPORTED_IDES = {
    "24.0": "RAD Studio 11 Alexandria",
    "23.0": "RAD Studio 12 Athens",
    "37.0": "RAD Studio 13 Florence",
}

RUNTIME_PKG = "SynEditDR"
DESIGNTIME_PKG = "SynEditDD"
PKG_DESCRIPTION = "TurboPack SynEdit Delphi"

ALL_PLATFORMS = ["Win32", "Win64", "Win64x"]

SCRIPT_DIR = Path(__file__).resolve().parent
SOURCE_DIR = SCRIPT_DIR / "Source"
HIGHLIGHTERS_DIR = SCRIPT_DIR / "Source" / "Highlighters"
PACKAGES_DIR = SCRIPT_DIR / "Packages" / "11AndAbove" / "Delphi"
CPP_DIR = SCRIPT_DIR / "Packages" / "11AndAbove" / "cpp"
BACKUP_DIR = SCRIPT_DIR / "Backups"


# =============================================================================
# Color output
# =============================================================================


class Color:
    ENABLED = True

    @staticmethod
    def _wrap(code: str, text: str) -> str:
        if not Color.ENABLED:
            return text
        return f"\033[{code}m{text}\033[0m"

    @staticmethod
    def info(text: str) -> str:
        return Color._wrap("94", text)

    @staticmethod
    def success(text: str) -> str:
        return Color._wrap("92", text)

    @staticmethod
    def warn(text: str) -> str:
        return Color._wrap("93", text)

    @staticmethod
    def error(text: str) -> str:
        return Color._wrap("91", text)

    @staticmethod
    def cyan(text: str) -> str:
        return Color._wrap("96", text)

    @staticmethod
    def white(text: str) -> str:
        return Color._wrap("97", text)

    @staticmethod
    def header(text: str) -> str:
        line = "=" * 76
        return (
            f"\n{Color.cyan(line)}\n{Color.cyan(text.center(76))}\n{Color.cyan(line)}"
        )


# =============================================================================
# BDS Version info
# =============================================================================


class BDSVersion:
    def __init__(self, version: str, name: str, root_dir: str):
        self.version = version
        self.name = name
        self.root_dir = root_dir
        self.suffix = version.replace(".", "")[:3]  # "37.0" -> "370"
        self.rsvars_path = Path(root_dir) / "bin" / "rsvars.bat"

    def __str__(self) -> str:
        return f"{self.name} (BDS {self.version})"

    @property
    def public_docs(self) -> Path:
        return Path(f"C:/Users/Public/Documents/Embarcadero/Studio/{self.version}")


# =============================================================================
# Registry Manager
# =============================================================================


class RegistryManager:
    BDS_BASE = r"Software\Embarcadero\BDS"

    def _read_value(self, key_path: str, value_name: str) -> str | None:
        try:
            with winreg.OpenKey(winreg.HKEY_CURRENT_USER, key_path) as key:
                value, reg_type = winreg.QueryValueEx(key, value_name)
                return value
        except FileNotFoundError:
            return None
        except OSError:
            return None

    def _write_value(self, key_path: str, value_name: str, value: str):
        with winreg.CreateKey(winreg.HKEY_CURRENT_USER, key_path) as key:
            winreg.SetValueEx(key, value_name, 0, winreg.REG_SZ, value)

    def _delete_value(self, key_path: str, value_name: str) -> bool:
        try:
            with winreg.OpenKey(
                winreg.HKEY_CURRENT_USER, key_path, 0, winreg.KEY_SET_VALUE
            ) as key:
                winreg.DeleteValue(key, value_name)
                return True
        except FileNotFoundError:
            return False
        except OSError:
            return False

    def detect_ides(self) -> list[BDSVersion]:
        """Detect installed RAD Studio versions."""
        found = []
        for ver, name in SUPPORTED_IDES.items():
            root = self._read_value(f"{self.BDS_BASE}\\{ver}", "RootDir")
            if root:
                root = root.rstrip("\\")
                found.append(BDSVersion(ver, name, root))
        return found

    def backup(self, bds_ver: str, label: str) -> Path | None:
        """Export registry key to .reg file."""
        BACKUP_DIR.mkdir(exist_ok=True)
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        backup_file = BACKUP_DIR / f"BDS_{bds_ver}_{label}_{timestamp}.reg"
        key_path = f"HKCU\\Software\\Embarcadero\\BDS\\{bds_ver}"
        result = subprocess.run(
            ["reg", "export", key_path, str(backup_file), "/y"],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            return backup_file
        return None

    def register_package(self, bds_ver: str, bpl_path: str, ide_bitness: int):
        """Register a design-time package in Known Packages."""
        if ide_bitness == 32:
            key = f"{self.BDS_BASE}\\{bds_ver}\\Known Packages"
        else:
            key = f"{self.BDS_BASE}\\{bds_ver}\\Known Packages x64"
        self._write_value(key, bpl_path, f"{PKG_DESCRIPTION} designtime package")

    def unregister_package(self, bds_ver: str, bpl_path: str, ide_bitness: int) -> bool:
        """Unregister a design-time package from Known Packages."""
        if ide_bitness == 32:
            key = f"{self.BDS_BASE}\\{bds_ver}\\Known Packages"
        else:
            key = f"{self.BDS_BASE}\\{bds_ver}\\Known Packages x64"
        return self._delete_value(key, bpl_path)

    def add_path(
        self, bds_ver: str, section: str, platform: str, value_name: str, new_path: str
    ):
        """Add a path to a semicolon-separated registry value if not present."""
        key = f"{self.BDS_BASE}\\{bds_ver}\\{section}\\{platform}"
        current = self._read_value(key, value_name) or ""
        paths = [p for p in current.split(";") if p]
        if not any(p.lower() == new_path.lower() for p in paths):
            paths.append(new_path)
            self._write_value(key, value_name, ";".join(paths))
            return True
        return False

    def remove_path(
        self,
        bds_ver: str,
        section: str,
        platform: str,
        value_name: str,
        remove_path: str,
    ):
        """Remove a path from a semicolon-separated registry value."""
        key = f"{self.BDS_BASE}\\{bds_ver}\\{section}\\{platform}"
        current = self._read_value(key, value_name) or ""
        paths = [p for p in current.split(";") if p]
        filtered = [p for p in paths if p.lower() != remove_path.lower()]
        if len(filtered) != len(paths):
            self._write_value(key, value_name, ";".join(filtered))
            return True
        return False


# =============================================================================
# Package Compiler
# =============================================================================


class PackageCompiler:
    def __init__(self, rsvars_path: Path):
        self.env = self._load_rsvars(rsvars_path)

    def _load_rsvars(self, rsvars_path: Path) -> dict:
        """Execute rsvars.bat and capture the resulting environment."""
        result = subprocess.run(
            f'cmd /c "call "{rsvars_path}" && set"',
            capture_output=True,
            text=True,
            shell=True,
        )
        if result.returncode != 0:
            raise RuntimeError(f"Failed to load rsvars.bat: {result.stderr}")
        env = {}
        for line in result.stdout.splitlines():
            if "=" in line:
                k, v = line.split("=", 1)
                env[k] = v
        return env

    def compile(self, dproj: Path, platform: str, bpl_dir: Path, dcp_dir: Path) -> bool:
        """Compile a .dproj for the given platform."""
        result = subprocess.run(
            [
                "msbuild.exe",
                str(dproj),
                "/t:Build",
                "/p:Config=Release",
                f"/p:Platform={platform}",
                f"/p:DCC_BplOutput={bpl_dir}",
                f"/p:DCC_DcpOutput={dcp_dir}",
                "/v:minimal",
                "/nologo",
            ],
            env=self.env,
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            output = (result.stdout + "\n" + result.stderr).strip()
            print(Color.error(f"    FAILED!\n{output}"))
            return False
        return True


# =============================================================================
# File utilities
# =============================================================================


def is_file_locked(filepath: Path) -> bool:
    """Check if a file is locked by another process."""
    if not filepath.exists():
        return False
    try:
        with open(filepath, "r+b"):
            return False
    except (PermissionError, OSError):
        return True


def delete_file(filepath: Path) -> bool:
    """Delete a file, returning True if deleted or didn't exist."""
    if not filepath.exists():
        print(f"  {Color.warn('[--]')} Not found: {filepath.name}")
        return True
    try:
        filepath.unlink()
        print(f"  {Color.success('[OK]')} Deleted: {filepath.name}")
        return True
    except OSError as e:
        print(f"  {Color.warn('[WARN]')} Could not delete: {filepath.name} ({e})")
        return False


# =============================================================================
# Install
# =============================================================================


def install(
    bds: BDSVersion, platforms: list[str], reg: RegistryManager, dry_run: bool = False
):
    """Install SynEdit packages for the selected IDE and platforms."""

    compile_win32 = "Win32" in platforms
    compile_win64 = "Win64" in platforms
    compile_win64x = "Win64x" in platforms

    # --- Check rsvars.bat ---
    print(f"\n{Color.info('[1/8] Checking build environment...')}")
    if not bds.rsvars_path.exists():
        print(Color.error(f"  ERROR: rsvars.bat not found at {bds.rsvars_path}"))
        return False
    print(f"  {Color.success('[OK]')} rsvars.bat found")

    # --- Check .dproj files exist ---
    runtime_dproj = PACKAGES_DIR / f"{RUNTIME_PKG}.dproj"
    designtime_dproj = PACKAGES_DIR / f"{DESIGNTIME_PKG}.dproj"
    if not runtime_dproj.exists():
        print(Color.error(f"  ERROR: {runtime_dproj} not found!"))
        return False

    # --- Registry backup ---
    print(f"\n{Color.info('[2/8] Creating registry backup...')}")
    if dry_run:
        print(f"  {Color.warn('[DRY-RUN]')} Would backup registry")
    else:
        backup_file = reg.backup(bds.version, "BEFORE_install")
        if backup_file:
            print(f"  {Color.success('[OK]')} {backup_file}")
        else:
            print(f"  {Color.warn('[WARN]')} Could not create registry backup")

    # --- Setup output directories ---
    print(f"\n{Color.info('[3/8] Setting up directories...')}")
    public_docs = bds.public_docs
    dirs = {
        "Win32": (public_docs / "Bpl", public_docs / "Dcp"),
        "Win64": (public_docs / "Bpl" / "Win64", public_docs / "Dcp" / "Win64"),
        "Win64x": (public_docs / "Bpl" / "Win64x", public_docs / "Dcp" / "Win64x"),
    }
    for plat in platforms:
        bpl_dir, dcp_dir = dirs[plat]
        if not dry_run:
            bpl_dir.mkdir(parents=True, exist_ok=True)
            dcp_dir.mkdir(parents=True, exist_ok=True)
        print(f"  {plat}: BPL={bpl_dir}")

    # --- Check BPL lock ---
    print(f"\n{Color.info('[4/8] Checking for locked files...')}")
    locked = False
    for plat in platforms:
        bpl_dir = dirs[plat][0]
        for pkg in [RUNTIME_PKG, DESIGNTIME_PKG]:
            bpl_file = bpl_dir / f"{pkg}{bds.suffix}.bpl"
            if is_file_locked(bpl_file):
                print(Color.error(f"  LOCKED: {bpl_file}"))
                locked = True
    if locked:
        print(Color.error("  Close RAD Studio before installing!"))
        if not dry_run:
            return False
        print(f"  {Color.warn('[DRY-RUN]')} Continuing despite locked files...")
    else:
        print(f"  {Color.success('[OK]')} No locked files")

    # --- Compile ---
    print(f"\n{Color.info('[5/8] Compiling packages...')}")
    if dry_run:
        for plat in platforms:
            pkgs = [RUNTIME_PKG]
            if plat != "Win64x":
                pkgs.append(DESIGNTIME_PKG)
            for pkg in pkgs:
                print(f"  {Color.warn('[DRY-RUN]')} Would compile {pkg} ({plat})")
    else:
        compiler = PackageCompiler(bds.rsvars_path)
        for plat in platforms:
            bpl_dir, dcp_dir = dirs[plat]
            print(f"\n{Color.cyan(f'--- Compiling {plat} ---')}")

            # Runtime package
            print(f"  Building {RUNTIME_PKG} ({plat})...")
            if not compiler.compile(runtime_dproj, plat, bpl_dir, dcp_dir):
                return False
            print(f"  {Color.success('[OK]')} {RUNTIME_PKG}{bds.suffix}.bpl")

            # Design-time package (not for Win64x - no IDE exists for that platform)
            if plat != "Win64x":
                print(f"  Building {DESIGNTIME_PKG} ({plat})...")
                if not compiler.compile(designtime_dproj, plat, bpl_dir, dcp_dir):
                    return False
                print(f"  {Color.success('[OK]')} {DESIGNTIME_PKG}{bds.suffix}.bpl")
            else:
                print(f"  {Color.info('[INFO]')} Design-time not needed for Win64x")

    # --- Register in IDE ---
    print(f"\n{Color.info('[6/8] Registering packages in IDE...')}")
    if compile_win32:
        bpl_path = str(dirs["Win32"][0] / f"{DESIGNTIME_PKG}{bds.suffix}.bpl")
        if dry_run:
            print(
                f"  {Color.warn('[DRY-RUN]')} Would register in 32-bit IDE: {bpl_path}"
            )
        else:
            reg.register_package(bds.version, bpl_path, 32)
            print(f"  {Color.success('[OK]')} Known Packages (32-bit IDE)")

    if compile_win64:
        bpl_path = str(dirs["Win64"][0] / f"{DESIGNTIME_PKG}{bds.suffix}.bpl")
        if dry_run:
            print(
                f"  {Color.warn('[DRY-RUN]')} Would register in 64-bit IDE: {bpl_path}"
            )
        else:
            reg.register_package(bds.version, bpl_path, 64)
            print(f"  {Color.success('[OK]')} Known Packages x64 (64-bit IDE)")

    # --- Delphi Library Paths ---
    print(f"\n{Color.info('[7/8] Configuring Delphi Library Paths...')}")
    src = str(SOURCE_DIR)
    hl = str(HIGHLIGHTERS_DIR)
    for plat in platforms:
        for value_name in ["Search Path", "Browsing Path"]:
            for path in [src, hl]:
                if dry_run:
                    print(f"  {Color.warn('[DRY-RUN]')} {plat} {value_name}: {path}")
                else:
                    added = reg.add_path(bds.version, "Library", plat, value_name, path)
                    if added:
                        print(f"  {Color.success('[+]')} {plat} {value_name}: added")

    # --- C++ Paths ---
    print(f"\n{Color.info('[8/8] Configuring C++ Paths...')}")
    cpp_configs = []
    if compile_win32:
        for config in ["Debug", "Release"]:
            cpp_path = str(CPP_DIR / "Win32" / config)
            cpp_configs.append(("Win32", "IncludePath", cpp_path))
            cpp_configs.append(("Win32", "IncludePath_Clang32", cpp_path))
            cpp_configs.append(("Win32", "LibraryPath", cpp_path))
            cpp_configs.append(("Win32", "LibraryPath_Clang32", cpp_path))
    if compile_win64:
        for config in ["Debug", "Release"]:
            cpp_path = str(CPP_DIR / "Win64" / config)
            cpp_configs.append(("Win64", "IncludePath", cpp_path))
            cpp_configs.append(("Win64", "LibraryPath", cpp_path))
    if compile_win64x:
        for config in ["Debug", "Release"]:
            cpp_path = str(CPP_DIR / "Win64x" / config)
            cpp_configs.append(("Win64x", "IncludePath", cpp_path))
            cpp_configs.append(("Win64x", "LibraryPath", cpp_path))

    for plat, value_name, path in cpp_configs:
        if dry_run:
            print(f"  {Color.warn('[DRY-RUN]')} C++ {plat} {value_name}: {path}")
        else:
            reg.add_path(bds.version, "C++\\Paths", plat, value_name, path)

    if not dry_run:
        print(f"  {Color.success('[OK]')} C++ paths configured")

    # --- Summary ---
    print(Color.header("Installation completed successfully!"))
    print(f"\n{Color.white('Compiled packages:')}")
    for plat in platforms:
        bpl_dir = dirs[plat][0]
        print(f"  {plat}:  {bpl_dir / (RUNTIME_PKG + bds.suffix + '.bpl')}")
        if plat != "Win64x":
            print(f"          {bpl_dir / (DESIGNTIME_PKG + bds.suffix + '.bpl')}")

    print(f"\n{Color.white('IDE Registration:')}")
    if compile_win32:
        print(f"  32-bit IDE: {Color.success('Registered')}")
    if compile_win64:
        print(f"  64-bit IDE: {Color.success('Registered')}")

    print(f"\n{Color.warn('IMPORTANT: Restart RAD Studio to load components!')}")
    print("\nComponents will appear in Tool Palette:")
    print('  - "SynEdit" category')
    print('  - "SynEdit Highlighters" category')

    return True


# =============================================================================
# Uninstall
# =============================================================================


def uninstall(
    bds: BDSVersion,
    reg: RegistryManager,
    dry_run: bool = False,
    skip_paths_prompt: bool = False,
    auto_yes: bool = False,
):
    """Uninstall SynEdit packages from the selected IDE."""

    public_docs = bds.public_docs
    dirs = {
        "Win32": (public_docs / "Bpl", public_docs / "Dcp"),
        "Win64": (public_docs / "Bpl" / "Win64", public_docs / "Dcp" / "Win64"),
        "Win64x": (public_docs / "Bpl" / "Win64x", public_docs / "Dcp" / "Win64x"),
    }

    # --- Confirm ---
    if not auto_yes:
        print(
            Color.error(
                "\nWARNING: This will remove ALL SynEdit components from this IDE!"
            )
        )
        print("\n  This includes:")
        print("    - Win32 packages")
        print("    - Win64 packages")
        print("    - Win64x packages")
        print("    - All BPL, DCP files")
        print("    - IDE registrations (32-bit and 64-bit)")
        confirm = input("\nAre you sure you want to continue? (y/n): ").strip().lower()
        if confirm != "y":
            print("\nUninstallation cancelled.")
            return True

    # --- Registry backup ---
    print(f"\n{Color.info('[1/5] Creating registry backup...')}")
    if dry_run:
        print(f"  {Color.warn('[DRY-RUN]')} Would backup registry")
    else:
        backup_before = reg.backup(bds.version, "BEFORE_uninstall")
        if backup_before:
            print(f"  {Color.success('[OK]')} {backup_before}")
        else:
            print(f"  {Color.warn('[WARN]')} Could not create registry backup")

    # --- Unregister from IDE ---
    print(f"\n{Color.info('[2/5] Unregistering packages from IDE...')}")

    # 32-bit IDE
    bpl_32 = str(dirs["Win32"][0] / f"{DESIGNTIME_PKG}{bds.suffix}.bpl")
    print(f"\n{Color.cyan('--- Unregistering from 32-bit IDE ---')}")
    if dry_run:
        print(f"  {Color.warn('[DRY-RUN]')} Would unregister: {bpl_32}")
    else:
        if reg.unregister_package(bds.version, bpl_32, 32):
            print(f"  {Color.success('[OK]')} Removed from Known Packages")
        else:
            print(f"  {Color.warn('[--]')} Was not registered in 32-bit IDE")

    # 64-bit IDE
    bpl_64 = str(dirs["Win64"][0] / f"{DESIGNTIME_PKG}{bds.suffix}.bpl")
    print(f"\n{Color.cyan('--- Unregistering from 64-bit IDE ---')}")
    if dry_run:
        print(f"  {Color.warn('[DRY-RUN]')} Would unregister: {bpl_64}")
    else:
        if reg.unregister_package(bds.version, bpl_64, 64):
            print(f"  {Color.success('[OK]')} Removed from Known Packages x64")
        else:
            print(f"  {Color.warn('[--]')} Was not registered in 64-bit IDE")

    # --- Delete compiled files ---
    print(f"\n{Color.info('[3/5] Deleting compiled files...')}")

    for plat in ALL_PLATFORMS:
        bpl_dir, dcp_dir = dirs[plat]
        print(f"\n{Color.cyan(f'--- {plat} files ---')}")

        if dry_run:
            pkgs = [RUNTIME_PKG]
            if plat != "Win64x":
                pkgs.append(DESIGNTIME_PKG)
            for pkg in pkgs:
                for d, ext in [(bpl_dir, ".bpl"), (bpl_dir, ".rsm"), (dcp_dir, ".dcp")]:
                    f = (
                        d / f"{pkg}{bds.suffix}{ext}"
                        if ext != ".dcp"
                        else d / f"{pkg}{ext}"
                    )
                    if f.exists():
                        print(f"  {Color.warn('[DRY-RUN]')} Would delete: {f.name}")
        else:
            for pkg in [RUNTIME_PKG, DESIGNTIME_PKG]:
                delete_file(bpl_dir / f"{pkg}{bds.suffix}.bpl")
                delete_file(dcp_dir / f"{pkg}.dcp")
            # RSM files (Win64, Win64x only)
            if plat in ("Win64", "Win64x"):
                for pkg in [RUNTIME_PKG, DESIGNTIME_PKG]:
                    delete_file(bpl_dir / f"{pkg}{bds.suffix}.rsm")

    # Clean DCU files
    print(f"\n{Color.cyan('--- Cleaning DCU files ---')}")
    for plat in ALL_PLATFORMS:
        dcp_dir = dirs[plat][1]
        if dry_run:
            print(f"  {Color.warn('[DRY-RUN]')} Would clean {plat} DCU files")
        else:
            count = 0
            for dcu in dcp_dir.glob("Syn*.dcu"):
                dcu.unlink()
                count += 1
            if count > 0:
                print(f"  {Color.success('[OK]')} Cleaned {count} {plat} DCU files")
            else:
                print(f"  {Color.warn('[--]')} No {plat} DCU files")

    # --- Remove Library Paths ---
    print(f"\n{Color.info('[4/5] Removing Library Paths...')}")
    remove_paths = auto_yes
    if not auto_yes and not dry_run:
        answer = (
            input("  Remove SynEdit paths from Library configuration? (y/n): ")
            .strip()
            .lower()
        )
        remove_paths = answer == "y"

    if remove_paths or dry_run:
        src = str(SOURCE_DIR)
        hl = str(HIGHLIGHTERS_DIR)

        # Delphi paths
        for plat in ALL_PLATFORMS:
            for value_name in ["Search Path", "Browsing Path"]:
                for path in [src, hl]:
                    if dry_run:
                        print(
                            f"  {Color.warn('[DRY-RUN]')} {plat} {value_name}: would remove"
                        )
                    else:
                        reg.remove_path(bds.version, "Library", plat, value_name, path)
            if not dry_run:
                print(f"  {Color.success('[OK]')} {plat} Delphi paths: cleaned")

        # C++ paths
        print("\n  Removing C++ paths...")
        cpp_configs = []
        # Win32
        for config in ["Debug", "Release"]:
            cpp_path = str(CPP_DIR / "Win32" / config)
            cpp_configs.append(("Win32", "IncludePath", cpp_path))
            cpp_configs.append(("Win32", "IncludePath_Clang32", cpp_path))
            cpp_configs.append(("Win32", "LibraryPath", cpp_path))
            cpp_configs.append(("Win32", "LibraryPath_Clang32", cpp_path))
        # Win64
        for config in ["Debug", "Release"]:
            cpp_path = str(CPP_DIR / "Win64" / config)
            cpp_configs.append(("Win64", "IncludePath", cpp_path))
            cpp_configs.append(("Win64", "LibraryPath", cpp_path))
        # Win64x
        for config in ["Debug", "Release"]:
            cpp_path = str(CPP_DIR / "Win64x" / config)
            cpp_configs.append(("Win64x", "IncludePath", cpp_path))
            cpp_configs.append(("Win64x", "LibraryPath", cpp_path))

        for plat, value_name, path in cpp_configs:
            if dry_run:
                pass  # already printed above
            else:
                reg.remove_path(bds.version, "C++\\Paths", plat, value_name, path)

        if not dry_run:
            print(f"  {Color.success('[OK]')} C++ paths cleaned")

    # --- Post-uninstall backup ---
    print(f"\n{Color.info('[5/5] Creating post-uninstall registry backup...')}")
    if dry_run:
        print(f"  {Color.warn('[DRY-RUN]')} Would backup registry")
    else:
        backup_after = reg.backup(bds.version, "AFTER_uninstall")
        if backup_after:
            print(f"  {Color.success('[OK]')} {backup_after}")

    # --- Summary ---
    print(Color.header("Uninstallation completed successfully!"))
    print(f"\n{Color.white('Removed:')}")
    print("  - Win32 packages (BPL, DCP)")
    print("  - Win64 packages (BPL, DCP)")
    print("  - Win64x packages (BPL, DCP)")
    print("  - IDE registrations (32-bit and 64-bit)")

    if not dry_run:
        print(f"\n{Color.white('Registry backups:')}")
        if backup_before:
            print(f"  Before: {backup_before}")
        if backup_after:
            print(f"  After:  {backup_after}")

    print(
        f"\n{Color.warn('IMPORTANT: Restart RAD Studio for changes to take effect!')}"
    )

    return True


# =============================================================================
# Interactive prompts
# =============================================================================


def select_ide(ides: list[BDSVersion]) -> BDSVersion | None:
    """Let the user select an IDE interactively."""
    print(f"\n{Color.info('Select RAD Studio version:')}\n")
    for i, ide in enumerate(ides, 1):
        print(f"  {i}. {ide.name}")
    print()
    choice = input(f"Enter number (1-{len(ides)}) or 'q' to quit: ").strip()
    if choice.lower() == "q":
        return None
    try:
        idx = int(choice) - 1
        if 0 <= idx < len(ides):
            return ides[idx]
    except ValueError:
        pass
    print(Color.error("Invalid selection!"))
    return None


def select_platforms() -> list[str] | None:
    """Let the user select platforms interactively."""
    print(f"\n{Color.info('Select target platforms:')}\n")
    print("  1. Win32 only")
    print("  2. Win64 only")
    print("  3. Win32 + Win64 (recommended)")
    print("  4. Win32 + Win64 + Win64x (ALL)")
    print()
    choice = input("Enter number (1-4): ").strip()
    options = {
        "1": ["Win32"],
        "2": ["Win64"],
        "3": ["Win32", "Win64"],
        "4": ["Win32", "Win64", "Win64x"],
    }
    return options.get(choice)


# =============================================================================
# Main
# =============================================================================


def main():
    parser = argparse.ArgumentParser(
        description="xSynEdit 2025.03 Manager for RAD Studio"
    )
    parser.add_argument(
        "--uninstall", action="store_true", help="Uninstall instead of install"
    )
    parser.add_argument(
        "--ide", type=str, metavar="VER", help="BDS version (e.g. 37.0, 23.0, 24.0)"
    )
    parser.add_argument(
        "--platforms", type=str, help="Comma-separated platforms (Win32,Win64,Win64x)"
    )
    parser.add_argument(
        "--yes", "-y", action="store_true", help="Skip confirmation prompts"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without making changes",
    )
    parser.add_argument(
        "--no-color", action="store_true", help="Disable colored output"
    )
    args = parser.parse_args()

    if args.no_color:
        Color.ENABLED = False

    # Enable ANSI on Windows
    if sys.platform == "win32" and Color.ENABLED:
        os.system("")  # enables ANSI escape code processing

    mode = "Uninstaller" if args.uninstall else "Installer"
    print(Color.header(f"xSynEdit 2025.03 {mode} for RAD Studio"))

    if args.dry_run:
        print(f"\n{Color.warn('*** DRY-RUN MODE — no changes will be made ***')}")

    reg = RegistryManager()

    # --- Detect IDEs ---
    print(f"\n{Color.info('Detecting installed RAD Studio versions...')}\n")
    ides = reg.detect_ides()

    if not ides:
        print(Color.error("ERROR: No supported RAD Studio installation found!"))
        return 1

    for ide in ides:
        print(f"  {Color.success('[OK]')} {ide.name}")

    # --- Select IDE ---
    target = None
    if args.ide:
        for ide in ides:
            if ide.version == args.ide:
                target = ide
                break
        if not target:
            print(Color.error(f"\nERROR: BDS {args.ide} not found!"))
            print(f"Available: {', '.join(ide.version for ide in ides)}")
            return 1
    else:
        target = select_ide(ides)
        if not target:
            print("\nCancelled.")
            return 0

    print(f"\n{Color.success(f'Selected: {target}')}")
    print(f"  Root: {target.root_dir}")

    # --- Uninstall ---
    if args.uninstall:
        ok = uninstall(target, reg, dry_run=args.dry_run, auto_yes=args.yes)
        return 0 if ok else 1

    # --- Select platforms ---
    if args.platforms:
        platforms = [p.strip() for p in args.platforms.split(",")]
        for p in platforms:
            if p not in ALL_PLATFORMS:
                print(Color.error(f"\nERROR: Unknown platform '{p}'"))
                print(f"Supported: {', '.join(ALL_PLATFORMS)}")
                return 1
    else:
        platforms = select_platforms()
        if not platforms:
            print(Color.error("Invalid selection!"))
            return 1

    print(f"\nSelected platforms: {', '.join(platforms)}")

    # --- Install ---
    ok = install(target, platforms, reg, dry_run=args.dry_run)
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
