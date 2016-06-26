// Copyright 2016 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#include <Metal/Metal.h>

#include "Core/Host.h"

#include "VideoBackends/Metal/FramebufferManager.h"
#include "VideoBackends/Metal/PerfQuery.h"
#include "VideoBackends/Metal/Render.h"
#include "VideoBackends/Metal/ShaderCache.h"
#include "VideoBackends/Metal/TextureCache.h"
#include "VideoBackends/Metal/VertexManager.h"
#include "VideoBackends/Metal/VideoBackend.h"
#include "VideoBackends/Metal/Interface.h"

#include "VideoCommon/BPStructs.h"
#include "VideoCommon/CommandProcessor.h"
#include "VideoCommon/Fifo.h"
#include "VideoCommon/IndexGenerator.h"
#include "VideoCommon/OnScreenDisplay.h"
#include "VideoCommon/OpcodeDecoding.h"
#include "VideoCommon/PixelEngine.h"
#include "VideoCommon/PixelShaderManager.h"
#include "VideoCommon/VertexLoaderManager.h"
#include "VideoCommon/VertexShaderManager.h"
#include "VideoCommon/VideoBackendBase.h"
#include "VideoCommon/VideoConfig.h"

namespace Metal
{
  
  unsigned int VideoBackend::PeekMessages()
  {
    return 0;
  }
  
  std::string VideoBackend::GetName() const
  {
    return "Metal";
  }
  
  std::string VideoBackend::GetDisplayName() const
  {
    return "Metal (experimental)";
  }

  static void InitBackendInfo()
  {
    g_Config.backend_info.APIType = API_METAL;
    g_Config.backend_info.bSupportsExclusiveFullscreen = false;
    g_Config.backend_info.bSupportsDualSourceBlend = false;
    g_Config.backend_info.bSupportsEarlyZ = false;
    g_Config.backend_info.bSupportsPrimitiveRestart = false;
    g_Config.backend_info.bSupportsOversizedViewports = false;
    g_Config.backend_info.bSupportsGeometryShaders = false;
    g_Config.backend_info.bSupports3DVision = false;
    g_Config.backend_info.bSupportsPostProcessing = false;
    g_Config.backend_info.bSupportsPaletteConversion = false;
    g_Config.backend_info.bSupportsClipControl = false;
    
    g_Config.backend_info.Adapters.clear();

    // aamodes: We only support 1 sample, so no MSAA
    g_Config.backend_info.AAModes = {1};
    
    NSArray<id<MTLDevice>>* devices = MTLCopyAllDevices();
    for (unsigned int i = 0; i < devices.count; i++)
    {
      id<MTLDevice> device = devices[i];
      if ((int)i == g_Config.iAdapter)
      {
        
      }
      g_Config.backend_info.Adapters.push_back([device.name UTF8String]);
      [device release];
    }
    [devices release];
    
    g_Config.backend_info.PPShaders.clear();
    g_Config.backend_info.AnaglyphShaders.clear();
  }
  
  void VideoBackend::ShowConfig(void* parent_handle)
  {
    InitBackendInfo();
    Host_ShowVideoConfig(parent_handle, GetDisplayName(), "gfx_metal");
  }
  
  bool VideoBackend::Initialize(void* window_handle)
  {
    InitializeShared();
    InitBackendInfo();
    
    frameCount = 0;
    
    // Load Configs
    if (File::Exists(File::GetUserPath(D_CONFIG_IDX) + "GFX.ini"))
      g_Config.Load(File::GetUserPath(D_CONFIG_IDX) + "GFX.ini");
    else
      g_Config.Load(File::GetUserPath(D_CONFIG_IDX) + "gfx_metal.ini");
    g_Config.GameIniLoad();
    g_Config.UpdateProjectionHack();
    g_Config.VerifyValidity();
    UpdateActiveConfig();
    
    // Do our OSD callbacks
    OSD::DoCallbacks(OSD::CallbackType::Initialization);
    
    // Initialize VideoCommon
    CommandProcessor::Init();
    PixelEngine::Init();
    BPInit();
    Fifo::Init();
    OpcodeDecoder::Init();
    IndexGenerator::Init();
    VertexShaderManager::Init();
    PixelShaderManager::Init();
    VertexLoaderManager::Init();
    Host_Message(WM_USER_CREATE);
    
    if (!MetalInt::Create((NSView *)window_handle))
      return false;
    
    m_initialized = true;
    
    return true;
  }
  
  // This is called after Initialize() from the Core
  // Run from the graphics thread
  void VideoBackend::Video_Prepare()
  {
    g_renderer = std::make_unique<Renderer>();
    g_vertex_manager = std::make_unique<VertexManager>();
    g_perf_query = std::make_unique<PerfQuery>();
    g_framebuffer_manager = std::make_unique<FramebufferManager>();
    g_texture_cache = std::make_unique<TextureCache>();
    VertexShaderCache::s_instance = std::make_unique<VertexShaderCache>();
    GeometryShaderCache::s_instance = std::make_unique<GeometryShaderCache>();
    PixelShaderCache::s_instance = std::make_unique<PixelShaderCache>();
  }
  
  void VideoBackend::Shutdown()
  {
    // Shutdown VideoCommon
    Fifo::Shutdown();
    VertexLoaderManager::Shutdown();
    VertexShaderManager::Shutdown();
    PixelShaderManager::Shutdown();
    OpcodeDecoder::Shutdown();
    
    // Do our OSD callbacks
    OSD::DoCallbacks(OSD::CallbackType::Shutdown);
  }
  
  void VideoBackend::Video_Cleanup()
  {
    PixelShaderCache::s_instance.reset();
    VertexShaderCache::s_instance.reset();
    GeometryShaderCache::s_instance.reset();
    g_texture_cache.reset();
    g_perf_query.reset();
    g_vertex_manager.reset();
    g_framebuffer_manager.reset();
    g_renderer.reset();
  }

}