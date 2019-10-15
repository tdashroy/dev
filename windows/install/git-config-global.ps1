# Make line endings checkout Windows-style and commit Unix-style
git config --global core.autocrlf true

# Turn off .orig files after resolving conflicts with git mergetool
git config --global mergetool.keepBackup false
