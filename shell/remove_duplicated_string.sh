# Ref: https://unix.stackexchange.com/questions/30173/how-to-remove-duplicate-lines-inside-a-text-file

awk '!seen[$0]++' filename
