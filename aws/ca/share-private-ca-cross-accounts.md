# Share private CA cross accounts

Refer to the following document: https://aws.amazon.com/blogs/security/how-to-use-aws-ram-to-share-your-acm-private-ca-cross-account/


First, create your shared resource in the AWS RAM console. This is completed in the Private CA OWNING account.
- Sign in to the AWS Management Console. For Services, select the Resource Access Manager console.
- In the left-hand pane, choose Resource shares, and then choose Create resource share.
- For Name, enter Shared_Private_CA.
- For Resources, select your ACM Private CA.
- For Principals, select either AWS Organizations or an individual account.
- Choose Create resource share.


Next, accept the shared resource in your shared account. Note: If you choose to share with AWS Organizations, there is no need for the acceptance step. By sharing with an organization or organizational units, all accounts in that container will have access without going through the acceptance step. Accepting a resource share into your account enables you to control which shared resources are displayed in your account when you list resources. You can reject unwanted shares to prevent the system from displaying unwanted resources that are shared from accounts you don’t know or trust.
- In your shared account, sign in to the AWS Management Console. For Services, select the Resource Access Manager console.
- On the left-hand pane, under Shared with me, select Resource shares. (You will see the share invite pending.)
- Select the name of the shared resource, and then choose Accept resource share.
- After the share is accepted, under Resource shares, you will see that the Shared_Private_CA is now listed as Active.
