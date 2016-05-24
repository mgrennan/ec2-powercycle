# EC2-POWERCYCLE

_AWS Lambda function to stop and start EC2 instances based on resource tag using crontab-like expressions_


## Creating resource tag

Lambda function looks for EC2 instances that has resource tag _businessHours_ attached to it.

Tag value is simple JSON document that describes start and stop schedule in [crontab-like expressions](http://en.wikipedia.org/wiki/Cron).

### Example stop/start schedule: Mon - Fri, 8.45am - 5.40pm
```
businessHours: { "start": "45 8 * * 1-5", "stop": "40 17 * * 1-5" }
```
__NOTE__: 

Stopping instances on an hour's mark may result in extra hour to be charged. 
To fully utilise instance hours stop/start schdeule should be set 5 minutes prior to hour's mark.

For example instead of setting schedule  _businessHours: { "start": "0 9 * * 1-5", "stop": "0 17 * * 1-5" }_, 

set it to stop instance 5 minutes earlier _businessHours: { "start": "45 8 * * 1-5", "stop": "40 17 * * 1-5" }_
  

## Creating a Lambda Deployment Package

EC2-POWERCYCLE uses 3rd party library called [Croniter](https://github.com/kiorky/croniter) which must be installed before deployment package is created.

### Installing Croniter into lib/ directory

```
pip install croniter -t lib/
```

### Creating zip archive

The following command is run in the root of the ec2-powercycle repository.
The command bundles ec2-powercycle business logic, its dependencies and the README.md which can be uploaded to Lambda or S3 bucket.   

```
zip -r ../ec2-powercycle-0.0.1.zip ./*.py lib/ README.md
```

## IAM policy

When creating Lambda function you will be asked to associate AIM role with the the function.

### Creating Identity and Access Management (IAM) policy for Lambda function
  
The following policy example enables Lambda function to access the following AWS services:

  * __S3__ - Read access to S3 bucket to deploy new EC2-POWERCYCLE releases
  * __CloudFront__ - Full access to Amazon CloudFront for logging and job scheduling
  * __EC2__ - Access to query status of instances and stop and start them
  
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource": "arn:aws:logs:::*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "ec2:StartInstances",
                "ec2:StopInstances"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "arn:aws:s3:::com.ft.eu-west-1.ec2-powercycle"
        }
    ]
}
```