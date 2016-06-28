// Copyright 2016 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#include "Common/CommonFuncs.h"

#include "VideoBackends/Metal/StreamBuffer.h"
#include "VideoBackends/Metal/Interface.h"

namespace Metal
{
	StreamBuffer::StreamBuffer(u32 size)
	: m_size(ROUND_UP_POW2(size))
	{
		m_iterator = 0;
	}
	
	StreamBuffer::~StreamBuffer()
	{
	}
	
	class MapAndOrphan : public StreamBuffer
	{
	public:
		MapAndOrphan(u32 size) : StreamBuffer(size)
		{
			m_buffer = [MetalInt::device newBufferWithLength:m_size
						 options:MTLResourceCPUCacheModeDefaultCache|MTLResourceStorageModeShared];
		}
		
		~MapAndOrphan()
		{
			[m_buffer release];
		}
		
		std::pair<u8*, u32> Map(u32 size) override
		{
			if (m_iterator + size >= m_size)
			{
				[m_buffer release];
				m_buffer = [MetalInt::device newBufferWithLength:m_size
							 options:MTLResourceCPUCacheModeDefaultCache|MTLResourceStorageModeShared];
				m_iterator = 0;
			}
			u8* pointer = (u8*)m_buffer.contents;
			return std::make_pair(pointer, m_iterator);
		}
		
		void Unmap(u32 used_size) override
		{
			[m_buffer didModifyRange:NSMakeRange(0, m_size)];
			m_iterator += used_size;
		}

	};
	
	std::unique_ptr<StreamBuffer> StreamBuffer::Create(u32 size)
	{
		return std::make_unique<MapAndOrphan>(size);
	}
}
