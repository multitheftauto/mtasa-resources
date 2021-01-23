# Ingame Performance Browser

This resource allows you to see various performance information while ingame. 

## Usage 

Type `/ipb` to see performance stats. There are two targets, listed below.

**Client** with 5 categories:

- Lua timing
- Lua time recordings
- Lua memory
- Lib memory 
- Packet usage 

**Server** with 13 categories:

- Server info
- Lua timing
- Lua time recordings
- Lua memory
- Packet usage
- Sqlite timing 
- Bandwidth reduction
- Bandwidth usage 
- Server timing
- Function stats
- Debug info
- Debug table
- Lib memory

## Settings 

You can find 4 options in meta.xml, listed below.

**SaveHighCPUResources** - Save to RAM (every 5 seconds) CPU usage of resources that are using over specified % to debug when web/ingame PB isn't accessible

**SaveHighCPUResourcesAmount** - The amount of CPU a resource must use before being logged as a high CPU user. Default: 10

**NotifyIPBUsersOfHighUsage** - Requires SaveHighCPUResources to be enabled. Will notify any IPB users if a resources goes over the specified value of CPU %. Default is 50. Set to 1000 to disable.

**AccessRightName** - The name of the access right that a player needs in order to be able to use IPB. Default: general.http
