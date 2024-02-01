cmake_minimum_required(VERSION 3.5)
project(some_project_name)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/CMakeModules/")
include(FindProtobuf)
find_package(Protobuf REQUIRED)
find_package(Threads REQUIRED)
find_package(Zookeeper REQUIRED)
find_package(Check REQUIRED)
find_package(Conservator REQUIRED)
find_package(glog 0.5.0 REQUIRED)

set(Boost_USE_STATIC_LIBS ON)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
set(_GLOG glog::glog)
find_package(Boost REQUIRED COMPONENTS log thread system filesystem program_options)
find_package(Casablanca REQUIRED)
# TODO: re-enable
# find_package(AzureStorageCpp REQUIRED)
find_package(SSL REQUIRED)

# Path to a file.
set(AZURE_STORAGE_INCLUDE_DIR /usr/local/include/azure/storage)
find_library(AZURE_STORAGE_LIBRARY
        NAMES libazure-storage-blobs.so
        PATHS /usr/local/lib)
find_library(AZURE_STORAGE_COMMON_LIBRARY
        NAMES libazure-storage-common.so
        PATHS /usr/local/lib)
find_library(AZURE_CORE_LIBRARY
        NAMES libazure-core.so
        PATHS /usr/local/lib)
# set(AZURE_STORAGE_LIBRARY /usr/local/lib/libazure-storage-blobs.so)

set (CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} ~/src/cpp-netlib/build)
find_package (cppnetlib 0.13.0 REQUIRED)
include_directories ( ${CPPNETLIB_INCLUDE_DIRS} )
# target_link_libraries ( MyApplication ${CPPNETLIB_LIBRARIES} )
message(STATUS "Using cppnetlib dir: ${CPPNETLIB_INCLUDE_DIRS}")

find_package(RapidJSON REQUIRED)

include_directories(${AZURE_STORAGE_INCLUDE_DIR})
# include_directories(${AZURE_STORAGE_INCLUDE_DIR}/blobs)
include_directories(${CHECK_INCLUDE_DIRS})
include_directories(${ZOOKEEPER_INCLUDE_DIR}/zookeeper)
include_directories(${CONSERVATOR_INCLUDE_DIR}/conservator)

add_definitions(-std=c++14)
add_subdirectory(src)

file(COPY ${CMAKE_SOURCE_DIR}/k8s/run.sh DESTINATION ${CMAKE_BINARY_DIR})
file(COPY ${CMAKE_SOURCE_DIR}/k8s/mr_functions_v2.py DESTINATION ${CMAKE_BINARY_DIR})
