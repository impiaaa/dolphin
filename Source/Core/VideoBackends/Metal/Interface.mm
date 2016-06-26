// Copyright 2016 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#include <Metal/Metal.h>
#include <QuartzCore/QuartzCore.h>

#include "Common/Logging/Log.h"

#include "VideoCommon/VideoConfig.h"
#include "VideoBackends/Metal/Interface.h"

namespace MetalInt {
  bool Create(NSView *view) {
    @try {
      NSArray<id<MTLDevice>>* devices = MTLCopyAllDevices();
      id<MTLDevice> device = devices[g_Config.iAdapter];
      
      CAMetalLayer *metalLayer = [CAMetalLayer layer];
      metalLayer.device = device;
      metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
      metalLayer.frame = view.bounds;
      [view.layer addSublayer:metalLayer];
      
      [metalLayer release];
      [device release];
      [devices release];
    }
    @catch (NSException *exception) {
      ERROR_LOG(VIDEO, "Got exception creating Metal view: %s", [[exception description] UTF8String]);
      return false;
    }
    
    return true;
  }
}