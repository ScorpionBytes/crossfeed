// Main entrypoint for serverless frontend code.

import serverless from 'serverless-http';
import helmet from 'helmet';
import express from 'express';
import path from 'path';

export const app = express();
app.use(
  helmet({
    strictTransportSecurity: {
      maxAge: 31536000,
      includeSubDomains: true,
      preload: true
    }
  })
);

app.use(
  helmet.contentSecurityPolicy({
    directives: {
      defaultSrc: [
        "'self'",
        'https://cognito-idp.us-gov-west-1.amazonaws.com',
        'https://api.staging.crossfeed.cyber.dhs.gov'
      ],
      scriptSrc: [
        "'self'",
        'https://api.staging.crossfeed.cyber.dhs.gov',
        // Add any other allowed script sources here
        "'unsafe-inline'" // Allow inline scripts (not recommended for security)
      ]
      // Add other directives as needed
    }
  })
);

// app.get('/', (request, response) => {
//   response.send("Hello world " + __dirname + " " + JSON.stringify(getDirectories(path.join(__dirname, '../'))));
// })

app.use(express.static(path.join(__dirname, '../build')));

app.use((req, res) => {
  res.sendFile(path.join(__dirname, '../build/index.html'));
});

export const handler = serverless(app, {
  binary: ['image/*', 'font/*']
});