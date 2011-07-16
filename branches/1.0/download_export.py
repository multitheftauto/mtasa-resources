import os                       #basic file/dir stuff
import shutil           #higher level file operations, used to delete directory trees
import zipfile          #used to create zip files
import stat
import tempfile

EXPORT_DIR = tempfile.mkdtemp() + "/"
TEMP_EXPORT_DIR = EXPORT_DIR + "TEMP_SVN_DIR/"

validResourceTypes = {
	"optional" : 1,
	"required" : 1,
	"editor" : 1,
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


#Let's create a temp working directory
shutil.copytree("./", TEMP_EXPORT_DIR)

listnuke = makeNukeList(TEMP_EXPORT_DIR)

#walking is done, now delete all of the .svn dirs
for dir in listnuke:
		print("Removing %s"%dir)
		shutil.rmtree(dir)
#Delete any files in the root of the dir
for root,dirs,files in os.walk(TEMP_EXPORT_DIR):
	for file in files:
		os.remove(os.path.abspath(os.path.join(root,file)))
	#Delete any folders that shouldnt be there
	for dir in dirs:
		if not validResourceTypes.has_key(dir):
			shutil.rmtree(os.path.abspath(os.path.join(root,dir)))
	break

	
#Grab the SVN revision from a local file
SVNfile = open('.svn\entries', 'r')
svnRevision = SVNfile.readlines()[3][:-1]

# Merge the three root directories into one by moving files/dirs up one directory
for rootDir in os.listdir(TEMP_EXPORT_DIR):
		for subDir in os.listdir(os.path.join(TEMP_EXPORT_DIR,rootDir)):
				# move files to root directory
				srcFile = os.path.join(TEMP_EXPORT_DIR,rootDir,subDir)
				dstFile = os.path.join(EXPORT_DIR,subDir)
				print ( srcFile )
				print ( dstFile )
				os.rename(srcFile,dstFile)
# delete empty temp directory
shutil.rmtree(TEMP_EXPORT_DIR)

zipFileHandle = zipfile.ZipFile("multitheftauto_resources-r%s.zip"%svnRevision,'w', zipfile.ZIP_DEFLATED) #ZIP_DEFLATED means to compress, the alternative is ZIP_STORED
for root,dirs,files in os.walk(EXPORT_DIR):
		for file in files:
				absPathToFile = os.path.join(root,file)
				zipFileHandle.write(absPathToFile,os.path.relpath(absPathToFile,EXPORT_DIR))
zipFileHandle.close()
