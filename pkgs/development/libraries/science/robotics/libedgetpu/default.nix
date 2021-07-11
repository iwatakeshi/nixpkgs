{ abseil-cpp
, cmake
, fetchFromGitHub
, flatbuffers
, lib
, libusb
, llvmPackages_12
, meson
, ninja
, pkg-config
, stdenv
, stdenvAdapters
, tensorflow-lite
, xxd
, buildType ? "release"
, withPci ? true
, withUsb ? true
, lto ? false
, wrapBintoolsWith
}:
llvmPackages_12.stdenv.mkDerivation rec {
  pname = "libedgetpu";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "cpcloud";
    repo = "libedgetpu";
    rev = "f922dfb5c963d3f7d23dfe512417694113122f08";
    sha256 = "0fw7lbahjlzpx1v7nj30hkci3x0y7z7qhaj9y7428vgdiqjgml4w";
  };

  nativeBuildInputs = [
    meson
    cmake  # used to detect dependencies
    ninja
    pkg-config
    xxd
  ];

  buildInputs = [
    (wrapBintoolsWith {
      inherit (llvmPackages_12) bintools;
    })
    abseil-cpp
    flatbuffers
    libusb
    tensorflow-lite
  ];

  mesonFlags = [
    "--buildtype=${buildType}"
    "-Dpci=${if withPci then "enabled" else "disabled"}"
    "-Dusb=${if withUsb then "enabled" else "disabled"}"
    "-Dcpp_std=c++17"
    "-Db_lto=${lib.boolToString lto}"
  ];

  postInstall = ''
    ln -s $out/lib/libedgetpu.so{,.1}
    ln -s $out/lib/libedgetpu.so.1{,.0}
    ln -s $out/lib/libedgetpu.so.1.0{,.0}
  '';

  meta = with lib; {
    description = "Library for driving Google Coral Edge TPU devices";
    homepage = "https://coral.ai/";
    license = licenses.asl20;
    maintainers = with maintainers; [ cpcloud ];
    platforms = tensorflow-lite.meta.platforms;
  };
}
