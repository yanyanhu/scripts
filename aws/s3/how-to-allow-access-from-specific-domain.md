# How to allow access to S3 from specific website/domain only
To create a bucket policy to allow the read (s3:getObject) access to S3 bucket from specific domain(s) only (e.g. https://example.com  and https://www.example.com ), while policy still allow your same account(the one own the bucket) to have the full access.


## Step1
Enable public access of the bucket

## Step2
Apply the following bucket policy:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Allow get requests originating from example.com only if it's not from account owner.",
            "Effect": "Deny",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::bucket/*",
            "Condition": {
                "StringNotLike": {
                    "aws:PrincipalArn": [
                        "arn:aws:iam::ACCOUNT_ID:user/*",
                        "arn:aws:iam::ACCOUNT_ID:role/*"
                    ],
                    "aws:Referer": [
                        "http://example.com/* ",
                        "http://www.example.com/* "
                    ]
                }
            }
        },
        {
            "Sid": "Allow get requests originating from www.example.com and example.com.",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
            ],
            "Resource": "arn:aws:s3:::bucket/*",
            "Condition": {
                "StringLike": {
                    "aws:Referer": [
                        "http://www.example.com/* ",
                        "http://example.com/* "
                    ]
                }
            }
        },
        {
            "Sid": "Allow S3 Access",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::bucket/*",
            "Condition": {
                "StringLike": {
                    "aws:PrincipalArn": [
                        "arn:aws:iam::ACCOUNT_ID:user/*",
                        "arn:aws:iam::ACCOUNT_ID:role/*"
                    ]
                }
            }
        }
    ]
}
```

NOTE: The `aws:Referer` key should be used carefully. It is dangerous to include a publicly known referer header value. Unauthorized parties can use modified or custom browsers to provide any aws:referer value that they choose. As a result, aws:referer should not be used to prevent unauthorized parties from making direct AWS requests. It is offered only to allow customers to protect their digital content, such as content stored in Amazon S3, from being referenced on unauthorized third-party sites. For more information, see aws:referer in the IAM User Guide.

References:

[1] https://stackoverflow.com/questions/65351211/how-to-configure-cors-on-aws-s3/69089544#69089544

[2] https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html#example-bucket-policies-use-case-4
