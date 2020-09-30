# Install and Run Jmeter in Linux

## Install Java
Install Java first, e.g. run
```
sudo yum install -y java
```

## Download Jmeter
Download jmeter from the following page:
```
http://jmeter.apache.org/download_jmeter.cgi
```

## Unzip Jmeter package
Unzip the downloaded package.


## Run jmeter using the binary
Go to the bin folder and run jmeter using the binary directly, e.g.
```
$ cd ./apache-jmeter-5.3/bin
$ jmeter -n -t my-test-plan.jmx -l my-test-plan-jmeteroutput.csv
```

Note: the test plan can be created and exported in gui mode in macos or windows.
