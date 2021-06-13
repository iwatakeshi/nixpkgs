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
, tensorflow-lite
, withBenchmarks ? false
  # dmabuf only builds some integration tests using gstreamer + dmabuf
  # sadly, they depend on files that exist only on the coral devboard
  # they can certainly be built, but will fail when executed
, withDmabufTests ? false
, withExamples ? false
, withTests ? true
}:

let
  libcoral-abseil-cpp = abseil-cpp.overrideAttrs (old: {
    cmakeFlags = [ "-DCMAKE_CXX_STANDARD=11" ];
  });

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
  mesonOption = name: enabled: "-D${name}=${if enabled then "enabled" else "disabled"}";
in
stdenv.mkDerivation {
  pname = "libcoral";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "cpcloud";
    repo = "libcoral";
    rev = "720b9d45c359ea5a4f3cf9e2036e38f9ce08c987";
    sha256 = "1xlk4pfbcsy24nz1fx8w42kv88cp77i22hyp8nwjn1agvi2ixz95";
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
    libcoral-abseil-cpp
    libcoral-eigen
    flatbuffers
    glog
    libedgetpu
    tensorflow-lite
  ] ++ lib.optionals (withTests || withDmabufTests || withBenchmarks) [
    gbenchmark
  ] ++ lib.optionals (withTests || withDmabufTests) [
    gmock
    gtest
  ] ++ lib.optionals withDmabufTests (with gst_all_1; [
    gst-plugins-base
    gstreamer
  ]);

  mesonFlags = [
    "--buildtype=release"
    (mesonOption "tests" withTests)
    (mesonOption "dmabuf_tests" withDmabufTests)
    (mesonOption "examples" withExamples)
    (mesonOption "benchmarks" withBenchmarks)
    "-Db_lto=true"
  ];

  doCheck = withTests;

  # We can only run the 'cpu' test suite here. All other
  # test suites require access to 1 or more edge TPUs.
  checkPhase = lib.optional withTests ''
    meson test --suite=cpu
  '';

  meta = with lib; {
    description = "Library for driving Google Coral Edge TPU devices";
    homepage = "https://coral.ai/";
    license = licenses.asl20;
    maintainers = with maintainers; [ cpcloud ];
    platforms = tensorflow-lite.meta.platforms;
  };
}
