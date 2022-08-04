# https://gallery.ecr.aws/lambda/nodejs
# https://hub.docker.com/r/amazon/aws-lambda-nodejs
FROM amazon/aws-lambda-nodejs:16

COPY ./nodejs/app.js ./nodejs/package*.json ./

RUN npm install
# If you are building your code for production, instead include a package-lock.json file on this directory and use:
# RUN npm ci --production

# Command can be overwritten by providing a different command in the template directly.
CMD ["app.lambdaHandler"]
