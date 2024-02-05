project(MapReduce)

add_library(
  zk_utils_lib #library name
  STATIC
  # zk.h zk.cc
  zkManager.h zkManager.cc
)

set_target_properties(zk_utils_lib PROPERTIES LINKER_LANGUAGE CXX)
target_link_libraries(zk_utils_lib coordinator_utils_lib ${_REFLECTION} ${ZOOKEEPER_LIBRARIES} ${CONSERVATOR_LIBRARIES} ${_GLOG})
# target_link_libraries(zk_utils_lib ui_grpc_proto ${_REFLECTION}  ${ZOOKEEPER_LIBRARIES} ${CONSERVATOR_LIBRARIES} ${_GLOG})
# target_link_libraries(zk_utils_lib ui_grpc_proto ${_REFLECTION}  ${ZOOKEEPER_LIBRARIES} ${CONSERVATOR_LIBRARIES} ${_GRPC_GRPCPP} ${_PROTOBUF_LIBPROTOBUF} ${_GLOG})
# target_include_directories(zk_utils_lib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../../protos)
include_directories(${CMAKE_CURRENT_SOURCE_DIR})