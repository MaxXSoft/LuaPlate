# LuaPlate

Let's play computer graphics with LuaPlate!

LuaPlate provides a canvas to Lua scripts, and allows scripts to draw points, lines or colors on the screen.

The entire project is based on SDL2 and Lua.

## Building LuaPlate

First of all, you should place Lua's header files and static library to `lib/lua`. Then run:

```
mkdir build
cd build && cmake ..
make -j8
```

LuaPlate can also build with LuaJIT. You can put related files into `lib/luajit` and run:

```
cd build && cmake -DUSE_LUAJIT=1 ..
make -j8
```

## Copyright and License

Copyright (C) 2010-2019 MaxXing. License GPLv3.
