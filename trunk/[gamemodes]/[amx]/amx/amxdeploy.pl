#!/usr/bin/perl
use strict;
use File::Copy::Recursive qw(fcopy dircopy);
use XML::Twig;

use constant CONF_META_AUTHOR	=> "N/A";
use constant CONF_RESOURCE_AMX	=> "amx";

# Scans the directory for a valid SA-MP server
sub scanSAMPDir {
	my ($dir) = @_;
	opendir(DIR, $dir) or return ();
	my @reqfiles = grep { /^(server.cfg)|(gamemodes)$/ } readdir(DIR);
	closedir(DIR);
	return @reqfiles == 2;
}

# Scans the gamemodes and filterscripts directories
sub scanAMXFiles {
	my ($dir) = @_;
	opendir(DIR, $dir) or return ();
	my @amxs = map { /^(.*)\./ } grep { /\.amx$/i } readdir(DIR);
	closedir(DIR);
	return @amxs;
}

# Scans for plugins
sub scanPlugins {
	my ($dir) = @_;
	opendir(DIR, $dir) or return ();
	my @plugins = map { /^(.*)\./ } grep { /\.(dll|so)$/i } readdir(DIR);
	closedir(DIR);
	return @plugins;
}

# Scans the directory for a valid MTA server
sub scanMTADir {
	my ($dir) = @_;
	opendir(DIR, $dir . "/mods/deathmatch") or return 0;
	my @reqfiles = grep { /^(mtaserver.conf)|(resources)$/ } readdir(DIR);
	closedir(DIR);
	return @reqfiles == 2;
}

# Creates a metafile
sub createMetaFile {
	my ($name, $path, $isgamemode) = @_;
	open(METAFILE, ">", $path) or print "ERROR: Could not open '" . $path . "'!\n";
	print METAFILE "<meta>\n";
	print METAFILE "    <info name=\"" . $name . "\" author=\"" . CONF_META_AUTHOR . "\"" . ($isgamemode ? " type=\"map\" gamemodes=\"" . CONF_RESOURCE_AMX . "\"" : " type=\"misc\"") . " />\n";
#	print METAFILE "    <include resource=\"" . CONF_RESOURCE_AMX . "\" />\n";
	print METAFILE "    <amx src=\"" . $name . ".amx\" />\n";
	print METAFILE "    <settings>\n";
	print METAFILE "        <setting name=\"*weather\" value=\"nochange\"/>\n";
	print METAFILE "    </settings>\n";
	print METAFILE "</meta>\n";
	close METAFILE;
}

# Copies a gamemode or filterscript from SA-MP to MTA
sub copyAMX {
	my ($name, $src, $dst, $isgamemode) = @_;
	# Create the new source and destination paths
	my $src_amx = $src . $name . ".amx";
	my $dst_amx_dir = $dst . ($isgamemode ? "amx-" : "amx-fs-") . $name;
	my $dst_amx = $dst_amx_dir . "/" . $name . ".amx";
	
	# Create the new directory
	mkdir $dst_amx_dir;
	# Create the meta file
	createMetaFile($name, $dst_amx_dir . "/meta.xml", $isgamemode);
	# Copy the amx file
	fcopy($src_amx, $dst_amx) or print "ERROR: Could not copy '" . $src_amx . "' to '" . $dst_amx . "' !\n";
}

# Gives a list of files to let the user choose from, and calls a callback function for each selected file.
sub copySelection {
	my ($files, $type, $copyfn) = @_;
	my @files = @$files;
	my @copied;
	
	# Let the user choose which files to copy
	my $cnt = 0;
	print "\n> Presenting you with a list of all ${type}s:\n";
	for(@files) {
		printf "    (%d) %s\n", ++$cnt, $_;
	}
	print "\nPlease select the ${type}s which you want to copy. Use * (asterisk) to\n";
	print "copy all available ${type}s or select a series of numbers delimited by\n";
	print "a space.\n";
	while(1) {
		print("\$ ");
		my $inp = <STDIN>;
		chomp($inp);
		my @nums = split(/\s+/, $inp);
		
		# And copy
		if($inp eq "*") {
			# Copy all gamemodes
			print "\n> Copying all ${type}s to MTA:SA DM server.\n";
			&$copyfn($_) for(@files);
			@copied = @files;
			last;
		} elsif (scalar @nums > 0) {
			# Specific selection of gamemodes
			print "\n> Copying " . scalar @nums . " $type" . (@nums == 1 ? "" : "s") . " to MTA:SA DM server.\n";
			foreach (@nums) {
				next if(!/^\d+$/);
				$_ = int($_);
				next if($_ < 1 || $_ > @files);
				push @copied, $files[$_-1];
				&$copyfn($files[$_-1]);
			}
			last;
		} else {
			# Invalid input
		}
	}
	return @copied;
}


# Print logo header
print "  /_\\    /\\/\\ \\ \\/ /      /   \\/ _\\\n";
print " //_\\\\  /    \\ \\  /_____ / /\\ /\\ \\ \n";
print "/  _  \\/ /\\/\\ \\/  \\_____/ /_// _\\ \\\n";
print "\\_/ \\_/\\/    \\/_/\\_\\   /___,'  \\__/\n";
print "          AMX Deployment Suite v1.0\n";
print "          for Multi Theft Auto: San Andreas Deathmatch\n";
print "                                   \n";
print "(C) Multi Theft Auto, 2008		  \n";
print "                                   \n";

# Print welcome screen
print "Welcome to the AMX Deployment Suite.\n";
print "\n";
print "This script is designed for easy replacement of an existing server installation\n";
print "running alternative San Andreas multiplayer modifications that use the PAWN\n";
print "scripting language.\n";
print "\n";
print "The AMX Deployment Suite contains an AMX interpreter that is able to run your\n";
print "AMX gamemodes on a Multi Theft Auto: San Andreas server. This way, you can\n";
print "enjoy your gamemodes in Multi Theft Auto, keep them compatible, without even\n";
print "having to rewrite them in Lua (although recommended).\n";
print "\n";
print "You can use <CTRL>-C to abort the script at any time.\n";
print "\n";
print "Please press <ENTER> to continue.\n";

my $resp = <STDIN>;

print "This script provides you with the following functionality:\n";
print " - Copy any AMX gamemodes, filterscripts and plugins over to a fresh\n";
print "   MTA:SA DM server install.\n";
print " - Copy your existing server configuration over to your freshly installed\n";
print "   MTA:SA DM server.\n";
print " - Provide an option to start your new MTA:SA DM server right away!\n";
print "\n";
print "YOU UNDERSTAND AND AGREE THAT YOUR USE OF THIS SCRIPT IS MADE AVAILABLE AND\n";
print "PROVIDED TO YOU AT YOUR OWN RISK. IT IS PROVIDED TO YOU \"AS IS\" AND WE\n";
print "EXPRESSLY DISCLAIM ALL WARRANTIES OF ANY KIND, IMPLIED OR EXPRESS, INCLUDING\n";
print "BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR\n";
print "PURPOSE, AND NON-INFRINGEMENT.\n";
print "\n";
print "Please type OK and press <ENTER> if you agree.\n";

my $resp = <STDIN>;
chomp($resp);
if(lc($resp) ne "ok") {
	exit;
}

# Get the SA-MP server path
my $oldsrvpath = "";
while(1) {
	print "\n> Please enter your San Andreas Multiplayer server path:\n\$ ";
	$oldsrvpath = <STDIN>;
	chomp($oldsrvpath);
	if(!scanSAMPDir($oldsrvpath)) {
		print "ERROR: Not a valid SA-MP server directory.\n";
	} else {
		print "# Found a valid SA-MP server installation.\n";
		last;
	}
}

# Scan for gamemodes, filterscripts and plugins in the SA-MP server dir
my @gamemodes = scanAMXFiles($oldsrvpath . "/gamemodes");
my @filterscripts = scanAMXFiles($oldsrvpath . "/filterscripts");
my @plugins = scanPlugins($oldsrvpath . "/plugins");

# Get the MTA server path
my $newsrvpath = "";
while(1) {
	print "\n> Please enter your MTA:SA DM server path:\n\$ ";
	$newsrvpath = <STDIN>;
	chomp($newsrvpath);
	if(!scanMTADir($newsrvpath)) {
		print "ERROR: Not a valid MTA:SA DM server directory.\n";
	} else {
		print "# Found a valid MTA server installation.\n";
		last;
	}
}

if(@gamemodes) {
	copySelection(\@gamemodes, "gamemode",
		sub {
			copyAMX($_[0], $oldsrvpath . "/gamemodes/", $newsrvpath . "/mods/deathmatch/resources/", 1);
		}
	);
}
if(@filterscripts) {
	copySelection(\@filterscripts, "filterscript",
		sub {
			copyAMX($_[0], $oldsrvpath . "/filterscripts/", $newsrvpath . "/mods/deathmatch/resources/", 0);
		}
	);
}
if(@plugins) {
	copySelection(\@plugins, "plugin",
		sub {
			my $fname = -e $oldsrvpath . "/plugins/" . $_[0] . ".dll" ? $_[0] . ".dll" : $_[0] . ".so";
			fcopy($oldsrvpath . "/plugins/" . $fname, $newsrvpath . "/mods/deathmatch/resources/" . CONF_RESOURCE_AMX . "/plugins/" . $fname);
		}
	);
}

print "> Copying scriptfiles\n";
dircopy($oldsrvpath . "/scriptfiles/", $newsrvpath . "/mods/deathmatch/resources/amx/scriptfiles");

print "> Configuring\n";

# Read sa-mp config
my %sampcfg;
open SAMPCFG, $oldsrvpath . "/server.cfg";
while(<SAMPCFG>) {
	chomp;
	next if(!/^(\w+) (.+)$/);
	$sampcfg{$1} = $2;
}
close SAMPCFG;

# Read current amx config
my $amxcfgpath = $newsrvpath . "/mods/deathmatch/resources/" . CONF_RESOURCE_AMX . "/meta.xml";
my $amxcfg = new XML::Twig;
if($amxcfg->safe_parsefile($amxcfgpath)) {
	my $settingsNode = $amxcfg->root->child(0, "settings");
	if(!$settingsNode) {
		$settingsNode = XML::Twig::Elt->new("settings");
		$settingsNode->paste("last_child", $amxcfg->root);
	}

	my $filterscriptsNode;
	my $pluginsNode;
	for my $setting ($settingsNode->children("setting")) {
		if($setting->att("name") eq "filterscripts") {
			$filterscriptsNode = $setting;
		} elsif($setting->att("name") eq "plugins") {
			$pluginsNode = $setting;
		}
	}
	if(!$filterscriptsNode) {
		$filterscriptsNode = XML::Twig::Elt->new("setting");
		$filterscriptsNode->set_att("name", "filterscripts");
		$filterscriptsNode->set_att("value", "");
		$filterscriptsNode->paste("last_child", $settingsNode);
	} elsif(!$filterscriptsNode->att("value")) {
		$filterscriptsNode->set_att("value", "");
	}
	if(!$pluginsNode) {
		$pluginsNode = XML::Twig::Elt->new("setting");
		$pluginsNode->set_att("name", "plugins");
		$pluginsNode->set_att("value", "");
		$pluginsNode->paste("last_child", $settingsNode);
	} elsif(!$pluginsNode->att("value")) {
		$pluginsNode->set_att("value", "");
	}

	# Get filterscripts already in amx meta.xml
	my %usedFilterscripts = %{{ map {$_ => 1 if(!/^$/)} split(/\s+/, $filterscriptsNode->att("value")) }};
	# Add filterscripts that are in samp's server.cfg and also exist in MTA
	if($sampcfg{filterscripts}) {
		for(split /\s+/, $sampcfg{filterscripts}) {
			next if(!-e $newsrvpath . "/mods/deathmatch/resources/amx-fs-$_");
			$usedFilterscripts{$_} = 1;
		}
	}

	# Get plugins already in amx meta.xml
	my %usedPlugins = %{{ map {$_ => 1 if(!/^$/)} split(/\s+/, $pluginsNode->att("value")) }};
	# Add plugins that are in samp's server.cfg and also exist in MTA
	if($sampcfg{plugins}) {
		for(split /\s+/, $sampcfg{plugins}) {
			next if(!-e $newsrvpath . "/mods/deathmatch/resources/amx/plugins/$_.dll" && !-e $newsrvpath . "/mods/deathmatch/resources/amx/plugins/$_.so");
			$usedPlugins{$_} = 1;
		}
	}

	# Update in XML tree
	$filterscriptsNode->set_att("value", join ' ', keys %usedFilterscripts);
	$pluginsNode->set_att("value", join ' ', keys %usedPlugins);

	# Save
	$amxcfg->set_pretty_print("indented");
	open AMXCFG, ">", $amxcfgpath;
	print AMXCFG $amxcfg->sprint;
	close AMXCFG;
} else {
	print "WARNING: could not open the amx meta.xml. Please make sure the file exists and contains no syntax errors, then rerun this script.\n";
}

# Configure mapcycler
my $cyclercfgpath = $newsrvpath . "/mods/deathmatch/resources/mapcycler/mapcycle.xml";
my $cyclercfg = new XML::Twig;
if($cyclercfg->safe_parsefile($cyclercfgpath)) {
	for ($cyclercfg->root->children("game")) {
		$_->delete if($_->att("mode") eq "amx");
	}
	for my $i (0..15) {
		$_ = $sampcfg{"gamemode$i"};
		next if(!$_);
		my ($mode, $rounds) = /^(.+?)\s+(\d*)$/;
		next if(!$mode || !-e $newsrvpath . "/mods/deathmatch/resources/amx-$mode");
		my $gameNode = XML::Twig::Elt->new("game");
		$gameNode->set_att("mode", "amx");
		$gameNode->set_att("map", $mode);
		$gameNode->set_att("rounds", $rounds);
		$gameNode->paste("last_child", $cyclercfg->root);
	}
	$cyclercfg->set_pretty_print("indented");
	open CYCLERCFG, ">", $cyclercfgpath;
	print CYCLERCFG $cyclercfg->sprint;
	close CYCLERCFG;
} else {
	print "WARNING: could not open mapcycler/mapcycle.xml. If you want automatic map cycling, ";
	print "please make sure the file exists and contains no syntax errors, then rerun this script.\n";
	print "You may also configure map cycling manually.\n";
}