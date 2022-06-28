{ stdenv
, lib
, fetchFromGitHub
, fixDarwinDylibNames
, aws-sdk-cpp
, bison
, boost
, bzip2
, cmake
, double-conversion
, flex
, fmt_8
, folly
, gflags
, glog
, gtest
, gmock
, libevent
, lz4
, lzo
, ninja
, openssl
, python3
, protobuf
, re2
, snappy
, zlib
, zstd
, enableShared ? !stdenv.hostPlatform.isStatic
}:

stdenv.mkDerivation rec {
  pname = "velox";
  version = "12345.0";

  src = fetchFromGitHub {
    repo = "velox";
    owner = "facebookincubator";
    rev = "ad0122779cf7e43655c760dcc4f489f92fcbdd1c";
    hash = "sha256-JyJ5qn2/gzzzCRLkf7CdYa2SGi8ayPbysdxDzQbv8cI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
  ] ++ lib.optional stdenv.isDarwin fixDarwinDylibNames;
  buildInputs = [
    aws-sdk-cpp
    bison
    boost
    bzip2
    double-conversion
    flex
    fmt_8
    folly
    gflags
    glog
    gmock
    gtest
    libevent
    lz4
    lzo
    openssl
    python3
    protobuf
    re2
    snappy
    zlib
    zstd
  ];

  patches = [ ./cmake.patch ];

  NIX_CFLAGS_COMPILE = [
    "-mavx2"
    "-mfma"
    "-mavx"
    "-mf16c"
    "-mlzcnt"
  ];

  cmakeFlags = [
    "-DVELOX_BUILD_TESTING=ON"
    "-DCMAKE_CXX_STANDARD=17"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DVELOX_ENABLE_S3=ON"
    "-DVELOX_ENABLE_BENCHMARKS=OFF"
    "-DVELOX_ENABLE_EXAMPLES=OFF"
    "-DVELOX_BUILD_BENCHMARKS_LARGE=OFF"
    "-DAWSSDK_CORE_HEADER_FILE=${aws-sdk-cpp}/include/aws/core/Aws.h"
  ];

  doInstallCheck = true;
  GTEST_FILTER = "";
  installCheckPhase = ''
    echo $PWD
    ls $PWD
    ctest --build-run-dir build/release -j $NIX_BUILD_CORES --output-on-failure
  '';

  meta = with lib; {
    description = "A cross-language development platform for in-memory data";
    homepage = "https://github.com/facebookincubator/velox";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ cpcloud ];
  };
}
