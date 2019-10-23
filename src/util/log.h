#ifndef LUAPLATE_UTIL_LOG_H_
#define LUAPLATE_UTIL_LOG_H_

#include <string_view>
#include <stdexcept>

#define LOG_ERROR(msg) throw LuaPlateException(msg)

class LuaPlateException : public std::runtime_error {
 public:
  LuaPlateException(std::string_view msg)
      : std::runtime_error(msg.data()) {}
};

#endif  // LUAPLATE_UTIL_LOG_H_
