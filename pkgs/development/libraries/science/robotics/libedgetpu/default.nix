{ abseil-cpp
, fetchFromGitHub
, flatbuffers
, lib
, libusb
, meson
, ninja
, pkg-config
, stdenv
, tensorflow-lite
, xxd
, withPci ? true
, withUsb ? true
}:
stdenv.mkDerivation rec {
  pname = "libedgetpu";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "cpcloud";
    repo = "libedgetpu";
    rev = "6f9abff0492bf03f20d3a3e366ed810fa102cade";
    sha256 = "04s061cm931655j93a43nz42y5jmswp8bxvdkp6f5p4pmxcbim98";
  };

  nativeBuildInputs = [
    meson
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
    "--buildtype=release"
    "-Dpci=${if withPci then "enabled" else "disabled"}"
    "-Dusb=${if withUsb then "enabled" else "disabled"}"
    "-Dcpp_std=c++17"
    "-Db_lto=true"
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
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
