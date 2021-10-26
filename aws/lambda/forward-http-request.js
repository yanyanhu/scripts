// Example to forward or redirect http request in AWS lambda
// Reference:
//     https://stackoverflow.com/questions/67639012/forward-requests-to-internal-service-lambda-aws

const https = require('https');


let response = {
    statusCode: 200,
    headers: {'Content-Type': 'application/json'},
    body: ""
}

let requestOptions = {
    timeout: 10,
    host: "HOSTNAME",
    path: "/path",
    method: "GET",
    rejectUnauthorized: false,
    requestCert: true,
}

let request = async (httpOptions, data) => {
    return new Promise((resolve, reject) => {
        let req = https.request(httpOptions, (res) => {
            let body = ''
            res.on('data', (chunk) => { body += chunk })
            res.on('end', () => { resolve(body) })

        })
        req.on('error', (e) => {
                reject(e)
            })
        // req.write(data) // No need for GET request
        req.end()
    })
}

exports.handler = async (event, context) => {
    try {
        let pathArray = event.rawPath.split('/');
        console.log(pathArray)
        if (pathArray[1] == "cms") {
          requestOptions.path = '/' + pathArray[2]
        } else {
          requestOptions.path = event.rawPath
        }
        let result = await request(requestOptions, JSON.stringify({v: 1}))
	// If needed, stringify the result before return
        // response.body = JSON.stringify(result)
        response.body = result
        return response
    } catch (e) {
        response.body = `Internal server error: ${e.code ? e.code : "Unspecified"}`
        return response
    }
}

// Example of simple redirect
// exports.handler = async (event) => {
//     const response = {
//         statusCode: 302,
//         headers: {
//             Location: 'https://HOSTNAME'
//         }
//     };

//     return response;
// };
