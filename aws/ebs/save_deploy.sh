## To deploy into AWS Elastic Beanstalk

To save the config of a running environment:
```
$eb config save
```

To export the config of a saved environment to local file:
```
$eb config save CONFIG_FILE --cfg SAVED_CFG_NAME
```

## Create a new environment using a saved config(locally or in S3)
```
$eb create --cfg SAVED_CFG_NAME ENV_NAME
```
Use platform settings from a saved configuration in .elasticbeanstalk/saved_configs/ or your Amazon S3 bucket. Specify the name of the file only, without the .cfg.yml extension.

## Terminate a running environment
```
$eb terminate ENV_NAME
```
