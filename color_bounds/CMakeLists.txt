cmake_minimum_required(VERSION 3.14 FATAL_ERROR)
project(tabucol)

set(CMAKE_CXX_STANDARD 17)

# -Wsign-conversion -Weffc++
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_ARCH_FLAGS} -O0 -g -ldl -lm -isystem dir -Wall -Wextra -Wshadow -Wnon-virtual-dtor -Wold-style-cast -Wcast-align -Wunused -Woverloaded-virtual -Wpedantic -Wconversion -Wmisleading-indentation -Wduplicated-cond -Wduplicated-branches -Wlogical-op -Wnull-dereference -Wuseless-cast -Wdouble-promotion -Wformat=2")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_ARCH_FLAGS} -O3 -DNDEBUG -ldl -lm -Wall -s -isystem dir -Wall -Wextra -Wshadow -Wnon-virtual-dtor -Wold-style-cast -Wcast-align -Wunused -Woverloaded-virtual -Wpedantic -Wconversion -Wmisleading-indentation -Wduplicated-cond -Wduplicated-branches -Wlogical-op -Wnull-dereference -Wuseless-cast -Wdouble-promotion -Wformat=2")

add_executable(${CMAKE_PROJECT_NAME}
    tabucol/main.cpp
    tabucol/utils.cpp tabucol/utils.hpp

    # representation
    tabucol/Graph.cpp tabucol/Graph.hpp
    tabucol/Solution.cpp tabucol/Solution.hpp
)

set_property(TARGET ${CMAKE_PROJECT_NAME} PROPERTY CXX_STANDARD 17)
