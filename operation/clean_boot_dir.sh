#Your boot partition is full. Since this is a kernel update, these files will be copied to the boot partition so you need to clean in out. Here is a blog post that will show you how to clear the old kernel images with one command. I'll give a basic synopsis of the method. Use this command to print out the current version of your kernel:
#
#uname -r
#
#Then use this command to print out all the kernels you have installed that aren't your newest kernel:
#
#dpkg -l linux-{image,headers}-"[0-9]*" | awk '/^ii/{ print $2}' | grep -v -e `uname -r | cut -f1,2 -d"-"` | grep -e '[0-9]'
#
#Make sure your current kernel isn't on that list. Notice how this is the majority of the final command (down below). To uninstall and delete these old kernels you will want to pipe these arguments to:
#
#sudo apt-get -y purge


dpkg -l linux-{image,headers}-"[0-9]*" | awk '/^ii/{ print $2}' | grep -v -e `uname -r | cut -f1,2 -d"-"` | grep -e '[0-9]' | xargs sudo apt-get -y purge
