file(GLOB HEADERS "include/cps/types/*.hpp")

add_library( cps_types
        asset.cpp
        public_key.cpp
        type_parser.cpp
        abi_serializer.cpp
             native.cpp
             ${HEADERS}
             "${CMAKE_CURRENT_SOURCE_DIR}/include/cps/types/generated.hpp"
             types.cps
             )
target_include_directories( cps_types PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include" )
target_link_libraries( cps_types cps_utilities fc )

add_executable( type_generator type_generator.cpp type_parser.cpp native.cpp )
target_include_directories( type_generator PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include" )
target_link_libraries( type_generator cps_utilities fc ${CMAKE_DL_LIBS} ${PLATFORM_SPECIFIC_LIBS}  )

add_custom_command( OUTPUT  "${CMAKE_CURRENT_SOURCE_DIR}/include/cps/types/generated.hpp"
                    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/type_generator ${CMAKE_CURRENT_SOURCE_DIR}/types.cps ${CMAKE_CURRENT_SOURCE_DIR}/include/cps/types/generated.hpp
                    DEPENDS types.cps type_generator )
INSTALL( TARGETS
   cps_types

   RUNTIME DESTINATION bin
   LIBRARY DESTINATION lib
   ARCHIVE DESTINATION lib
)
INSTALL( FILES ${HEADERS} DESTINATION "include/cps/types" )
