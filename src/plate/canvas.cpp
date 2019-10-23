#include "plate/canvas.h"

#include <stdexcept>
#include <cstdlib>

#include "util/log.h"

void Canvas::InitSDL() {
  if (window_) return;
  // initialize SDL
  SDL_Init(SDL_INIT_EVERYTHING);
  std::atexit(SDL_Quit);
  // create window
  window_ =
      SDLWindowPtr(SDL_CreateWindow("LuaPlate", SDL_WINDOWPOS_CENTERED,
                                    SDL_WINDOWPOS_CENTERED, width_, height_,
                                    SDL_WINDOW_SHOWN),
                   SDL_DestroyWindow);
  if (window_) {
    // initialize renderer
    renderer_ =
        SDLRendererPtr(SDL_CreateRenderer(window_.get(), -1,
                                          SDL_RENDERER_ACCELERATED |
                                              SDL_RENDERER_PRESENTVSYNC),
                       SDL_DestroyRenderer);
    if (renderer_) {
      SDL_SetRenderDrawBlendMode(renderer_.get(), SDL_BLENDMODE_BLEND);
      return;
    }
  }
  // report error
  LOG_ERROR("failed to initialize SDL2");
}

void Canvas::DestroySDL() {
  if (window_) SDL_Quit();
}

void Canvas::SetDrawColor(std::uint32_t rgba) {
  color_ = rgba;
  SDL_SetRenderDrawColor(renderer_.get(), r(), g(), b(), a());
}

void Canvas::SetDrawColor(std::uint8_t r, std::uint8_t g, std::uint8_t b,
                          std::uint8_t a) {
  color_ = r << kColorOffsetR;
  color_ |= g << kColorOffsetG;
  color_ |= b << kColorOffsetB;
  color_ |= a << kColorOffsetA;
  SDL_SetRenderDrawColor(renderer_.get(), r, g, b, a);
}

void Canvas::SetTitle(std::string_view title) {
  SDL_SetWindowTitle(window_.get(), title.data());
}

void Canvas::Resize(std::size_t width, std::size_t height) {
  width_ = width;
  height_ = height;
  SDL_SetWindowSize(window_.get(), width, height);
}

void Canvas::Fill() {
  SDL_RenderClear(renderer_.get());
}

void Canvas::DrawPoint(int x, int y) {
  SDL_RenderDrawPoint(renderer_.get(), x, y);
}

void Canvas::DrawLine(int x1, int y1, int x2, int y2) {
  SDL_RenderDrawLine(renderer_.get(), x1, y1, x2, y2);
}

void Canvas::DrawRect(int x, int y, int w, int h) {
  SDLRect rect = {x, y, w, h};
  SDL_RenderDrawRect(renderer_.get(), &rect);
}

void Canvas::FillRect(int x, int y, int w, int h) {
  SDLRect rect = {x, y, w, h};
  SDL_RenderFillRect(renderer_.get(), &rect);
}

bool Canvas::PollEvent() {
  if (!window_) return false;
  // handle event
  SDL_Event event;
  while (SDL_PollEvent(&event)) {
    if (event.type == SDL_QUIT || (event.type == SDL_KEYDOWN &&
                                   event.key.keysym.sym == SDLK_ESCAPE)) {
      return false;
    }
  }
  return true;
}

void Canvas::Render() {
  SDL_RenderPresent(renderer_.get());
  SDL_Delay(5);
}

void Canvas::Quit() {
  DestroySDL();
}
