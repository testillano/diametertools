add_executable (convert main.cpp)
add_library(ert_logger STATIC IMPORTED)
set_property(TARGET ert_logger PROPERTY IMPORTED_LOCATION /usr/local/lib/ert/libert_logger.a)
target_link_libraries(convert ${ERT_DIAMETERTOOLS_TARGET_NAME} ert_logger)
