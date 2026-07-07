const swaggerAutogen = require('swagger-autogen')();

const doc = {
  info: {
    title: 'PropAdmin Unified PMOS API',
    description: 'Unified Property Management Operating System API',
    version: '2.0.0'
  },
  host: 'localhost:5000',
  basePath: '/',
  schemes: ['http'],
  securityDefinitions: {
    bearerAuth: {
      type: 'apiKey',
      in: 'header',
      name: 'Authorization',
      description: 'Enter your Bearer token in the format: Bearer <token>'
    }
  },
  paths: {
    '/api/${config.apiVersion}/auth/register': {
      post: {
        summary: 'Register a new user (Signup)',
        description: 'Create a new user profile in the system.',
        parameters: [
          {
            name: 'body',
            in: 'body',
            required: true,
            schema: {
              type: 'object',
              properties: {
                email: { type: 'string', example: 'user@example.com' },
                password: { type: 'string', example: 'Password123!' },
                role: { type: 'string', example: 'tenant' },
                display_name: { type: 'string', example: 'John Doe' }
              },
              required: ['email', 'password', 'role']
            }
          }
        ],
        responses: {
          201: { description: 'Created' },
          400: { description: 'Bad Request' }
        }
      }
    },
    '/api/${config.apiVersion}/auth/login': {
      post: {
        summary: 'User Login',
        description: 'Log in to obtain a JWT token.',
        parameters: [
          {
            name: 'body',
            in: 'body',
            required: true,
            schema: {
              type: 'object',
              properties: {
                email: { type: 'string', example: 'admin@propadmin.io' },
                password: { type: 'string', example: 'Admin@1234' }
              },
              required: ['email', 'password']
            }
          }
        ],
        responses: {
          200: { description: 'OK' },
          400: { description: 'Bad Request' }
        }
      }
    }
  }
};

const outputFile = './swagger-output.json';
const endpointsFiles = ['./src/server.ts'];

const fs = require('fs');

swaggerAutogen(outputFile, endpointsFiles, doc).then(() => {
  console.log('Swagger output generated! Post-processing...');
  let content = fs.readFileSync(outputFile, 'utf8');
  content = content.replace(/\$\{config\.apiVersion\}/g, 'v1');
  
  const swaggerObj = JSON.parse(content);
  if (swaggerObj.paths) {
    for (const pathKey of Object.keys(swaggerObj.paths)) {
      const methods = swaggerObj.paths[pathKey];
      for (const methodKey of Object.keys(methods)) {
        const routeObj = methods[methodKey];
        if (routeObj.parameters) {
          routeObj.parameters = routeObj.parameters.filter(p => p.name !== 'config.apiVersion');
        }
      }
    }
  }
  
  fs.writeFileSync(outputFile, JSON.stringify(swaggerObj, null, 2), 'utf8');
  console.log('Swagger output post-processed and saved!');
  process.exit(0);
}).catch(err => {
  console.error(err);
  process.exit(1);
});
