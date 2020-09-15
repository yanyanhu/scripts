# How to secure the EBS based service by allowing access from cloudfront only

Let's say your actual site that you want to secure is app.example.com.

It sounds as if you have a CNAME elb.example.com pointing to the assigned hostname of the ELB, which is something like example-123456789.us-west-2.elb.amazonaws.com. If you access either of these hostnames, you're connecting directly to the ELB -- regardless of what's configured in CloudFront or WAF. These machines are still accessible over the Internet.

The trick here is to route the traffic to CloudFront, where it can be firewalled by WAF, which means a couple of additional things have to happen: first, this means an additional hostname is needed, so you configure app.example.com in DNS as a CNAME (or Alias, if you're using Route 53) pointing to the dxxxexample.cloudfront.net hostname assigned to your distribution.

You can also access your sitr using the assigned CloudFront hostname, directly, for testing. Accessing this endpoint from the blocked IP address should indeed result in the request being denied, now.

So, the CloudFront endpoint is where you need to send your traffic -- not directly to the ELB.

Doesn't that leave your ELB still exposed?

Yes, it does... so the next step is to plug that hole.

```
If you're using a custom origin, you can use custom headers to prevent users from bypassing CloudFront and requesting content directly from your origin.

http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/forward-custom-headers.html
```

The idea here is that you will establish a secret value known only to your servers and CloudFront. CloudFront will send this in the headers along with every request, and your servers will require that value to be present or else they will play dumb and throw an error -- such as 503 Service Unavailable or 403 Forbidden or even 404 Not Found.

So, you make up a header name, like X-My-CloudFront-Secret-String and a random string, like o+mJeNieamgKKS0Uu0A1Fqk7sOqa6Mlc3 and configure this as a Custom Origin Header in CloudFront. The values shown here are arbitrary examples -- this can be anything.

Then configure your application web server to deny any request where this header and the matching value are not present -- because this is how you know the request came from your specific CloudFront distribution. Anything else (other than ELB health checks, for which you need to make an exception) is not from your CloudFront distribution, and is therefore unauthorized by definition, so your server needs to deny it with an error, but without explaining too much in the error message.

This header and its expected value remains a secret because it will not be sent back to the browser by CloudFront -- it's only sent in the forward direction, in the requests that CloudFront sends to your ELB.

Note that you should get an SSL cert for your ELB (for the elb.example.com hostname) and configure CloudFront to forward all requests to your ELB using HTTPS. The likelihood of interception of traffic between CloudFront and ELB is low, but this is a protection you should consider implenting.

You can optionally also reduce (but not eliminate) most unauthorized access by blocking all requests that don't arrive from CloudFront by only allowing the CloudFront IP address ranges in the ELB security group -- the CloudFront address ranges are documented (search the JSON for blocks designated as CLOUDFRONT, and allow only these in the ELB security group) but note that if you do this, you still need to set up the custom origin header configuration, discussed above, because if you only block at the IP level, you're still technically allowing anybody's CloudFront distribution to access your ELB. Your CloudFront distribution shares IP addresses in a pool with other CloudFront distribution, so the fact that the request arrives from CloudFront is not a sufficient guarantee that it is from your CloudFront distribution. Note also that you need to sign up for change notifications so that if new address ranges are added to CloudFront, then you'll know to add them to your security group.

References:
[1] https://stackoverflow.com/questions/40642779/how-to-use-aws-waf-with-application-elb/40667492#40667492
