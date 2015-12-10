#!/bin/bash
#
# this should be run from the src directory, the layout is supposed to
# look like this:
#.../src/subsurface
#       /libgit2
#       /marble-source
#       /libdivecomputer
#
# the script will build these three libraries from source, even if
# they are installed as part of the host OS since we have seen
# numerous cases where building with random versions (especially older,
# but sometimes also newer versions than recommended here) will lead
# to all kinds of unnecessary pain
#
# it installs the libraries and subsurface in the install-root subdirectory
# of the current directory (except on Mac where the Subsurface.app ends up
# in subsurface/deskbuild

#testcomment

# create a log file of the build
exec 1> >(tee deskbuild.log) 2>&1


check_return_val()
{
    if [ "$1" -ne 0 ]
    then
        exit $1
    fi
}

SRC=$(pwd)
PLATFORM=$(uname)

if [[ ! -d "subsurface" ]] ; then
	echo "please start this script from the directory containing the Subsurface source directory"
	exit 1
fi



mkdir -p install-root
INSTALL_ROOT=$SRC/install-root

rm subsurface/deskbuild/desktop-widgets/libsubsurface_generated_ui.a
rm subsurface/deskbuild/desktop-widgets/libsubsurface_interface.a
rm subsurface/deskbuild/desktop-widgets/libsubsurface_statistics.a
rm subsurface/deskbuild/desktop-widgets/plugins/facebook/libfacebook_integration.a
rm subsurface/deskbuild/desktop-widgets/preferences/libsubsurface_desktop_preferences.a
rm subsurface/deskbuild/profile-widget/libsubsurface_profile.a
rm subsurface/deskbuild/qt-models/libsubsurface_models.a
rm subsurface/deskbuild/subsurface-core/libsubsurface_corelib.a

rm subsurface/deskbuild/subsurface
rm install-root/bin/subsurface

# make sure we find our own packages first (e.g., libgit2 only uses pkg_config to find libssh2)
export PKG_CONFIG_PATH=$INSTALL_ROOT/lib/pkgconfig:$PKG_CONFIG_PATH

echo Building in $SRC, installing in $INSTALL_ROOT


# finally, build Subsurface

if [ $PLATFORM = Darwin ] ; then
	SH_LIB_EXT=dylib
else
	SH_LIB_EXT=so
fi

cd $SRC/subsurface
mkdir -p deskbuild

cd deskbuild

#export CMAKE_PREFIX_PATH=$INSTALL_ROOT/lib/cmake

# definitely added -DCMAKE_VERBOSE_MAKEFILE=ON intentionally. want to see all build commands.

# not sure at what point -DCMAKE_INSTALL_PREFIX=$INSTALL_ROOT (with a .. trailing) got in here. what is that?

cmake   -DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_BUILD_TYPE=Debug \
	-DCMAKE_INSTALL_PREFIX=$INSTALL_ROOT .. \
	-DLIBGIT2_INCLUDE_DIR=$INSTALL_ROOT/include \
	-DLIBGIT2_LIBRARIES=$INSTALL_ROOT/lib/libgit2.$SH_LIB_EXT \
	-DLIBDIVECOMPUTER_INCLUDE_DIR=$INSTALL_ROOT/include \
	-DLIBDIVECOMPUTER_LIBRARIES=$INSTALL_ROOT/lib/libdivecomputer.a \
	-DMARBLE_INCLUDE_DIR=$INSTALL_ROOT/include \
	-DMARBLE_LIBRARIES=$INSTALL_ROOT/lib/libssrfmarblewidget.$SH_LIB_EXT \
	-DNO_PRINTING=OFF \
	-DUSE_LIBGIT23_API=1


check_return_val $?

if [ $PLATFORM = Darwin ] ; then
	rm -rf Subsurface.app
fi

LIBRARY_PATH=$INSTALL_ROOT/lib make -j4

check_return_val $?

LIBRARY_PATH=$INSTALL_ROOT/lib make install

check_return_val $?
