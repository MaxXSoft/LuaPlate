#ifndef LUAPLATE_SCRIPT_SCRIPT_H_
#define LUAPLATE_SCRIPT_SCRIPT_H_

#include <string_view>
#include <functional>
#include <utility>
#include <cstddef>

class ScriptHost;
using ScriptCallback = std::function<int(const ScriptHost &)>;

class ScriptHost {
 public:
  ScriptHost(std::string_view file) { InitLua(file); }
  ~ScriptHost() { DestroyLua(); }

  // add package path
  void AddPackagePath(std::string_view path);
  // register a user function
  void RegisterFunction(std::string_view name, ScriptCallback callback);
  // run current script
  void Run();

  // get value from top of stack
  template <typename T>
  T GetValue() const { return GetValue<T>(-1); }
  // get value from specific index of stack
  template <typename T>
  T GetValue(int index) const { return 0; }
  // push bool to stack
  void PushValue(bool value) const;
  // push int to stack
  void PushValue(int value) const;
  // push long long to stack
  void PushValue(long long value) const;
  // push float to stack
  void PushValue(float value) const;
  // push double to stack
  void PushValue(double value) const;
  // push raw string to stack
  void PushValue(const char *value) const;
  // push string view to stack
  void PushValue(std::string_view value) const;

  // call a function in script
  template <typename Ret, typename... Args>
  Ret CallFunction(std::string_view name, Args &&... args) const {
    PrepareFunctionCall(name);
    auto unpack = {0, (PushValue(std::forward<Args>(args)), 0)...};
    static_cast<void>(unpack);
    DoFuncCall(sizeof...(Args), 1);
    return GetValue<Ret>();
  }

  // call a function in script (which return type is void)
  template <typename... Args>
  void CallFunction(std::string_view name, Args &&... args) const {
    PrepareFunctionCall(name);
    auto unpack = {0, (PushValue(std::forward<Args>(args)), 0)...};
    static_cast<void>(unpack);
    DoFuncCall(sizeof...(Args), 0);
  }

 private:
  // initialize Lua runtime
  void InitLua(std::string_view file);
  // set up callback type in Lua
  void InitCallbackType();
  // destroy Lua runtime
  void DestroyLua();

  // check if there is an error in current Lua function call
  void CheckError(int ret) const;
  // prepare a function call
  void PrepareFunctionCall(std::string_view name) const;
  // do a function call
  void DoFuncCall(std::size_t arg_count, std::size_t ret_count) const;

  // Lua virtual machine
  void *lua_vm_;
};

#endif  // LUAPLATE_SCRIPT_SCRIPT_H_
