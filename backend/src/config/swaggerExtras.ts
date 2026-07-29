export const extraSwaggerPaths = {
  '/api/v1/webhooks/stripe': {
    post: {
      summary: 'Stripe Webhook',
      tags: ['Webhooks'],
      description: 'Receives webhook events from Stripe (e.g. payment_intent.succeeded).',
      requestBody: {
        required: true,
        content: {
          'application/json': {
            schema: {
              type: 'object',
              properties: {
                id: { type: 'string' },
                object: { type: 'string' },
                type: { type: 'string' },
                data: { type: 'object' }
              }
            },
            example: {
              id: "evt_3P...",
              object: "event",
              type: "payment_intent.succeeded",
              data: {
                object: {
                  id: "pi_3P...",
                  object: "payment_intent",
                  amount: 10000,
                  currency: "usd",
                  status: "succeeded"
                }
              }
            }
          }
        }
      },
      responses: {
        '200': { description: 'Received' }
      }
    }
  },
  '/api/v1/applications/draft': {
    post: {
      summary: 'Save Application Draft (Step 1-5)',
      tags: ['Applications'],
      security: [{ bearerAuth: [] }],
      requestBody: {
        required: true,
        content: {
          'application/json': {
            schema: {
              type: 'object',
              properties: {
                unitId: { type: 'string', format: 'uuid' },
                propertyId: { type: 'string', format: 'uuid' },
                landlordId: { type: 'string', format: 'uuid' },
                step: { type: 'number', enum: [1, 2, 3, 4, 5] },
                personalInfo: { type: 'object' },
                incomeEmployment: { type: 'object' },
                referencesData: { type: 'array', items: { type: 'object' } },
                documents: { type: 'array', items: { type: 'string' } }
              },
              required: ['unitId', 'propertyId', 'step']
            }
          }
        }
      },
      responses: {
        '200': { description: 'Success' }
      }
    }
  },
  '/api/v1/applications/{id}/submit': {
    post: {
      summary: 'Submit Final Application',
      tags: ['Applications'],
      security: [{ bearerAuth: [] }],
      parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }],
      responses: { '200': { description: 'Success' } }
    }
  },
  '/api/v1/applications/{id}/screening': {
    post: {
      summary: 'Pay $50 Screening Fee',
      tags: ['Applications'],
      security: [{ bearerAuth: [] }],
      parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }],
      requestBody: {
        required: true,
        content: { 'application/json': { schema: { type: 'object', properties: { paymentMethodId: { type: 'string' } }, required: ['paymentMethodId'] } } }
      },
      responses: { '200': { description: 'Success' } }
    }
  },
  '/api/v1/applications/me': {
    get: {
      summary: 'Get My Applications (Tenant)',
      tags: ['Applications'],
      security: [{ bearerAuth: [] }],
      responses: { '200': { description: 'Success' } }
    }
  },
  '/api/v1/applications': {
    get: {
      summary: 'Get Applications on My Properties (Landlord)',
      tags: ['Applications'],
      security: [{ bearerAuth: [] }],
      parameters: [{ name: 'status', in: 'query', required: false, schema: { type: 'string' } }],
      responses: { '200': { description: 'Success' } }
    }
  },
  '/api/v1/applications/{id}/status': {
    patch: {
      summary: 'Update Application Status (Landlord)',
      tags: ['Applications'],
      security: [{ bearerAuth: [] }],
      parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }],
      requestBody: {
        required: true,
        content: {
          'application/json': {
            schema: {
              type: 'object',
              properties: {
                status: { type: 'string', enum: ['approved', 'rejected', 'conditional_approval'] },
                conditionalTerms: {
                  type: 'object',
                  properties: {
                    tags: { type: 'array', items: { type: 'string' } },
                    note: { type: 'string' }
                  }
                }
              },
              required: ['status']
            }
          }
        }
      },
      responses: { '200': { description: 'Success' } }
    }
  },
  '/api/v1/jobs': {
    post: {
      summary: 'Create Job Posting (Landlord)',
      tags: ['Jobs'],
      security: [{ bearerAuth: [] }],
      requestBody: {
        required: true,
        content: {
          'application/json': {
            schema: {
              type: 'object',
              properties: {
                propertyId: { type: 'string', format: 'uuid' },
                title: { type: 'string' },
                category: { type: 'string', enum: ['essential_maintenance', 'turnover_cleaning', 'exterior_seasonal', 'safety_security', 'specialized_services'] },
                subCategory: { type: 'string' },
                urgency: { type: 'string', enum: ['emergency', 'urgent', 'standard'] },
                budgetMin: { type: 'number' },
                budgetMax: { type: 'number' }
              },
              required: ['propertyId', 'title', 'category']
            }
          }
        }
      },
      responses: { '201': { description: 'Created' } }
    },
    get: {
      summary: 'Get My Job Postings (Landlord)',
      tags: ['Jobs'],
      security: [{ bearerAuth: [] }],
      parameters: [{ name: 'status', in: 'query', required: false, schema: { type: 'string' } }],
      responses: { '200': { description: 'Success' } }
    }
  },
  '/api/v1/jobs/{id}/bids': {
    get: {
      summary: 'Get All Bids for Job (Landlord)',
      tags: ['Jobs'],
      security: [{ bearerAuth: [] }],
      parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }],
      responses: { '200': { description: 'Success' } }
    },
    post: {
      summary: 'Submit Bid on Job (Vendor)',
      tags: ['Jobs'],
      security: [{ bearerAuth: [] }],
      parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }],
      requestBody: {
        required: true,
        content: {
          'application/json': {
            schema: {
              type: 'object',
              properties: {
                bidAmount: { type: 'number' },
                proposalNotes: { type: 'string' },
                promotionType: { type: 'string' }
              },
              required: ['bidAmount']
            }
          }
        }
      },
      responses: { '201': { description: 'Created' } }
    }
  },
  '/api/v1/jobs/{id}/bids/{bidId}/accept': {
    patch: {
      summary: 'Accept Bid (Landlord)',
      tags: ['Jobs'],
      security: [{ bearerAuth: [] }],
      parameters: [
        { name: 'id', in: 'path', required: true, schema: { type: 'string' } },
        { name: 'bidId', in: 'path', required: true, schema: { type: 'string' } }
      ],
      responses: { '200': { description: 'Success' } }
    }
  },
  '/api/v1/jobs/open': {
    get: {
      summary: 'Browse Open Jobs (Vendor)',
      tags: ['Jobs'],
      security: [{ bearerAuth: [] }],
      responses: { '200': { description: 'Success' } }
    }
  },
  '/api/v1/vendors/invoices': {
    post: {
      summary: 'Create Invoice (Vendor)',
      tags: ['Vendors'],
      security: [{ bearerAuth: [] }],
      requestBody: {
        required: true,
        content: {
          'application/json': {
            schema: {
              type: 'object',
              properties: {
                propertyId: { type: 'string', format: 'uuid' },
                clientId: { type: 'string', format: 'uuid' },
                clientName: { type: 'string' },
                taxAmount: { type: 'number' },
                items: {
                  type: 'array',
                  items: {
                    type: 'object',
                    properties: { description: { type: 'string' }, quantity: { type: 'number' }, rate: { type: 'number' } },
                    required: ['description', 'quantity', 'rate']
                  }
                }
              },
              required: ['propertyId', 'clientId', 'clientName', 'items']
            }
          }
        }
      },
      responses: { '201': { description: 'Created' } }
    },
    get: {
      summary: 'Get My Invoices (Vendor)',
      tags: ['Vendors'],
      security: [{ bearerAuth: [] }],
      responses: { '200': { description: 'Success' } }
    }
  }
};
