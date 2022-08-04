'use strict';

// const aws = require('aws-sdk')
const numbers = Array(45).fill(1).map((n, i) => n + i)

function shuffle(array) {
    array.sort(() => Math.random() - 0.5);
}

exports.lambdaHandler = async (event, context, callback) => {
    console.log("Called lambdaHandler: lotto")
    shuffle(numbers);
    shuffle(numbers);
    const target = numbers.slice(0, 6);
    console.log(target)

    var response = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": JSON.stringify(target),
        "isBase64Encoded": false
    };

    callback(null, response);
};
