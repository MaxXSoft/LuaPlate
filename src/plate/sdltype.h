#ifndef LUAPLATE_PLATE_SDLTYPE_H_
#define LUAPLATE_PLATE_SDLTYPE_H_

#include <memory>

#include "SDL.h"

using SDLWindowPtr =
    std::unique_ptr<SDL_Window, decltype(&SDL_DestroyWindow)>;
using SDLRendererPtr =
    std::unique_ptr<SDL_Renderer, decltype(&SDL_DestroyRenderer)>;
using SDLSurfacePtr =
    std::unique_ptr<SDL_Surface, decltype(&SDL_FreeSurface)>;
using SDLTexturePtr = std::shared_ptr<SDL_Texture>;
using SDLRect = SDL_Rect;

#endif  // LUAPLATE_PLATE_SDLTYPE_H_
