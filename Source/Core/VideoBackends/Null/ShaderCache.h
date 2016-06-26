// Copyright 2015 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#pragma once

#include <map>
#include <memory>

#include "VideoCommon/GeometryShaderGen.h"
#include "VideoCommon/PixelShaderGen.h"
#include "VideoCommon/VertexShaderGen.h"
#include "VideoCommon/VideoCommon.h"

namespace Null
{
template <typename Uid>
class ShaderCache
{
public:
  ShaderCache();
  virtual ~ShaderCache();

  void Clear();
  bool SetShader(DSTALPHA_MODE dst_alpha_mode, u32 primitive_type);

protected:
  virtual Uid GetUid(DSTALPHA_MODE dst_alpha_mode, u32 primitive_type, API_TYPE api_type) = 0;
  virtual ShaderCode GenerateCode(DSTALPHA_MODE dst_alpha_mode, API_TYPE api_type, Uid uid) = 0;

private:
  std::map<Uid, std::string> m_shaders;
  const std::string* m_last_entry = nullptr;
  Uid m_last_uid;
};

class VertexShaderCache : public ShaderCache<VertexShaderUid>
{
public:
  static std::unique_ptr<VertexShaderCache> s_instance;

protected:
  VertexShaderUid GetUid(DSTALPHA_MODE dst_alpha_mode, u32 primitive_type,
                         API_TYPE api_type) override
  {
    return GetVertexShaderUid();
  }
  ShaderCode GenerateCode(DSTALPHA_MODE dst_alpha_mode, API_TYPE api_type,
                          VertexShaderUid uid) override
  {
    return GenerateVertexShaderCode(api_type, uid.GetUidData());
  }
};

class GeometryShaderCache : public ShaderCache<GeometryShaderUid>
{
public:
  static std::unique_ptr<GeometryShaderCache> s_instance;

protected:
  GeometryShaderUid GetUid(DSTALPHA_MODE dst_alpha_mode, u32 primitive_type,
                           API_TYPE api_type) override
  {
    return GetGeometryShaderUid(primitive_type);
  }
  ShaderCode GenerateCode(DSTALPHA_MODE dst_alpha_mode, API_TYPE api_type,
                          GeometryShaderUid uid) override
  {
    return GenerateGeometryShaderCode(api_type, uid.GetUidData());
  }
};

class PixelShaderCache : public ShaderCache<PixelShaderUid>
{
public:
  static std::unique_ptr<PixelShaderCache> s_instance;

protected:
  PixelShaderUid GetUid(DSTALPHA_MODE dst_alpha_mode, u32 primitive_type,
                        API_TYPE api_type) override
  {
    return GetPixelShaderUid(dst_alpha_mode);
  }
  ShaderCode GenerateCode(DSTALPHA_MODE dst_alpha_mode, API_TYPE api_type,
                          PixelShaderUid uid) override
  {
    return GeneratePixelShaderCode(dst_alpha_mode, api_type, uid.GetUidData());
  }
};

}  // namespace NULL
