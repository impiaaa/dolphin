// Copyright 2016 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#include <Metal/Metal.h>
#include <QuartzCore/QuartzCore.h>

#include "Common/Logging/Log.h"

#include "VideoBackends/Metal/Interface.h"

#include "VideoCommon/VideoConfig.h"

namespace MetalInt
{
	
	static id<MTLDevice> device = nullptr;
	static id<MTLCommandQueue> command_queue = nullptr;
	
	bool Create(NSView *view)
	{
		
		@try
		{
			NSArray<id<MTLDevice>>* devices = MTLCopyAllDevices();
			device = devices[g_Config.iAdapter];
			
			CAMetalLayer* metal_layer = [CAMetalLayer layer];
			metal_layer.device = device;
			metal_layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
			metal_layer.frame = view.bounds;
			[view.layer addSublayer:metal_layer];
			
			[devices release];
			[metal_layer release];
		}
		@catch (NSException *exception)
		{
			ERROR_LOG(VIDEO, "Got exception creating Metal layer: %s",
			          [[exception description] UTF8String]);
			return false;
		}
		
		command_queue = [device newCommandQueue];
		if (!command_queue)
		{
			ERROR_LOG(VIDEO, "Could not create Metal command queue");
			return false;
		}
		
		return true;
	}
	
	void Close()
	{
		[command_queue release];
		command_queue = nullptr;
		
		[device release];
		device = nullptr;
	}
	
}
