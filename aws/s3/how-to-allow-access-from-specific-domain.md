# How to allow access to S3 from specific website/domain only

## Step1
Enable public access of the bucket

## Step2
Apply the following bucket policy which will deny all access besides the ones from given website, e.g. `https://www.example.com` and `https://example.com`:
```
{
    "Version": "2012-10-17",
    "Id": "http referer policy example",
    "Statement": [
        {
            "Sid": "Allow get requests originating from given domain(s).",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::YOUR-BUCKET/*",
            "Condition": {
                "StringNotLike": {
                    "aws:Referer": [
                        "https://www.example.com/*",
                        "https://example.com/*"
                    ]
                }
            }
        }
    ]
}
```

NOTE: This key should be used carefully. It is dangerous to include a publicly known referer header value. Unauthorized parties can use modified or custom browsers to provide any aws:referer value that they choose. As a result, aws:referer should not be used to prevent unauthorized parties from making direct AWS requests. It is offered only to allow customers to protect their digital content, such as content stored in Amazon S3, from being referenced on unauthorized third-party sites. For more information, see aws:referer in the IAM User Guide.

References:
[1] https://stackoverflow.com/questions/65351211/how-to-configure-cors-on-aws-s3/69089544#69089544

[2] https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html#example-bucket-policies-use-case-4
