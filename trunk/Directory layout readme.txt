New directory layout for MTA:SA 1.1 resources
---------------------------------------------

Important things to note:
* Any directory surrounded with [...] will be assumed to contain further directories and resources.
* The directory layout is to assist organising resources in the server directory only. Internally MTA:SA still sees all the resources in a big flat list.
* Therefore, do not use the [...] paths in script or config files.
* Therefore, you can move resources around without having to worry about [...] paths.
* But, a resource will not load if it exists twice anywhere in the directory hierarchy.
* And finally, this is only a suggested layout. You can move stuff around, although it's probably best to leave the official resources where they for simpler updating.
