#ifndef LUAPLATE_PLATE_CANVAS_H_
#define LUAPLATE_PLATE_CANVAS_H_

#include <string_view>
#include <cstddef>
#include <cstdint>

#include "plate/sdltype.h"

class Canvas {
 public:
  Canvas()
      : window_(nullptr, nullptr), renderer_(nullptr, nullptr),
        width_(640), height_(480), color_(0xffffffff) {
    InitSDL();
  }
  ~Canvas() { DestroySDL(); }

  void SetDrawColor(std::uint32_t rgba);
  void SetDrawColor(std::uint8_t r, std::uint8_t g, std::uint8_t b,
                    std::uint8_t a);

  void SetTitle(std::string_view title);
  void Resize(std::size_t width, std::size_t height);
  void Fill();

  void DrawPoint(int x, int y);
  void DrawLine(int x1, int y1, int x2, int y2);
  void DrawRect(int x, int y, int w, int h);
  void FillRect(int x, int y, int w, int h);

  bool PollEvent();
  void Render();
  void Quit();

  std::size_t width() const { return width_; }
  std::size_t height() const { return height_; }
  std::uint32_t rgba() const { return color_; }
  std::uint8_t r() const {
    return (color_ & (0xff << kColorOffsetR)) >> kColorOffsetR;
  }
  std::uint8_t g() const {
    return (color_ & (0xff << kColorOffsetG)) >> kColorOffsetG;
  }
  std::uint8_t b() const {
    return (color_ & (0xff << kColorOffsetB)) >> kColorOffsetB;
  }
  std::uint8_t a() const {
    return (color_ & (0xff << kColorOffsetA)) >> kColorOffsetA;
  }

 private:
  const std::size_t kColorOffsetR = 24;
  const std::size_t kColorOffsetG = 16;
  const std::size_t kColorOffsetB = 8;
  const std::size_t kColorOffsetA = 0;

  void InitSDL();
  void DestroySDL();

  SDLWindowPtr window_;
  SDLRendererPtr renderer_;
  std::size_t width_, height_;
  std::uint32_t color_;
};

#endif  // LUAPLATE_PLATE_CANVAS_H_
