{ abseil-cpp
, cmake
, fetchFromGitHub
, flatbuffers
, lib
, libusb
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
}:
let
  linkerEnv = if lto then stdenvAdapters.useGoldLinker else lib.id;
in
(linkerEnv stdenv).mkDerivation rec {
  pname = "libedgetpu";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "cpcloud";
    repo = "libedgetpu";
    rev = "a1678e68373766d0eff643fd01c4b4b39010d567";
    sha256 = "0zxpfzhb7amn4f2z7ar1whk6nshq7llwwix8s0h8fyz0jbyhc9x6";
  };

  nativeBuildInputs = [
    meson
    cmake  # used to detect dependencies
    ninja
    pkg-config
    xxd
  ];

  buildInputs = [
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
