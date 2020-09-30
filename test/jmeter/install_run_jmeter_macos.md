# Install and run jmeter in macos

## Install jmeter

The easiest way to install it is using Homebrew:
```
brew install jmeter
```

Or if you need plugins also:
```
brew install jmeter --with-plugins
```

And to open it, use the following command (since it doesn't appear in your Applications):
```
open /usr/local/bin/jmeter
```


## To install JAVA on macos

Oracle has a poor record for making it easy to install and configure Java, but using Homebrew, the latest OpenJDK (Java 14) can be installed with:
```
brew cask install java
```

For the many use cases depending on an older version (commonly Java 8), the AdoptOpenJDK project makes it possible with an extra step.
```
brew tap adoptopenjdk/openjdk
brew cask install adoptopenjdk8
```

Existing users of Homebrew may encounter Error: Cask adoptopenjdk8 exists in multiple taps due to prior workarounds with different instructions. This can be solved by fully specifying the location with brew cask install adoptopenjdk/openjdk/adoptopenjdk8.


References:
[1] https://stackoverflow.com/questions/22610316/how-do-i-install-jmeter-on-a-mac
[2] https://stackoverflow.com/questions/24342886/how-to-install-java-8-on-mac
