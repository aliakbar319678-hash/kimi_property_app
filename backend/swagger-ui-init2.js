
window.onload = function() {
  // Build a system
  var url = window.location.search.match(/url=([^&]+)/);
  if (url && url.length > 1) {
    url = decodeURIComponent(url[1]);
  } else {
    url = window.location.origin;
  }
  var options = {
  "swaggerDoc": {
    "openapi": "3.0.0",
    "info": {
      "title": "PropAdmin API Documentation",
      "version": "2.0.0",
      "description": "Complete REST API for PropAdmin / T&L Property Management Platform — 68 endpoints covering Auth, Properties, Leases, Finance, Maintenance, LMS, Chat, Notifications, Admin, Vendors, Uploads, Discussions, Calendar, AI & Webhooks."
    },
    "servers": [
      {
        "url": "http://localhost:5000",
        "description": "Local Development Server"
      }
    ],
    "components": {
      "securitySchemes": {
        "bearerAuth": {
          "type": "http",
          "scheme": "bearer",
          "bearerFormat": "JWT",
          "description": "Paste your JWT access token here (obtain from POST /api/v1/auth/login)"
        }
      }
    },
    "security": [
      {
        "bearerAuth": []
      }
    ],
    "paths": {
      "/api/v1/webhooks/stripe": {
        "post": {
          "summary": "Handle Stripe webhook events",
          "tags": [
            "Webhooks"
          ],
          "parameters": [
            {
              "in": "header",
              "name": "stripe-signature",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Webhook received"
            }
          }
        }
      },
      "/api/v1/vendors/my-bids": {
        "get": {
          "summary": "Get vendor's bids",
          "tags": [
            "Vendors"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "query",
              "name": "status",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "List of vendor bids"
            }
          }
        }
      },
      "/api/v1/vendors/stats": {
        "get": {
          "summary": "Get vendor statistics",
          "tags": [
            "Vendors"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "responses": {
            "200": {
              "description": "Vendor stats"
            }
          }
        }
      },
      "/api/v1/vendors/jobs": {
        "get": {
          "summary": "Get vendor jobs",
          "tags": [
            "Vendors"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "query",
              "name": "status",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Vendor jobs list"
            }
          }
        }
      },
      "/api/v1/users/me/profile": {
        "put": {
          "summary": "Update current user profile",
          "tags": [
            "Users"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "firstName": {
                      "type": "string"
                    },
                    "lastName": {
                      "type": "string"
                    },
                    "phoneNumber": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Profile updated",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "success": {
                        "type": "boolean",
                        "example": true
                      },
                      "data": {
                        "type": "object"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      "/api/v1/users/me/onboarding/{step}": {
        "post": {
          "summary": "Complete onboarding step",
          "tags": [
            "Users"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "step",
              "required": true,
              "schema": {
                "type": "integer"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "data": {
                      "type": "object"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Onboarding step saved"
            }
          }
        }
      },
      "/api/v1/users/me/documents": {
        "post": {
          "summary": "Upload user document",
          "tags": [
            "Users"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "docType": {
                      "type": "string"
                    },
                    "fileUrl": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Document uploaded"
            }
          }
        }
      },
      "/api/v1/users/{id}/roles": {
        "get": {
          "summary": "Get user roles",
          "tags": [
            "Users"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "List of roles"
            }
          }
        },
        "post": {
          "summary": "Add role to user",
          "tags": [
            "Users"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "role": {
                      "type": "string"
                    },
                    "entityId": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Role added"
            }
          }
        }
      },
      "/api/v1/uploads/property/{id}/image": {
        "post": {
          "summary": "Upload property image",
          "tags": [
            "Uploads"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "multipart/form-data": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "file": {
                      "type": "string",
                      "format": "binary"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Image uploaded"
            }
          }
        }
      },
      "/api/v1/uploads/work-order/{id}/photo": {
        "post": {
          "summary": "Upload work order photo",
          "tags": [
            "Uploads"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "multipart/form-data": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "file": {
                      "type": "string",
                      "format": "binary"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Photo uploaded"
            }
          }
        }
      },
      "/api/v1/uploads/kyc/{docType}": {
        "post": {
          "summary": "Upload KYC document",
          "tags": [
            "Uploads"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "docType",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "multipart/form-data": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "file": {
                      "type": "string",
                      "format": "binary"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Document uploaded"
            }
          }
        }
      },
      "/api/v1/properties": {
        "post": {
          "summary": "Create a new property",
          "tags": [
            "Properties"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "title",
                    "address",
                    "type"
                  ],
                  "properties": {
                    "title": {
                      "type": "string",
                      "example": "Luxury Apartment"
                    },
                    "description": {
                      "type": "string",
                      "example": "A beautiful apartment in the city center"
                    },
                    "address": {
                      "type": "string",
                      "example": "123 Main St, New York, NY 10001"
                    },
                    "type": {
                      "type": "string",
                      "example": "apartment"
                    },
                    "price": {
                      "type": "number",
                      "example": 2500
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Property created successfully",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "success": {
                        "type": "boolean",
                        "example": true
                      },
                      "data": {
                        "type": "object",
                        "properties": {
                          "id": {
                            "type": "string"
                          },
                          "title": {
                            "type": "string"
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      "/api/v1/properties/search": {
        "get": {
          "summary": "Search for properties",
          "tags": [
            "Properties"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "q",
              "schema": {
                "type": "string"
              },
              "description": "Search query"
            },
            {
              "in": "query",
              "name": "type",
              "schema": {
                "type": "string"
              },
              "description": "Property type"
            },
            {
              "in": "query",
              "name": "minPrice",
              "schema": {
                "type": "number"
              }
            },
            {
              "in": "query",
              "name": "maxPrice",
              "schema": {
                "type": "number"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Search results",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "success": {
                        "type": "boolean",
                        "example": true
                      },
                      "data": {
                        "type": "array",
                        "items": {
                          "type": "object"
                        }
                      },
                      "total": {
                        "type": "number"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      "/api/v1/properties/{id}": {
        "get": {
          "summary": "Get a property by ID",
          "tags": [
            "Properties"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "Property ID"
            }
          ],
          "responses": {
            "200": {
              "description": "Property details",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "success": {
                        "type": "boolean",
                        "example": true
                      },
                      "data": {
                        "type": "object"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      "/api/v1/properties/{id}/units": {
        "post": {
          "summary": "Create a unit within a property",
          "tags": [
            "Properties"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "Property ID"
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "unitNumber",
                    "price"
                  ],
                  "properties": {
                    "unitNumber": {
                      "type": "string"
                    },
                    "price": {
                      "type": "number"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Unit created"
            }
          }
        }
      },
      "/api/v1/properties/{id}/save": {
        "post": {
          "summary": "Save a property for a tenant",
          "tags": [
            "Properties"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "Property ID"
            }
          ],
          "responses": {
            "200": {
              "description": "Property saved successfully"
            }
          }
        }
      },
      "/api/v1/properties/saved/me": {
        "get": {
          "summary": "Get user's saved properties",
          "tags": [
            "Properties"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "responses": {
            "200": {
              "description": "List of saved properties"
            }
          }
        }
      },
      "/api/v1/notifications": {
        "get": {
          "summary": "Get all notifications",
          "tags": [
            "Notifications"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "query",
              "name": "page",
              "schema": {
                "type": "integer"
              }
            },
            {
              "in": "query",
              "name": "limit",
              "schema": {
                "type": "integer"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "List of notifications"
            }
          }
        }
      },
      "/api/v1/notifications/unread": {
        "get": {
          "summary": "Get unread notifications",
          "tags": [
            "Notifications"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "responses": {
            "200": {
              "description": "List of unread notifications"
            }
          }
        }
      },
      "/api/v1/notifications/unread-count": {
        "get": {
          "summary": "Get unread notifications count",
          "tags": [
            "Notifications"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "responses": {
            "200": {
              "description": "Unread count"
            }
          }
        }
      },
      "/api/v1/notifications/{id}/read": {
        "put": {
          "summary": "Mark notification as read",
          "tags": [
            "Notifications"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Notification marked as read"
            }
          }
        }
      },
      "/api/v1/notifications/read-all": {
        "put": {
          "summary": "Mark all notifications as read",
          "tags": [
            "Notifications"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "responses": {
            "200": {
              "description": "All notifications marked as read"
            }
          }
        }
      },
      "/api/v1/maintenance/work-orders": {
        "post": {
          "summary": "Create a new work order",
          "tags": [
            "Maintenance"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "propertyId",
                    "title",
                    "description",
                    "category",
                    "priority"
                  ],
                  "properties": {
                    "propertyId": {
                      "type": "string"
                    },
                    "unitId": {
                      "type": "string"
                    },
                    "title": {
                      "type": "string"
                    },
                    "description": {
                      "type": "string"
                    },
                    "category": {
                      "type": "string",
                      "example": "plumbing"
                    },
                    "priority": {
                      "type": "string",
                      "example": "high"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Work order created"
            }
          }
        },
        "get": {
          "summary": "Get work orders",
          "tags": [
            "Maintenance"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "query",
              "name": "status",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "List of work orders"
            }
          }
        }
      },
      "/api/v1/maintenance/work-orders/{id}": {
        "get": {
          "summary": "Get work order by ID",
          "tags": [
            "Maintenance"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Work order details"
            }
          }
        }
      },
      "/api/v1/maintenance/work-orders/{id}/bids": {
        "post": {
          "summary": "Submit a bid for a work order",
          "tags": [
            "Maintenance"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "amount",
                    "estimatedDays",
                    "proposal"
                  ],
                  "properties": {
                    "amount": {
                      "type": "number"
                    },
                    "estimatedDays": {
                      "type": "number"
                    },
                    "proposal": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Bid submitted"
            }
          }
        }
      },
      "/api/v1/maintenance/bids/{id}/accept": {
        "post": {
          "summary": "Accept a vendor bid",
          "tags": [
            "Maintenance"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Bid accepted"
            }
          }
        }
      },
      "/api/v1/maintenance/work-orders/{id}/status": {
        "put": {
          "summary": "Update work order status",
          "tags": [
            "Maintenance"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "status"
                  ],
                  "properties": {
                    "status": {
                      "type": "string",
                      "enum": [
                        "open",
                        "assigned",
                        "in_progress",
                        "completed",
                        "cancelled"
                      ]
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Status updated"
            }
          }
        }
      },
      "/api/v1/maintenance/vendor/jobs": {
        "get": {
          "summary": "Get jobs assigned to vendor",
          "tags": [
            "Maintenance"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "query",
              "name": "status",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "List of vendor jobs"
            }
          }
        }
      },
      "/api/v1/lms/courses": {
        "get": {
          "summary": "Get all courses",
          "tags": [
            "LMS"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "query",
              "name": "category",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "List of courses"
            }
          }
        }
      },
      "/api/v1/lms/courses/{id}": {
        "get": {
          "summary": "Get course by ID",
          "tags": [
            "LMS"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Course details"
            }
          }
        }
      },
      "/api/v1/lms/courses/{id}/enroll": {
        "post": {
          "summary": "Enroll in a course",
          "tags": [
            "LMS"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "201": {
              "description": "Enrolled successfully"
            }
          }
        }
      },
      "/api/v1/lms/enrollments/{id}/progress": {
        "put": {
          "summary": "Update course progress",
          "tags": [
            "LMS"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "progressPercent": {
                      "type": "number"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Progress updated"
            }
          }
        }
      },
      "/api/v1/lms/modules/{id}/quiz": {
        "get": {
          "summary": "Get module quiz",
          "tags": [
            "LMS"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Quiz details"
            }
          }
        }
      },
      "/api/v1/lms/enrollments/{id}/quiz": {
        "post": {
          "summary": "Submit quiz answers",
          "tags": [
            "LMS"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "moduleId": {
                      "type": "string"
                    },
                    "answers": {
                      "type": "array",
                      "items": {
                        "type": "object"
                      }
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Quiz graded"
            }
          }
        }
      },
      "/api/v1/lms/certificates": {
        "get": {
          "summary": "Get user certificates",
          "tags": [
            "LMS"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "responses": {
            "200": {
              "description": "List of certificates"
            }
          }
        }
      },
      "/api/v1/lms/enrollments/{id}/certificate": {
        "post": {
          "summary": "Issue certificate for completed course",
          "tags": [
            "LMS"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "201": {
              "description": "Certificate issued"
            }
          }
        }
      },
      "/api/v1/lms/certificates/{number}/verify": {
        "get": {
          "summary": "Verify a certificate",
          "tags": [
            "LMS"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "number",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Certificate verification status"
            }
          }
        }
      },
      "/api/v1/lms/dashboard": {
        "get": {
          "summary": "Get LMS dashboard",
          "tags": [
            "LMS"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "responses": {
            "200": {
              "description": "Dashboard stats"
            }
          }
        }
      },
      "/api/v1/leases": {
        "post": {
          "summary": "Create a new lease",
          "tags": [
            "Leases"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "propertyId",
                    "unitId",
                    "tenantId",
                    "startDate",
                    "endDate",
                    "rentAmount",
                    "securityDeposit"
                  ],
                  "properties": {
                    "propertyId": {
                      "type": "string"
                    },
                    "unitId": {
                      "type": "string"
                    },
                    "tenantId": {
                      "type": "string"
                    },
                    "startDate": {
                      "type": "string",
                      "format": "date"
                    },
                    "endDate": {
                      "type": "string",
                      "format": "date"
                    },
                    "rentAmount": {
                      "type": "number"
                    },
                    "securityDeposit": {
                      "type": "number"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Lease created successfully",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "success": {
                        "type": "boolean",
                        "example": true
                      },
                      "data": {
                        "type": "object"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      "/api/v1/leases/dashboard": {
        "get": {
          "summary": "Get leases dashboard",
          "tags": [
            "Leases"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "responses": {
            "200": {
              "description": "Dashboard statistics and active leases",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "success": {
                        "type": "boolean",
                        "example": true
                      },
                      "data": {
                        "type": "array",
                        "items": {
                          "type": "object"
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      "/api/v1/leases/expiring-soon": {
        "get": {
          "summary": "Get leases expiring soon",
          "tags": [
            "Leases"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "responses": {
            "200": {
              "description": "List of leases expiring in the next 30/60 days",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "success": {
                        "type": "boolean",
                        "example": true
                      },
                      "data": {
                        "type": "array",
                        "items": {
                          "type": "object"
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      "/api/v1/leases/{id}/renew": {
        "post": {
          "summary": "Renew a lease",
          "tags": [
            "Leases"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "Lease ID"
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "newEndDate"
                  ],
                  "properties": {
                    "newEndDate": {
                      "type": "string",
                      "format": "date"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Lease renewed successfully"
            }
          }
        }
      },
      "/api/v1/finance/dashboard": {
        "get": {
          "summary": "Get finance dashboard statistics",
          "tags": [
            "Finance"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "query",
              "name": "period",
              "schema": {
                "type": "string",
                "enum": [
                  "daily",
                  "weekly",
                  "monthly",
                  "yearly"
                ]
              },
              "description": "Time period for statistics"
            }
          ],
          "responses": {
            "200": {
              "description": "Finance statistics",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "success": {
                        "type": "boolean",
                        "example": true
                      },
                      "data": {
                        "type": "object"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      "/api/v1/finance/payments/initiate": {
        "post": {
          "summary": "Initiate a rent or fee payment",
          "tags": [
            "Finance"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "leaseId",
                    "amount",
                    "paymentMethod"
                  ],
                  "properties": {
                    "leaseId": {
                      "type": "string"
                    },
                    "amount": {
                      "type": "number"
                    },
                    "paymentMethod": {
                      "type": "string",
                      "example": "card"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Payment initiated successfully",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "success": {
                        "type": "boolean",
                        "example": true
                      },
                      "data": {
                        "type": "object",
                        "properties": {
                          "paymentIntentId": {
                            "type": "string"
                          },
                          "clientSecret": {
                            "type": "string"
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      "/api/v1/finance/vendor/earnings": {
        "get": {
          "summary": "Get vendor earnings and transaction history",
          "tags": [
            "Finance"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "responses": {
            "200": {
              "description": "Vendor earnings data",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "success": {
                        "type": "boolean",
                        "example": true
                      },
                      "data": {
                        "type": "object",
                        "properties": {
                          "totalEarnings": {
                            "type": "number"
                          },
                          "pendingPayments": {
                            "type": "number"
                          },
                          "history": {
                            "type": "array",
                            "items": {
                              "type": "object"
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      "/api/v1/finance/invoices": {
        "post": {
          "summary": "Generate a vendor invoice for a work order",
          "tags": [
            "Finance"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "workOrderId",
                    "items"
                  ],
                  "properties": {
                    "workOrderId": {
                      "type": "string"
                    },
                    "items": {
                      "type": "array",
                      "items": {
                        "type": "object",
                        "properties": {
                          "description": {
                            "type": "string"
                          },
                          "amount": {
                            "type": "number"
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Invoice generated"
            }
          }
        }
      },
      "/api/v1/discussions": {
        "post": {
          "summary": "Create a new discussion",
          "tags": [
            "Discussions"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "title",
                    "content",
                    "tags"
                  ],
                  "properties": {
                    "title": {
                      "type": "string"
                    },
                    "content": {
                      "type": "string"
                    },
                    "tags": {
                      "type": "array",
                      "items": {
                        "type": "string"
                      }
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Discussion created"
            }
          }
        },
        "get": {
          "summary": "List all discussions",
          "tags": [
            "Discussions"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "query",
              "name": "tags",
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "sortBy",
              "schema": {
                "type": "string",
                "enum": [
                  "recent",
                  "popular"
                ]
              }
            }
          ],
          "responses": {
            "200": {
              "description": "List of discussions"
            }
          }
        }
      },
      "/api/v1/discussions/{id}": {
        "get": {
          "summary": "Get discussion by ID",
          "tags": [
            "Discussions"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Discussion details"
            }
          }
        }
      },
      "/api/v1/discussions/{id}/replies": {
        "post": {
          "summary": "Add a reply to a discussion",
          "tags": [
            "Discussions"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "content"
                  ],
                  "properties": {
                    "content": {
                      "type": "string"
                    },
                    "parentId": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Reply added"
            }
          }
        }
      },
      "/api/v1/discussions/replies/{id}/upvote": {
        "post": {
          "summary": "Upvote a reply",
          "tags": [
            "Discussions"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Reply upvoted"
            }
          }
        }
      },
      "/api/v1/chat/rooms": {
        "post": {
          "summary": "Create a chat room",
          "tags": [
            "Chat"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "name",
                    "participants",
                    "contextType",
                    "contextId"
                  ],
                  "properties": {
                    "name": {
                      "type": "string"
                    },
                    "participants": {
                      "type": "array",
                      "items": {
                        "type": "string"
                      }
                    },
                    "contextType": {
                      "type": "string"
                    },
                    "contextId": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Chat room created"
            }
          }
        },
        "get": {
          "summary": "Get all chat rooms for user",
          "tags": [
            "Chat"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "responses": {
            "200": {
              "description": "List of chat rooms"
            }
          }
        }
      },
      "/api/v1/chat/rooms/{id}/messages": {
        "get": {
          "summary": "Get messages in a room",
          "tags": [
            "Chat"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "page",
              "schema": {
                "type": "integer"
              }
            },
            {
              "in": "query",
              "name": "limit",
              "schema": {
                "type": "integer"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "List of messages"
            }
          }
        },
        "post": {
          "summary": "Send a message to a room",
          "tags": [
            "Chat"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "content"
                  ],
                  "properties": {
                    "content": {
                      "type": "string"
                    },
                    "attachments": {
                      "type": "array",
                      "items": {
                        "type": "object"
                      }
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Message sent"
            }
          }
        }
      },
      "/api/v1/chat/rooms/{id}/read": {
        "put": {
          "summary": "Mark messages as read",
          "tags": [
            "Chat"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Messages marked as read"
            }
          }
        }
      },
      "/api/v1/calendar/events": {
        "post": {
          "summary": "Create a calendar event",
          "tags": [
            "Calendar"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "title": {
                      "type": "string"
                    },
                    "startTime": {
                      "type": "string",
                      "format": "date-time"
                    },
                    "endTime": {
                      "type": "string",
                      "format": "date-time"
                    },
                    "description": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Event created"
            }
          }
        }
      },
      "/api/v1/calendar/google-link": {
        "post": {
          "summary": "Generate Google Calendar integration link",
          "tags": [
            "Calendar"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "title": {
                      "type": "string"
                    },
                    "startTime": {
                      "type": "string",
                      "format": "date-time"
                    },
                    "endTime": {
                      "type": "string",
                      "format": "date-time"
                    },
                    "description": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Generated link"
            }
          }
        }
      },
      "/api/v1/auth/register": {
        "post": {
          "summary": "Register a new user",
          "tags": [
            "Auth"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "email",
                    "password",
                    "firstName",
                    "lastName"
                  ],
                  "properties": {
                    "email": {
                      "type": "string",
                      "example": "user@example.com"
                    },
                    "password": {
                      "type": "string",
                      "example": "StrongPass123!"
                    },
                    "firstName": {
                      "type": "string",
                      "example": "John"
                    },
                    "lastName": {
                      "type": "string",
                      "example": "Doe"
                    },
                    "roles": {
                      "type": "array",
                      "items": {
                        "type": "string"
                      },
                      "example": [
                        "tenant"
                      ]
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Successfully registered",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "success": {
                        "type": "boolean",
                        "example": true
                      },
                      "data": {
                        "type": "object",
                        "properties": {
                          "id": {
                            "type": "string",
                            "example": "123e4567-e89b-12d3-a456-426614174000"
                          },
                          "email": {
                            "type": "string",
                            "example": "user@example.com"
                          },
                          "firstName": {
                            "type": "string",
                            "example": "John"
                          },
                          "lastName": {
                            "type": "string",
                            "example": "Doe"
                          },
                          "roles": {
                            "type": "array",
                            "items": {
                              "type": "string"
                            },
                            "example": [
                              "tenant"
                            ]
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      "/api/v1/auth/login": {
        "post": {
          "summary": "Login a user",
          "tags": [
            "Auth"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "email",
                    "password"
                  ],
                  "properties": {
                    "email": {
                      "type": "string",
                      "example": "landlord@example.com"
                    },
                    "password": {
                      "type": "string",
                      "example": "Admin123!"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Successfully logged in",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "success": {
                        "type": "boolean",
                        "example": true
                      },
                      "data": {
                        "type": "object",
                        "properties": {
                          "accessToken": {
                            "type": "string",
                            "example": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
                          },
                          "refreshToken": {
                            "type": "string",
                            "example": "def502005a3971936c..."
                          },
                          "user": {
                            "type": "object",
                            "properties": {
                              "id": {
                                "type": "string",
                                "example": "uuid"
                              },
                              "email": {
                                "type": "string",
                                "example": "landlord@example.com"
                              },
                              "roles": {
                                "type": "array",
                                "items": {
                                  "type": "string"
                                },
                                "example": [
                                  "landlord"
                                ]
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      "/api/v1/auth/refresh": {
        "post": {
          "summary": "Refresh access token",
          "tags": [
            "Auth"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "refreshToken"
                  ],
                  "properties": {
                    "refreshToken": {
                      "type": "string",
                      "example": "your-refresh-token-here"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "New tokens generated",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "success": {
                        "type": "boolean",
                        "example": true
                      },
                      "data": {
                        "type": "object",
                        "properties": {
                          "accessToken": {
                            "type": "string"
                          },
                          "refreshToken": {
                            "type": "string"
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      "/api/v1/auth/me": {
        "get": {
          "summary": "Get current authenticated user details",
          "tags": [
            "Auth"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "responses": {
            "200": {
              "description": "Current user details",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "success": {
                        "type": "boolean",
                        "example": true
                      },
                      "data": {
                        "type": "object",
                        "properties": {
                          "id": {
                            "type": "string",
                            "example": "uuid"
                          },
                          "email": {
                            "type": "string",
                            "example": "admin@propadmin.io"
                          },
                          "firstName": {
                            "type": "string",
                            "example": "Admin"
                          },
                          "lastName": {
                            "type": "string",
                            "example": "User"
                          },
                          "roles": {
                            "type": "array",
                            "items": {
                              "type": "string"
                            },
                            "example": [
                              "super_admin"
                            ]
                          },
                          "createdAt": {
                            "type": "string",
                            "format": "date-time"
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      "/api/v1/ai/chat": {
        "post": {
          "summary": "Chat with AI assistant",
          "tags": [
            "AI Assistant"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "message"
                  ],
                  "properties": {
                    "message": {
                      "type": "string"
                    },
                    "propertyId": {
                      "type": "string"
                    },
                    "leaseId": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "AI response"
            }
          }
        }
      },
      "/api/v1/admin/dashboard": {
        "get": {
          "summary": "Get admin dashboard statistics",
          "tags": [
            "Admin"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "responses": {
            "200": {
              "description": "Dashboard stats"
            }
          }
        }
      },
      "/api/v1/admin/audit-logs": {
        "get": {
          "summary": "Get system audit logs",
          "tags": [
            "Admin"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "query",
              "name": "page",
              "schema": {
                "type": "integer"
              }
            },
            {
              "in": "query",
              "name": "limit",
              "schema": {
                "type": "integer"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "List of audit logs"
            }
          }
        }
      },
      "/api/v1/admin/verification-queue": {
        "get": {
          "summary": "Get user verification queue",
          "tags": [
            "Admin"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "query",
              "name": "status",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Verification queue"
            }
          }
        }
      },
      "/api/v1/admin/verification-queue/{id}/approve": {
        "post": {
          "summary": "Approve a verification request",
          "tags": [
            "Admin"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "notes": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Approved successfully"
            }
          }
        }
      },
      "/api/v1/admin/verification-queue/{id}/reject": {
        "post": {
          "summary": "Reject a verification request",
          "tags": [
            "Admin"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "notes": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Rejected successfully"
            }
          }
        }
      },
      "/api/v1/admin/users/{id}/suspend": {
        "put": {
          "summary": "Suspend a user",
          "tags": [
            "Admin"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "reason": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "User suspended"
            }
          }
        }
      },
      "/api/v1/admin/system-health": {
        "get": {
          "summary": "Get detailed system health metrics",
          "tags": [
            "Admin"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "responses": {
            "200": {
              "description": "System health details"
            }
          }
        }
      },
      "/health": {
        "get": {
          "summary": "System health check",
          "tags": [
            "System"
          ],
          "responses": {
            "200": {
              "description": "System is healthy",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "status": {
                        "type": "string",
                        "example": "ok"
                      },
                      "timestamp": {
                        "type": "string",
                        "format": "date-time"
                      }
                    }
                  }
                }
              }
            },
            "503": {
              "description": "Database unavailable"
            }
          }
        }
      }
    },
    "tags": [
      {
        "name": "Webhooks",
        "description": "Third-party webhook handlers (Stripe, etc.)"
      },
      {
        "name": "Vendors",
        "description": "Vendor specific endpoints (Bids, Stats, Jobs)"
      },
      {
        "name": "Users",
        "description": "User profile and role management"
      },
      {
        "name": "Uploads",
        "description": "File upload endpoints"
      },
      {
        "name": "Properties",
        "description": "Property management endpoints"
      },
      {
        "name": "Notifications",
        "description": "User notifications"
      },
      {
        "name": "Maintenance",
        "description": "Maintenance work orders and bids"
      },
      {
        "name": "LMS",
        "description": "Learning Management System (Courses & Certificates)"
      },
      {
        "name": "Leases",
        "description": "Lease management endpoints"
      },
      {
        "name": "Finance",
        "description": "Finance and payment management endpoints"
      },
      {
        "name": "Discussions",
        "description": "Community forums and discussions"
      },
      {
        "name": "Chat",
        "description": "Real-time messaging and chat rooms"
      },
      {
        "name": "Calendar",
        "description": "Calendar events and integrations"
      },
      {
        "name": "Auth",
        "description": "Authentication endpoints"
      },
      {
        "name": "AI Assistant",
        "description": "AI property management assistant"
      },
      {
        "name": "Admin",
        "description": "System administration and moderation"
      },
      {
        "name": "System",
        "description": "System health and status endpoints"
      }
    ]
  },
  "customOptions": {}
};
  url = options.swaggerUrl || url
  var urls = options.swaggerUrls
  var customOptions = options.customOptions
  var spec1 = options.swaggerDoc
  var swaggerOptions = {
    spec: spec1,
    url: url,
    urls: urls,
    dom_id: '#swagger-ui',
    deepLinking: true,
    presets: [
      SwaggerUIBundle.presets.apis,
      SwaggerUIStandalonePreset
    ],
    plugins: [
      SwaggerUIBundle.plugins.DownloadUrl
    ],
    layout: "StandaloneLayout"
  }
  for (var attrname in customOptions) {
    swaggerOptions[attrname] = customOptions[attrname];
  }
  var ui = SwaggerUIBundle(swaggerOptions)

  if (customOptions.oauth) {
    ui.initOAuth(customOptions.oauth)
  }

  if (customOptions.preauthorizeApiKey) {
    const key = customOptions.preauthorizeApiKey.authDefinitionKey;
    const value = customOptions.preauthorizeApiKey.apiKeyValue;
    if (!!key && !!value) {
      const pid = setInterval(() => {
        const authorized = ui.preauthorizeApiKey(key, value);
        if(!!authorized) clearInterval(pid);
      }, 500)

    }
  }

  if (customOptions.authAction) {
    ui.authActions.authorize(customOptions.authAction)
  }

  window.ui = ui
}
