import os
import shutil
import zipfile
import tempfile
import stat
import time

EXPORT_DIR = "./exported_installer/"

validResourceTypes = {
	"optional" : 1,
	"required" : 1,
	"editor" : 1,
}

folderResources = {
	"amx" : 1
}

#Function to get rid of read-only
#walk the svn checkout directory, looking for .svn dirs
def makeNukeList(dir):
	nukeList = list()
	for root,dirs,files in os.walk(dir):
			if ".svn" in dirs:
					svnPath = os.path.abspath(os.path.join(root,".svn"))
					nukeList.append(svnPath) #add dir to nuke list
					print("Unsetting readonly for %s"%svnPath)
					os.chmod(svnPath,stat.S_IWRITE) #unsets .svn directory readonly
			if ".svn" in root:
					#all files and dirs are inside of .svn dir, unset readonly on everything so I can nuke it
					for file in files:
							filePath = os.path.abspath(os.path.join(root,file))
							print("Unsetting readonly for %s"%filePath)
							os.chmod(filePath,stat.S_IWRITE)
					for dir in dirs:
							dirPath = os.path.abspath(os.path.join(root,dir))
							print("Unsetting readonly for %s"%dirPath)
							os.chmod(dirPath,stat.S_IWRITE)
	return nukeList


if os.path.exists(EXPORT_DIR):
	makeNukeList(EXPORT_DIR)
	shutil.rmtree(EXPORT_DIR)

#Let's create a temp working directory
shutil.copytree("./", EXPORT_DIR)

listnuke = makeNukeList(EXPORT_DIR)

#walking is done, now delete all of the .svn dirs
for dir in listnuke:
		print("Removing %s"%dir)
		shutil.rmtree(dir)
#Delete any files in the root of the dir
for root,dirs,files in os.walk(EXPORT_DIR):
	for file in files:
		os.remove(os.path.abspath(os.path.join(root,file)))
	#Delete any folders that shouldnt be there
	for dir in dirs:
		if not validResourceTypes.has_key(dir):
			shutil.rmtree(os.path.abspath(os.path.join(root,dir)))
	break

time.sleep(2)
#output our zips
for root,dirs,files in os.walk(EXPORT_DIR):
	for resourceDir in dirs:
		for resource in os.listdir( os.path.join(EXPORT_DIR,resourceDir) ):
			if not folderResources.has_key(resource):
				path = os.path.join(EXPORT_DIR,resourceDir, resource)
				print("%s.zip" % (path))
				zip = zipfile.ZipFile("%s.zip" % (path), "w" )
				for root,dirs,files in os.walk( path ):
					for file in files:
						#print ("%s/%s" % (root[(len(resourceDir) + len(resource)) + 2:],file)
						#print ( "%s/%s" % (root[len(path)+1:],file) )
						print ( "%s/%s" % (root,file) )
						
						zip.write (  "%s/%s" % (root,file), "%s/%s" % (root[len(path)+1:],file) )
				zip.close()
				#Now we can delete the corresponding folder
				shutil.rmtree(path)
	break


