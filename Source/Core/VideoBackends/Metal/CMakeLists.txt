set(SRCS
	Render.cpp
	VertexManager.cpp
	ShaderCache.cpp
	main.mm)

find_library(METAL_FRAMEWORK Metal)
mark_as_advanced(METAL_FRAMEWORK)
set(LIBS	${LIBS}
			videocommon
			SOIL
			common
			${METAL_FRAMEWORK})

add_dolphin_library(videometal "${SRCS}" "${LIBS}")
