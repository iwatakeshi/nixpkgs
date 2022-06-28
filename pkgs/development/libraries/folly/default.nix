{ lib
, stdenv
, fetchFromGitHub
, boost
, cmake
, double-conversion
, fetchpatch
, fmt_8
, gflags
, glog
, libaio
, libdwarf
, libevent
, libiberty
, libsodium
, libunwind
, liburing
, lz4
, ninja
, openssl
, pkg-config
, snappy
, xz
, zlib
, zstd
, follyMobile ? false
}:

stdenv.mkDerivation rec {
  pname = "folly";
  version = "2022.06.27.00";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "folly";
    rev = "v${version}";
    sha256 = "sha256-KUkHW9t94x7X3M1b4YFFS2MpVn/f2MnlbZyJnExFPvY=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  # See CMake/folly-deps.cmake in the Folly source tree.
  buildInputs = [
    boost
    double-conversion
    glog
    gflags
    libaio
    libdwarf
    liburing
    libevent
    libsodium
    libiberty
    openssl
    snappy
    lz4
    xz
    zlib
    libunwind
    fmt_8
    zstd
  ];

  NIX_CFLAGS_COMPILE = [
    "-DFOLLY_MOBILE=${if follyMobile then "1" else "0"}"
    "-fpermissive"
    "-mavx2"
    "-mfma"
    "-mavx"
    "-mf16c"
    "-mlzcnt"
  ];
  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-Wno-dev"
    "-DCMAKE_CXX_STANDARD=17"
  ];

  meta = with lib; {
    description = "An open-source C++ library developed and used at Facebook";
    homepage = "https://github.com/facebook/folly";
    license = licenses.asl20;
    # 32bit is not supported: https://github.com/facebook/folly/issues/103
    platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ];
    maintainers = with maintainers; [ abbradar pierreis ];
  };
}
