// Copyright 2016 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#pragma once

#include <Cocoa/Cocoa.h>
#include <Metal/Metal.h>

namespace MetalInt
{
	extern id<MTLDevice> device;
	extern id<MTLCommandQueue> command_queue;
	
	bool Create(NSView *);
	void Close();
}
