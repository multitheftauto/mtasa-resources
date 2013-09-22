#include <a_samp>
#include <file>

main()
{
	print("  AMX test filterscript loaded");
}

public OnFilterScriptInit()
{
	print("This filterscript doesn't do anything.");
	print("It is simply an example of a filterscript resource.");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}


