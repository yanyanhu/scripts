//Simple authorizer based on header check
exports.handler = async(event, context) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    
    let response = {
        "isAuthorized": false,
        "context": {
            "AuthInfo": "defaultdeny"
        }
    };
    if (event.headers.authorized_relay === "secretToken") {
        console.log('AUTH check passed.');
        response = {
            "isAuthorized": true,
            "context": {
                "AuthInfo": "Customer1"
            }
        };
    }
    return response;
};
