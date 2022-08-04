'use strict';

// const aws = require('aws-sdk')

function shuffle(array) {
    array.sort(() => Math.random() - 0.5);
}

exports.lambdaHandler = async (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log("Called lambdaHandler: lotto")
    const numbers = Array(45).fill(1).map((n, i) => n + i)
    shuffle(numbers);
    shuffle(numbers);
    const result = numbers.slice(0, 6);
    console.log('result:', result)

    var response = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": JSON.stringify(result),
        "isBase64Encoded": false
    };

    callback(null, response);
};
