/* This script is for updating the cloudformation template for lambda and cloudfront deployment.
 *
 *   1) For the behavior of "/api/*, reconfigure the following options:
 *      - "Allowed HTTP Methods" from "GET" to all HTTP methods
 *      - "Cache Based on Selected Request Headers" from "None" to "All"
 *      - "Query String Forwarding and Caching" from "None" to "Forward all, cache based on all"
 *
 *   2) Create a custom error response for the distribution, setting the response page path for all
 *   403 errors to /surveys/index.html
*/

const fs = require('fs')


// Read the original template
const data = fs.readFileSync(process.env.STACK_TEMPLATE, 'utf8')

try {
    // Create a custom error response
    var template = JSON.parse(data)
    template.Resources.CloudFrontDistribution.Properties.DistributionConfig.CustomErrorResponses = [{
        "ErrorCachingMinTTL" : "300",
        "ErrorCode" : "403",
        "ResponseCode" : "200",
        "ResponsePagePath" : "/surveys/index.html"
    }]

    // Extra all cache behaviors
    var cacheBehaviors = template.Resources.CloudFrontDistribution.Properties.DistributionConfig.CacheBehaviors

    // Update the cache behavior of `/api/*`
    cacheBehaviors.forEach(function(value, index) {
        if (value["PathPattern"] == '/api/*') {
            cacheBehaviors[index]["AllowedMethods"] = [
                "GET",
                "HEAD",
                "OPTIONS",
                "PUT",
                "PATCH",
                "POST",
                "DELETE"
            ]
            cacheBehaviors[index]["ForwardedValues"] = {
                "Headers": ["*"],
                "QueryString": true
            }
            template.Resources.CloudFrontDistribution.Properties.DistributionConfig.CacheBehaviors = cacheBehaviors
            var dataUpdated = JSON.stringify(template, null, 4)
            fs.writeFileSync(process.env.STACK_TEMPLATE_UPDATED, dataUpdated)
        }
    })
} catch(err) {
    console.error(err)
}
