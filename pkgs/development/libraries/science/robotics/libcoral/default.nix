{ abseil-cpp
, cmake
, eigen
, fd
, fetchFromGitLab
, fetchFromGitHub
, flatbuffers
, gbenchmark
, glog
, gmock
, gst_all_1
, gtest
, lib
, libedgetpu
, meson
, ninja
, pkg-config
, stdenv
, stdenvAdapters
, tensorflow-lite
, withBenchmarks ? false
, withExamples ? false
, withTests ? [ "cpu" ]
, lto ? false
}:

let
  # libcoral requires a special version of eigen
  libcoral-eigen = eigen.overrideAttrs (old: {
    patches = [ ./libcoral-eigen-include-dir.patch ];
    src = fetchFromGitLab {
      owner = "libeigen";
      repo = "eigen";
      rev = "3d9051ea84a5089b277c88dac456b3b1576bfa7f";
      sha256 = "1y3f2jvimb5i904f4n37h23cv2pkdlbz8656s0kga1y7c0p50wif";
    };
  });
  withAnyTests = (lib.length withTests) != 0;
  linkerEnv = if lto then stdenvAdapters.useGoldLinker else lib.id;
in
(linkerEnv stdenv).mkDerivation {
  pname = "libcoral";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "cpcloud";
    repo = "libcoral";
    rev = "98da0a8bff80cbfcc971bd7a20e8e88723b71ba8";
    sha256 = "1grrcvlc98xmm10r5gyiwk4l12lp2si53va5bcw8fzbx34b1x1jx";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    meson
    cmake # used to detect dependencies
    pkg-config
    ninja
    fd
  ];

  buildInputs = [
    abseil-cpp
    flatbuffers
    glog
    libcoral-eigen
    libedgetpu
    tensorflow-lite
  ] ++ lib.optionals (withAnyTests || withBenchmarks) [
    gbenchmark
  ] ++ lib.optionals withAnyTests [
    gmock
    gtest
  ] ++ lib.optionals (lib.elem "dmabuf" withTests) [
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
  ];

  mesonFlags = [
    "--buildtype=release"
    "-Dtests=${lib.concatStringsSep "," withTests}"
    "-Dexamples=${if withExamples then "enabled" else "disabled"}"
    "-Dbenchmarks=${if withBenchmarks then "enabled" else "disabled"}"
    "-Dcpp_std=c++17"
    "-Db_lto=${lib.boolToString lto}"
  ];

  doCheck = withAnyTests;

  checkPhase = lib.optional withAnyTests ''
    meson test
  '';

  meta = with lib; {
    description = "Library for driving Google Coral Edge TPU devices";
    homepage = "https://coral.ai/";
    license = licenses.asl20;
    maintainers = with maintainers; [ cpcloud ];
    platforms = libedgetpu.meta.platforms;
  };
}
