#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#
#  Many, many thanks go to all people that provide the individual modules!!!
#

rp_module_id="gngeopi"
rp_module_desc="NeoGeo emulator GnGeoPi"
rp_module_menus="2+"
rp_module_flags=""

function depends_gngeopi() {
    getDepends libsdl1.2-dev
}

function sources_gngeopi() {
    gitPullOrClone "$md_build" https://github.com/ymartel06/GnGeo-Pi.git
}

function build_gngeopi() {
    cd gngeo
    chmod +x configure
    ./configure --disable-i386asm --prefix="$md_inst"
    make clean
    # not safe for building in parallel
    make -j1
    md_ret_require="$md_build/gngeo/src/gngeo"
}

function install_gngeopi() {
    cd gngeo
    make install
    mkdir -p "$md_inst/neogeobios"
}

function configure_gngeopi() {
    mkRomDir "neogeo"

    mkdir -p "$configdir/neogeo"

    # move old config to new location
    if [[ -d "$home/.gngeo" && ! -h "$home/.gngeo" ]]; then
        mv "$home/.gngeo/"* "$configdir/neogeo"
        rmdir "$home/.gngeo"
    fi
    
    if [[ ! -f "$configdir/gngeo/gngeorc" ]]; then
        # add default controls for keyboard p1/p2
        cat > "$home/.gngeo/gngeorc" <<\_EOF_
p1control A=K122,B=K120,C=K97,D=K115,START=K49,COIN=K51,UP=K273,DOWN=K274,LEFT=K276,RIGHT=K275,MENU=K27
p2control A=K108,B=K59,C=K111,D=K112,START=K50,COIN=K52,UP=K264,DOWN=K261,LEFT=K260,RIGHT=K262,MENU=K27
_EOF_
    fi
    
    # symlink to new config location
    ln -snf "$configdir/neogeo" "$home/.gngeo"

    chown -R $user:$user "$configdir/neogeo"

    delSystem "$md_id" "neogeo-gngeopi"
    addSystem 0 "$md_id" "neogeo" "$md_inst/bin/gngeo -i $romdir/neogeo -B $md_inst/neogeobios %ROM%"

    __INFMSGS+=("For emulator $md_id you need to copy the NeoGeo BIOS (neogeo.zip) files to the roms folder '$romdir/neogeo'.")
}
