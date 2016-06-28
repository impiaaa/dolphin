// Copyright 2016 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#pragma once

#include <array>
#include <memory>
#include <utility>

#include <Metal/Metal.h>

#include "VideoCommon/VideoCommon.h"

namespace Metal
{
	// Use OpenGL-like map buffers for now - Metal doesn't seem to have async buffers
	class StreamBuffer
	{
	public:
		static std::unique_ptr<StreamBuffer> Create(u32 size);
		virtual ~StreamBuffer();
		
		virtual std::pair<u8*, u32> Map(u32 size) = 0;
		virtual void Unmap(u32 used_size) = 0;
		
		std::pair<u8*, u32> Map(u32 size, u32 stride)
		{
			u32 padding = m_iterator % stride;
			if (padding)
			{
				m_iterator += stride - padding;
			}
			return Map(size);
		}
		
		id<MTLBuffer> m_buffer;
		
	protected:
		StreamBuffer(u32 size);
		
		const u32 m_size;
		
		u32 m_iterator;
	};
}
