#include "script/script.h"

#include <stdexcept>
#include <string>

#include "lua.hpp"
#include "util/log.h"

#define LUA_VM reinterpret_cast<lua_State *>(lua_vm_)

namespace {

// type name of all callbacks in script host, used in Lua
const char *kCallbackTypeName = "SECallback";

// definition of callbacks in script host
struct CallbackType {
  ScriptCallback callback;
  ScriptHost *host;
};

// handler of '__call' method of callback type in Lua
int LuaCallbackCall(lua_State *lua_vm) {
  // get copy of user data from Lua's stack
  auto ptr = luaL_checkudata(lua_vm, 1, kCallbackTypeName);
  auto callback = *static_cast<CallbackType *>(ptr);
  // remove from the stack before executing
  // so that like all other callbacks
  // function finds only its intended arguments on the stack
  lua_remove(lua_vm, 1);
  // invoke callback
  return callback.callback(*callback.host);
}

// handler of '__gc' method of callback type in Lua
int LuaCallbackGC(lua_State *lua_vm) {
  auto ptr = luaL_testudata(lua_vm, 1, kCallbackTypeName);
  if (!ptr) {
    lua_pushstring(lua_vm, "garbage collection failure of SECallback");
    lua_error(lua_vm);
  }
  else {
    auto callback = static_cast<CallbackType *>(ptr);
    callback->callback.~function();
    callback->host = nullptr;
  }
  return 0;
}

}  // namespace

void ScriptHost::InitLua(std::string_view file) {
  // create VM instance
  lua_vm_ = luaL_newstate();
  // add standard libraries to Lua VM
  luaL_openlibs(LUA_VM);
  // load script file
  CheckError(luaL_loadfile(LUA_VM, file.data()));
  // initialize callback type
  InitCallbackType();
}

void ScriptHost::InitCallbackType() {
  // create new metatable
  luaL_newmetatable(LUA_VM, kCallbackTypeName);
  // create callback
  lua_pushcfunction(LUA_VM, LuaCallbackCall);
  lua_setfield(LUA_VM, -2, "__call");
  // create destructor
  lua_pushcfunction(LUA_VM, LuaCallbackGC);
  lua_setfield(LUA_VM, -2, "__gc");
  // pop table from stack
  lua_pop(LUA_VM, 1);
}

void ScriptHost::DestroyLua() {
  // destroy VM instance
  if (lua_vm_) lua_close(LUA_VM);
}

void ScriptHost::CheckError(int ret) const {
  if (ret != LUA_OK) {
    auto err_msg = lua_tostring(LUA_VM, -1);
    throw std::runtime_error(err_msg);
  }
}

void ScriptHost::PrepareFunctionCall(std::string_view name) const {
  lua_getglobal(LUA_VM, name.data());
  if (!lua_isfunction(LUA_VM, -1)) {
    lua_pop(LUA_VM, 1);
    LOG_ERROR("calling an invalid Lua function");
  }
}

void ScriptHost::DoFuncCall(std::size_t arg_count,
                            std::size_t ret_count) const {
  CheckError(lua_pcall(LUA_VM, arg_count, ret_count, 0));
}

void ScriptHost::AddPackagePath(std::string_view path) {
  // get field "path" from table at top of stack (-1)
  lua_getglobal(LUA_VM, "package");
  lua_getfield(LUA_VM, -1, "path");
  // grab path string from top of stack
  std::string cur_path = lua_tostring(LUA_VM, -1);
  // add new path
  cur_path.push_back(';');
  cur_path.append(path);
  // get rid of the string on the stack we just pushed
  lua_pop(LUA_VM, 1);
  // push the new one
  lua_pushstring(LUA_VM, cur_path.c_str());
  // set the field "path" in table at -2 with value at top of stack
  lua_setfield(LUA_VM, -2, "path");
  // get rid of package table from top of stack
  lua_pop(LUA_VM, 1);
}

void ScriptHost::RegisterFunction(std::string_view name,
                                    ScriptCallback callback) {
  // get a new memory block from Lua to store user data
  void *mem = lua_newuserdata(LUA_VM, sizeof(CallbackType));
  // set type of user data
  luaL_setmetatable(LUA_VM, kCallbackTypeName);
  // initialize memory block
  new (mem) CallbackType({std::move(callback), this});
  // register it as a global variable (global function)
  lua_setglobal(LUA_VM, name.data());
}

void ScriptHost::Run() {
  CheckError(lua_pcall(LUA_VM, 0, LUA_MULTRET, 0));
}

template <>
bool ScriptHost::GetValue(int index) const {
  return lua_toboolean(LUA_VM, index);
}

template <>
int ScriptHost::GetValue(int index) const {
  return lua_tonumber(LUA_VM, index);
}

template <>
long long ScriptHost::GetValue(int index) const {
  return lua_tonumber(LUA_VM, index);
}

template <>
float ScriptHost::GetValue(int index) const {
  return lua_tonumber(LUA_VM, index);
}

template <>
double ScriptHost::GetValue(int index) const {
  return lua_tonumber(LUA_VM, index);
}

template <>
std::string_view ScriptHost::GetValue(int index) const {
  return lua_tostring(LUA_VM, index);
}

void ScriptHost::PushValue(bool value) const {
  lua_pushboolean(LUA_VM, value);
}

void ScriptHost::PushValue(int value) const {
  lua_pushnumber(LUA_VM, value);
}

void ScriptHost::PushValue(long long value) const {
  lua_pushnumber(LUA_VM, value);
}

void ScriptHost::PushValue(float value) const {
  lua_pushnumber(LUA_VM, value);
}

void ScriptHost::PushValue(double value) const {
  lua_pushnumber(LUA_VM, value);
}

void ScriptHost::PushValue(const char *value) const {
  lua_pushstring(LUA_VM, value);
}

void ScriptHost::PushValue(std::string_view value) const {
  lua_pushstring(LUA_VM, value.data());
}
