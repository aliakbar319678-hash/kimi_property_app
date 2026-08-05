import Joi from 'joi';

export const schemas = {
  login: Joi.object({
    email: Joi.string().required(), // removed .email() to allow identifier
    password: Joi.string().min(8).required(),
    username: Joi.string().optional(),
    full_name: Joi.string().optional(),
    phone: Joi.string().optional(),
    deviceId: Joi.string().optional(),
    deviceType: Joi.string().valid('ios', 'android', 'web').optional(),
  }),

  register: Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().min(6).required(),
    phone: Joi.string().optional(),
    username: Joi.string().optional(),
    role: Joi.string().valid('tenant', 'landlord', 'vendor', 'admin', 'property_manager').required(),
    regionCode: Joi.string().optional(),
    display_name: Joi.string().optional(),
    first_name: Joi.string().optional(),
    last_name: Joi.string().optional(),
    avatar_url: Joi.string().optional(),
  }),

  usAddress: Joi.object({
    addressLine1: Joi.string().required(),
    addressLine2: Joi.string().optional(),
    city: Joi.string().required(),
    stateProvince: Joi.string().length(2).uppercase().required(), // CA, NY, etc.
    postalCode: Joi.string().pattern(/^\d{5}(-\d{4})?$/).required(), // 12345 or 12345-6789
    countryCode: Joi.string().valid('US').required()
  }),

  caAddress: Joi.object({
    addressLine1: Joi.string().required(),
    addressLine2: Joi.string().optional(),
    city: Joi.string().required(),
    stateProvince: Joi.string().length(2).uppercase().required(), // ON, BC, etc.
    postalCode: Joi.string().pattern(/^[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d$/).required(), // A1A 1A1
    countryCode: Joi.string().valid('CA').required()
  }),

  onboardingStep: Joi.object({
    step: Joi.number().integer().min(1).max(5).required(),
    data: Joi.object({
      legalName: Joi.string().optional(),
      dob: Joi.date().iso().optional(),
      phone: Joi.string().pattern(/^\+1\d{10}$/).message('Phone must be in E.164 format for US/CA (+1...)').optional(),
      employment: Joi.object().optional(),
      documents: Joi.array().items(Joi.object({
        type: Joi.string().valid('passport', 'drivers_license', 'state_id', 'proof_of_income').required(),
        url: Joi.string().uri().required()
      })).optional(),
      preferences: Joi.object().optional(),
      ssn_sin_last4: Joi.string().pattern(/^\d{4}$/).optional(),
      tax_identifier: Joi.string().optional(), // In real scenario, encrypted by frontend or handled via 3rd party
      current_address: Joi.alternatives().try(Joi.link('#usAddress'), Joi.link('#caAddress')).optional()
    }).required(),
  }),

  propertyCreate: Joi.object({
    name: Joi.string().min(3).max(255).required(),
    addressLine1: Joi.string().required(),
    city: Joi.string().required(),
    stateProvince: Joi.string().required(),
    postalCode: Joi.string().required(),
    countryCode: Joi.string().length(2).uppercase().default('US'),
    type: Joi.string().valid('apartment', 'house', 'commercial', 'loft', 'studio').required(),
    amenities: Joi.array().items(Joi.string()).optional(),
    description: Joi.string().optional(),
    location: Joi.object({ lat: Joi.number().required(), lng: Joi.number().required() }).optional(),
  }),

  propertySearch: Joi.object({
    priceMin: Joi.number().min(0).optional(),
    priceMax: Joi.number().min(0).optional(),
    beds: Joi.number().integer().min(0).optional(),
    baths: Joi.number().integer().min(0).optional(),
    radiusKm: Joi.number().min(1).max(100).optional(),
    lat: Joi.number().min(-90).max(90).optional(),
    lng: Joi.number().min(-180).max(180).optional(),
    amenities: Joi.string().optional(),
    pets: Joi.boolean().optional(),
    availableFrom: Joi.date().iso().optional(),
    sort: Joi.string().valid('relevance', 'price_asc', 'price_desc', 'newest').default('relevance'),
    page: Joi.number().integer().min(1).default(1),
    limit: Joi.number().integer().min(1).max(100).default(20),
  }),

  workOrderCreate: Joi.object({
    propertyId: Joi.string().uuid().required(),
    unitId: Joi.string().uuid().required(),
    tenantId: Joi.string().uuid().optional(),
    title: Joi.string().min(3).max(255).required(),
    description: Joi.string().required(),
    category: Joi.string().valid('general_repair', 'plumbing', 'electrical', 'hvac', 'appliance', 'painting', 'other').required(),
    priority: Joi.string().valid('low', 'medium', 'high', 'emergency').default('medium'),
    budgetMin: Joi.number().min(0).optional(),
    budgetMax: Joi.number().min(0).optional(),
    currency: Joi.string().length(3).uppercase().required(),
    accessInstructions: Joi.string().optional(),
    notifyTenant: Joi.boolean().default(true),
    notifyVendor: Joi.boolean().default(true),
  }),

  bidCreate: Joi.object({
    amount: Joi.number().positive().required(),
    currency: Joi.string().length(3).uppercase().required(),
    message: Joi.string().max(1000).optional(),
    estimatedHours: Joi.number().integer().min(1).optional(),
    proposedDate: Joi.date().iso().required(),
    isFixedPrice: Joi.boolean().default(false),
  }),

  leaseCreate: Joi.object({
    tenantId: Joi.string().uuid().required(),
    unitId: Joi.string().uuid().required(),
    startDate: Joi.date().iso().required(),
    endDate: Joi.date().iso().greater(Joi.ref('startDate')).required(),
    rentAmount: Joi.number().positive().required(),
    depositAmount: Joi.number().min(0).optional(),
    paymentSchedule: Joi.string().valid('monthly', 'weekly', 'bi_weekly').default('monthly'),
    autoRenew: Joi.boolean().default(false),
  }),

  paymentInitiate: Joi.object({
    leaseId: Joi.string().uuid().required(),
    amount: Joi.number().positive().required(),
    paymentMethod: Joi.string().valid('card', 'bank_transfer', 'stripe').required(),
  }),

  courseCreate: Joi.object({
    title: Joi.string().min(3).required(),
    slug: Joi.string().alphanum().optional(),
    category: Joi.string().optional(),
    difficulty: Joi.string().optional(),
    duration_minutes: Joi.number().integer().min(0).optional(),
    instructor_name: Joi.string().optional(),
    description: Joi.string().optional(),
    passing_score: Joi.number().integer().min(0).max(100).default(70),
    is_published: Joi.boolean().optional(),
    thumbnail_url: Joi.string().optional(),
  }),

  quizSubmit: Joi.object({
    moduleId: Joi.string().required(),
    answers: Joi.array().items(
      Joi.object({
        questionId: Joi.string().required(),
        selectedOptionId: Joi.string().required(),
      })
    ).required(),
  }),
};

export const validate = (schema: Joi.ObjectSchema) => {
  return (req: any, res: any, next: any) => {
    const { error, value } = schema.validate(req.body, { abortEarly: false, stripUnknown: true });
    if (error) {
      return res.status(400).json({
        error: 'Validation failed',
        details: error.details.map((d) => ({ field: d.path.join('.'), message: d.message })),
      });
    }
    req.body = value;
    next();
  };
};
