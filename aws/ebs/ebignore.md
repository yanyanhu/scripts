# Ignoring files using .ebignore

You can tell the EB CLI to ignore certain files in your project directory by adding the file .ebignore to the directory. This file works like a .gitignore file. When you deploy your project directory to Elastic Beanstalk and create a new application version, the EB CLI doesn't include files specified by .ebignore in the source bundle that it creates.

If .ebignore isn't present, but .gitignore is, the EB CLI ignores files specified in .gitignore. If .ebignore is present, the EB CLI doesn't read .gitignore.

When .ebignore is present, the EB CLI doesn't use git commands to create your source bundle. This means that EB CLI ignores files specified in .ebignore, and includes all other files. In particular, it includes uncommitted source files.
