// To modify the Host header from Cloudfront to API GW to use the target origin
// instead of Cloudfront url. Otherwise, API GW will return 502 server error.
// Reference:
//   - https://serverfault.com/questions/888714/send-custom-host-header-with-cloudfront
//   - https://serverfault.com/questions/1053906/how-to-whitelist-authorization-header-in-cloudfront-custom-origin-request-policy
'use strict';

exports.handler = (event, context, callback) => {
  const request = event.Records[0].cf.request;

  /* Set host header to API GW domain*/
  request.headers['host'] = [{ key: 'host', value: request.origin.custom.domainName }];
  console.log('successfully executed Lambda at Edge')
  callback(null, request);
};
