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
    host: "www.example.com",
    path: "",
    method: "",
    rejectUnauthorized: false,
    requestCert: true,
}

let request = async (httpOptions, postData) => {
    return new Promise((resolve, reject) => {
        let req = https.request(httpOptions, (res) => {
            let body = ''
            res.on('data', (chunk) => { body += chunk })
            res.on('end', () => { resolve(body) })

        })
        req.on('error', (e) => {
                reject(e)
            })
	// No need for GET request
        req.write(postData)
        req.end()
    })
}

exports.handler = async (event, context) => {
    try {
        let pathArray = event.rawPath.split('/');

        let rawPath = ''
        if (pathArray[1] == "path") {
            rawPath = '/' + event.rawPath.split('/').slice(2).join('/')
        } else {
            rawPath = event.rawPath
        }

        if (event.rawQueryString != '') {
            requestOptions.path = rawPath + '?' + event.rawQueryString
        } else {
            requestOptions.path = rawPath
        }

        requestOptions.method = event.requestContext.http.method
        console.log(requestOptions)

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

// //Example of simple redirect
// exports.handler = async (event) => {
//     const response = {
//         statusCode: 302, // also tried 301
//         headers: {
//             Location: 'https://www.example.com'
//         }
//     };

//     return response;
// };
