// Copyright 2016 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#include "VideoBackends/Metal/ShaderCache.h"
#include "VideoBackends/Metal/VertexManager.h"

#include "VideoCommon/IndexGenerator.h"
#include "VideoCommon/Statistics.h"
#include "VideoCommon/VertexLoaderManager.h"
#include "VideoCommon/VideoConfig.h"

namespace Metal
{
	class MetalNativeVertexFormat : public NativeVertexFormat
	{
	public:
		MetalNativeVertexFormat() {}
		void SetupVertexPointers() override {}
	};
	
	NativeVertexFormat*
	VertexManager::CreateNativeVertexFormat(const PortableVertexDeclaration& vtx_decl)
	{
		return new MetalNativeVertexFormat;
	}
	
	VertexManager::VertexManager() : m_local_v_buffer(MAXVBUFFERSIZE), m_local_i_buffer(MAXIBUFFERSIZE)
	{
	}
	
	VertexManager::~VertexManager()
	{
	}
	
	void VertexManager::ResetBuffer(u32 stride)
	{
		s_pCurBufferPointer = s_pBaseBufferPointer = m_local_v_buffer.data();
		s_pEndBufferPointer = s_pCurBufferPointer + m_local_v_buffer.size();
		IndexGenerator::Start(&m_local_i_buffer[0]);
	}
	
	void VertexManager::vFlush(bool use_dst_alpha)
	{
		VertexShaderCache::s_instance->SetShader(use_dst_alpha ? DSTALPHA_DUAL_SOURCE_BLEND : DSTALPHA_NONE,
		                                         current_primitive_type);
		GeometryShaderCache::s_instance->SetShader(use_dst_alpha ? DSTALPHA_DUAL_SOURCE_BLEND : DSTALPHA_NONE,
		                                           current_primitive_type);
		PixelShaderCache::s_instance->SetShader(use_dst_alpha ? DSTALPHA_DUAL_SOURCE_BLEND : DSTALPHA_NONE,
		                                        current_primitive_type);
	}
	
}  // namespace
