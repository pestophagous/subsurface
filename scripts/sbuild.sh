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
# in subsurface/build

#testcomment

# create a log file of the build
exec 1> >(tee build.log) 2>&1

SRC=$(pwd)
PLATFORM=$(uname)

if [[ ! -d "subsurface" ]] ; then
	echo "please start this script from the directory containing the Subsurface source directory"
	exit 1
fi


mkdir -p install-root
INSTALL_ROOT=$SRC/install-root

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
mkdir -p build

cd build

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


if [ $PLATFORM = Darwin ] ; then
	rm -rf Subsurface.app
fi

LIBRARY_PATH=$INSTALL_ROOT/lib make -j4
LIBRARY_PATH=$INSTALL_ROOT/lib make install


# the '-B' is probably a bad idea. :) it forces every build command to run, regardless of 'no changes since last build'
# LIBRARY_PATH=$INSTALL_ROOT/lib make -B TestDiveSiteDuplication \
# 	    TestGitStorage \
# 	    TestGpsCoords \
# 	    TestParse \
# 	    TestPlan \
# 	    TestProfile \
# 	    TestRenumber \
# 	    TestUnitConversion


#   "CMakeFiles/TestDiveSiteDuplication_automoc.dir/AutogenInfo.cmake"
#   "CMakeFiles/TestGitStorage_automoc.dir/AutogenInfo.cmake"
#   "CMakeFiles/TestGpsCoords_automoc.dir/AutogenInfo.cmake"
#   "CMakeFiles/TestParse_automoc.dir/AutogenInfo.cmake"
#   "CMakeFiles/TestPlan_automoc.dir/AutogenInfo.cmake"
#   "CMakeFiles/TestProfile_automoc.dir/AutogenInfo.cmake"
#   "CMakeFiles/TestRenumber_automoc.dir/AutogenInfo.cmake"
#   "CMakeFiles/TestUnitConversion_automoc.dir/AutogenInfo.cmake"
#   "CMakeFiles/TestDiveSiteDuplication.dir/DependInfo.cmake"
#   "CMakeFiles/TestDiveSiteDuplication_automoc.dir/DependInfo.cmake"
#   "CMakeFiles/TestGitStorage.dir/DependInfo.cmake"
#   "CMakeFiles/TestGitStorage_automoc.dir/DependInfo.cmake"
#   "CMakeFiles/TestGpsCoords.dir/DependInfo.cmake"
#   "CMakeFiles/TestGpsCoords_automoc.dir/DependInfo.cmake"
#   "CMakeFiles/TestParse.dir/DependInfo.cmake"
#   "CMakeFiles/TestParse_automoc.dir/DependInfo.cmake"
#   "CMakeFiles/TestPlan.dir/DependInfo.cmake"
#   "CMakeFiles/TestPlan_automoc.dir/DependInfo.cmake"
#   "CMakeFiles/TestProfile.dir/DependInfo.cmake"
#   "CMakeFiles/TestProfile_automoc.dir/DependInfo.cmake"
#   "CMakeFiles/TestRenumber.dir/DependInfo.cmake"
#   "CMakeFiles/TestRenumber_automoc.dir/DependInfo.cmake"
#   "CMakeFiles/TestUnitConversion.dir/DependInfo.cmake"
#   "CMakeFiles/TestUnitConversion_automoc.dir/DependInfo.cmake"

#   TestDiveSiteDuplication: CMakeFiles/TestDiveSiteDuplication.dir/rule
# TestDiveSiteDuplication_automoc: CMakeFiles/TestDiveSiteDuplication_automoc.dir/rule
# TestGitStorage: CMakeFiles/TestGitStorage.dir/rule
# TestGitStorage_automoc: CMakeFiles/TestGitStorage_automoc.dir/rule
# TestGpsCoords: CMakeFiles/TestGpsCoords.dir/rule
# TestGpsCoords_automoc: CMakeFiles/TestGpsCoords_automoc.dir/rule
# TestParse: CMakeFiles/TestParse.dir/rule
# TestParse_automoc: CMakeFiles/TestParse_automoc.dir/rule
# TestPlan: CMakeFiles/TestPlan.dir/rule
# TestPlan_automoc: CMakeFiles/TestPlan_automoc.dir/rule
# TestProfile: CMakeFiles/TestProfile.dir/rule
# TestProfile_automoc: CMakeFiles/TestProfile_automoc.dir/rule
# TestRenumber: CMakeFiles/TestRenumber.dir/rule
# TestRenumber_automoc: CMakeFiles/TestRenumber_automoc.dir/rule
# TestUnitConversion: CMakeFiles/TestUnitConversion.dir/rule
# TestUnitConversion_automoc: CMakeFiles/TestUnitConversion_automoc.dir/rule

# 	$(MAKE) -f CMakeFiles/TestDiveSiteDuplication.dir/build.make CMakeFiles/TestDiveSiteDuplication.dir/qrc_subsurface.cpp.o
# 	$(MAKE) -f CMakeFiles/TestGitStorage.dir/build.make CMakeFiles/TestGitStorage.dir/qrc_subsurface.cpp.o
# 	$(MAKE) -f CMakeFiles/TestGpsCoords.dir/build.make CMakeFiles/TestGpsCoords.dir/qrc_subsurface.cpp.o
# 	$(MAKE) -f CMakeFiles/TestParse.dir/build.make CMakeFiles/TestParse.dir/qrc_subsurface.cpp.o
# 	$(MAKE) -f CMakeFiles/TestPlan.dir/build.make CMakeFiles/TestPlan.dir/qrc_subsurface.cpp.o
# 	$(MAKE) -f CMakeFiles/TestProfile.dir/build.make CMakeFiles/TestProfile.dir/qrc_subsurface.cpp.o
# 	$(MAKE) -f CMakeFiles/TestRenumber.dir/build.make CMakeFiles/TestRenumber.dir/qrc_subsurface.cpp.o
# 	$(MAKE) -f CMakeFiles/TestUnitConversion.dir/build.make CMakeFiles/TestUnitConversion.dir/qrc_subsurface.cpp.o
# 	$(MAKE) -f CMakeFiles/TestDiveSiteDuplication.dir/build.make CMakeFiles/TestDiveSiteDuplication.dir/tests/testdivesiteduplication.cpp.o
# 	$(MAKE) -f CMakeFiles/TestGitStorage.dir/build.make CMakeFiles/TestGitStorage.dir/tests/testgitstorage.cpp.o
# 	$(MAKE) -f CMakeFiles/TestGpsCoords.dir/build.make CMakeFiles/TestGpsCoords.dir/tests/testgpscoords.cpp.o
# 	$(MAKE) -f CMakeFiles/TestParse.dir/build.make CMakeFiles/TestParse.dir/tests/testparse.cpp.o
# 	$(MAKE) -f CMakeFiles/TestPlan.dir/build.make CMakeFiles/TestPlan.dir/tests/testplan.cpp.o
# 	$(MAKE) -f CMakeFiles/TestProfile.dir/build.make CMakeFiles/TestProfile.dir/tests/testprofile.cpp.o
# 	$(MAKE) -f CMakeFiles/TestRenumber.dir/build.make CMakeFiles/TestRenumber.dir/tests/testrenumber.cpp.o
# 	$(MAKE) -f CMakeFiles/TestUnitConversion.dir/build.make CMakeFiles/TestUnitConversion.dir/tests/testunitconversion.cpp.o
