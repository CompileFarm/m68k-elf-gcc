#!/bin/bash

###################################################################
#Script Name	:   build-binutils                                                                                            
#Description	:   build binutils for the Motorola 68000 toolchain   
#Date           :   samedi, 4 avril 2020                                                                          
#Args           :   Welcome to the next level!                                                                                        
#Author       	:   Jacques Belosoukinski (kentosama)                                                   
#Email         	:   kentosama@genku.net                                          
###################################################################

VERSION="2.40"
ARCHIVE="binutils-${VERSION}.tar.bz2"
URL="https://ftp.gnu.org/gnu/binutils/${ARCHIVE}"
SHA512SUM="30256362945184329c994730f60d8493292547e0e5de5f49d57490d8d9b1a0a18393bf7f70934ba5061ee2001ec4cbf5f206d310df9512a7fb3625a362e358f9"
DIR="binutils-${VERSION}"

# Check if user is root
if [ ${EUID} == 0 ]; then
    echo "Please don't run this script as root"
    exit 1
fi

# Create build folder
mkdir -p ${BUILD_DIR}/${DIR}

cd ${DOWNLOAD_DIR}

# Download binutils if is needed
if ! [ -f "${ARCHIVE}" ]; then
    wget ${URL}
fi

# Extract binutils archive if is needed
if ! [ -d "${SRC_DIR}/${DIR}" ]; then
#    if [ $(sha512sum ${ARCHIVE} | awk '{print $1}') != ${SHA512SUM} ]; then
#        echo "SHA512SUM verification of ${ARCHIVE} failed!"
#        exit
#    else
        tar jxvf ${ARCHIVE} -C ${SRC_DIR}
#    fi
fi

cd ${BUILD_DIR}/${DIR}

# Enable gold for 64bit
if [ ${ARCH} != "i386" ] && [ ${ARCH} != "i686" ]; then
    GOLD="--enable-gold=yes"
fi

# Configure before build
../../source/${DIR}/configure       --prefix=${INSTALL_DIR} \
                                    --build=${BUILD_MACH} \
                                    --host=${HOST_MACH} \
                                    --target=${TARGET} \
                                    --disable-werror \
                                    --disable-nls \
                                    --disable-threads \
                                    --disable-multilib \
                                    --enable-libssp \
                                    --enable-lto \
                                    --enable-languages=c
                                    --program-prefix=${PROGRAM_PREFIX} \
                                    ${GOD}


# build and install binutils
make -j${NUM_PROC} 2<&1 | tee build.log

# Install binutils
if [ $? -eq 0 ]; then
    make install -j${NUM_PROC}
fi
