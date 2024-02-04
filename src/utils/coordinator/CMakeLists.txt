project(MapReduce)

add_library(
  coordinator_utils_lib #library name
  STATIC
  coordinator.h
)

set_target_properties(coordinator_utils_lib PROPERTIES LINKER_LANGUAGE CXX)
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
