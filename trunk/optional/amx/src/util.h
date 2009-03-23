#ifndef UTIL_H
#define UTIL_H

// Cross compatibility
#ifdef WIN32

	#define STDCALL __stdcall

	#define getProcAddr GetProcAddress
	#define loadLib LoadLibrary
	#define freeLib FreeLibrary

	int setenv(const char* name, const char* value, int overwrite);

#else

	#define HMODULE void*
	#define STDCALL

	void* getProcAddr ( HMODULE hModule, const char* szProcName );
	#define loadLib(x) dlopen(x, RTLD_NOW)
	#define freeLib dlclose

#endif

#ifndef BYTE
	#define BYTE unsigned char
	#define WORD unsigned short
	#define DWORD unsigned long
#endif


// Util functions
void lua_pushamxstring(lua_State *luaVM, AMX *amx, cell addr);
void lua_pushamxstring(lua_State *luaVM, AMX *amx, cell *physaddr);
void lua_pushremotevalue(lua_State *localVM, lua_State *remoteVM, int index, bool toplevel = true);
void lua_pushremotevalues(lua_State *localVM, lua_State *remoteVM, int num);
std::vector<AMX *> getResourceAMXs(lua_State *luaVM);
std::string getScriptFilePath(AMX *amx, const char *filename);
extern "C" char* getScriptFilePath(AMX *amx, char *dest, const char *filename, size_t destsize);
bool isSafePath(const char* path);

#endif

