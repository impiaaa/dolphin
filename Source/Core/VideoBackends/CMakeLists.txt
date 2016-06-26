add_subdirectory(OGL)
add_subdirectory(Null)
add_subdirectory(Software)
if(APPLE)
	add_subdirectory(Metal)
endif()
# TODO: Add other backends here!
