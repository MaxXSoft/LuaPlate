#include <iostream>
#include <cstring>

#include "version.h"
#include "plate/canvas.h"
#include "script/script.h"
#include "util/log.h"

using namespace std;

namespace {

bool quit_flag = false;

void PrintVersion() {
  cout << APP_NAME << " version " << APP_VERSION << endl;
  cout << "Copyright (C) 2010-2019 MaxXing, MaxXSoft. License GPLv3.";
  cout << endl;
}

int MarkQuit(const ScriptHost &h) {
  quit_flag = true;
  return 0;
}

void RegisterFunctions(ScriptHost &host, Canvas &canvas) {
  host.RegisterFunction("set_color", [&canvas](const ScriptHost &h) {
    auto i = h.GetValue<long long>(1);
    canvas.SetDrawColor(i);
    return 0;
  });
  host.RegisterFunction("set_color_rgba", [&canvas](const ScriptHost &h) {
    auto r = h.GetValue<int>(1);
    auto g = h.GetValue<int>(2);
    auto b = h.GetValue<int>(3);
    auto a = h.GetValue<int>(4);
    canvas.SetDrawColor(r, g, b, a);
    return 0;
  });
  host.RegisterFunction("set_title", [&canvas](const ScriptHost &h) {
    auto title = h.GetValue<string_view>(1);
    canvas.SetTitle(title);
    return 0;
  });
  host.RegisterFunction("resize", [&canvas](const ScriptHost &h) {
    auto width = h.GetValue<int>(1);
    auto height = h.GetValue<int>(2);
    canvas.Resize(width, height);
    return 0;
  });
  host.RegisterFunction("fill", [&canvas](const ScriptHost &h) {
    canvas.Fill();
    return 0;
  });
  host.RegisterFunction("draw_point", [&canvas](const ScriptHost &h) {
    auto x = h.GetValue<int>(1);
    auto y = h.GetValue<int>(2);
    canvas.DrawPoint(x, y);
    return 0;
  });
  host.RegisterFunction("draw_line", [&canvas](const ScriptHost &h) {
    auto x1 = h.GetValue<int>(1);
    auto y1 = h.GetValue<int>(2);
    auto x2 = h.GetValue<int>(3);
    auto y2 = h.GetValue<int>(4);
    canvas.DrawLine(x1, y1, x2, y2);
    return 0;
  });
  host.RegisterFunction("draw_rect", [&canvas](const ScriptHost &h) {
    auto x = h.GetValue<int>(1);
    auto y = h.GetValue<int>(2);
    auto w = h.GetValue<int>(3);
    auto height = h.GetValue<int>(4);
    canvas.DrawRect(x, y, w, height);
    return 0;
  });
  host.RegisterFunction("fill_rect", [&canvas](const ScriptHost &h) {
    auto x = h.GetValue<int>(1);
    auto y = h.GetValue<int>(2);
    auto w = h.GetValue<int>(3);
    auto height = h.GetValue<int>(4);
    canvas.FillRect(x, y, w, height);
    return 0;
  });
  host.RegisterFunction("quit", MarkQuit);
  host.RegisterFunction("get_size", [&canvas](const ScriptHost &h) {
    h.PushValue(static_cast<int>(canvas.width()));
    h.PushValue(static_cast<int>(canvas.height()));
    return 2;
  });
  host.RegisterFunction("get_color", [&canvas](const ScriptHost &h) {
    h.PushValue(canvas.r());
    h.PushValue(canvas.g());
    h.PushValue(canvas.b());
    h.PushValue(canvas.a());
    return 4;
  });
}

void TryToCall(const ScriptHost &host, string_view name) {
  try {
    host.CallFunction(name);
  }
  catch (LuaPlateException &e) {
    // do nothing
  }
}

}  // namespace

int main(int argc, const char *argv[]) {
  // check argument count
  if (argc < 2) {
    cerr << "invalid argument." << endl;
    cerr << "usage: " << argv[0] << " <lua_file>" << endl;
    return 1;
  }

  // check input
  auto input = argv[1];
  if (!strcmp(input, "-v")) {
    PrintVersion();
    return 0;
  }

  // initialize canvas
  Canvas canvas;

  // initialize script engine
  ScriptHost host(input);
  RegisterFunctions(host, canvas);
  host.Run();

  // call initialize function in script
  TryToCall(host, "scene_begin");
  // run main loop
  while (!quit_flag) {
    if (!canvas.PollEvent()) break;
    // call update function in script
    TryToCall(host, "scene_update");
    canvas.Render();
  }
  // call release function in script
  TryToCall(host, "scene_end");
  canvas.Quit();
  return 0;
}
