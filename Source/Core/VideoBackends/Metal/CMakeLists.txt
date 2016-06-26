set(SRCS
	Render.cpp
	VertexManager.cpp
	ShaderCache.cpp
	Interface.mm
	main.mm)

find_library(METAL_FRAMEWORK Metal)
find_library(QC_FRAMEWORK QuartzCore)
mark_as_advanced(METAL_FRAMEWORK QC_FRAMEWORK)

set(LIBS	${LIBS}
			videocommon
			SOIL
			common
			${METAL_FRAMEWORK}
			${QC_FRAMEWORK})

add_dolphin_library(videometal "${SRCS}" "${LIBS}")
