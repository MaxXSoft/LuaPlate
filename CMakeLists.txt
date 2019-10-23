cmake_minimum_required(VERSION 3.5)
project(LuaPlate VERSION "0.0.1")

# set CMake module path
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# # set compiler path
# set(CMAKE_C_COMPILER "/usr/local/opt/gcc/bin/gcc-9")
# set(CMAKE_CXX_COMPILER "/usr/local/opt/gcc/bin/g++-9")

# C++17 standard support
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# enable all warnings and treat them as errors
if(MSVC)
  add_compile_options(/W3 /WX)
else()
  add_compile_options(-Wall -Werror)
endif()

# some definitions
add_compile_definitions(APP_NAME="${PROJECT_NAME}")
add_compile_definitions(APP_VERSION="${PROJECT_VERSION}")
add_compile_definitions(APP_VERSION_MAJOR=${PROJECT_VERSION_MAJOR})
add_compile_definitions(APP_VERSION_MINOR=${PROJECT_VERSION_MINOR})
add_compile_definitions(APP_VERSION_PATCH=${PROJECT_VERSION_PATCH})

# SDL2 package
find_package(SDL2 REQUIRED)
include_directories(${SDL2_INCLUDE_DIRS})

# Lua library
if(${USE_LUAJIT})
  message("Using LuaJIT...")
  set(LUA_DIR ${CMAKE_CURRENT_SOURCE_DIR}/lib/luajit)
  set(LUA_LIB ${LUA_DIR}/libluajit.a)
  if(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
    set(LUA_LINK_FLAGS "-pagezero_size 10000 -image_base 100000000")
  endif()
else()
  message("Using vanilla Lua...")
  set(LUA_DIR ${CMAKE_CURRENT_SOURCE_DIR}/lib/lua)
  set(LUA_LIB ${LUA_DIR}/liblua.a)
endif()

# project include directories
include_directories(src)
include_directories(${LUA_DIR})

# all of C++ source files
file(GLOB_RECURSE SOURCES "src/*.cpp")

# executable
add_executable(luaplate ${SOURCES})
target_link_libraries(luaplate ${SDL2_LIBRARIES} ${LUA_LIB})

# set link flags
if(DEFINED LUA_LINK_FLAGS)
  set_target_properties(luaplate PROPERTIES LINK_FLAGS ${LUA_LINK_FLAGS})
endif()
