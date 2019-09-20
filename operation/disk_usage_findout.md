This is an answer from askubuntu:
```
https://askubuntu.com/questions/911865/no-more-disk-space-how-can-i-find-what-is-taking-up-the-space
```

Start from root directory:
```
du -cha --max-depth=1 / | grep -E "M|G"
```

The grep is to limit the returning lines to those which return with values in the Megabyte or Gigabyte range. If your disks are big enough, you could add |T as well to include Terabyte amounts. You may get some errors on /proc, /sys, and/or /dev since they are not real files on disk. However, it should still provide valid output for the rest of the directories in root. After you find the biggest ones you can then run the command inside of that directory in order to narrow your way down the culprit. So for example, if /var was the biggest you could do it like this next:

```
du -cha --max-depth=1 /var | grep -E "M|G"
```
