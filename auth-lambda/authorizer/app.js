var jwt = require('jsonwebtoken');

exports.handler = async(event) => {
    let token = event.headers.authorization.split(" ")[1];
  
    try {
      var decoded = jwt.verify(token, 'supersecret')
      console.log("allowed");
      return {
        "principalId": "*",
        "policyDocument": {
          "Version": "2012-10-17",
          "Statement": [{
            "Action": "execute-api:Invoke",
            "Effect": "Allow",
            "Resource": event.routeArn
          }]
        }
      };
    } catch(err) {
      console.log("denied");
      return {
        "principalId": "*",
        "policyDocument": {
          "Version": "2012-10-17",
          "Statement": [{
            "Action": "execute-api:Invoke",
            "Effect": "Deny",
            "Resource": event.routeArn
          }]
        }
      };
    }
  }