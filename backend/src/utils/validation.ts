import Joi from 'joi';

export const schemas = {
  login: Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().min(8).required(),
    deviceId: Joi.string().optional(),
    deviceType: Joi.string().valid('ios', 'android', 'web').optional(),
  }),

  register: Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().min(8).required(),
    phone: Joi.string().optional(),
    role: Joi.string().valid('tenant', 'landlord', 'vendor').required(),
    regionCode: Joi.string().optional(),
  }),

  onboardingStep: Joi.object({
    data: Joi.object().required(),
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
    propertyId: Joi.string().uuid().required(),
    startDate: Joi.date().iso().required(),
    endDate: Joi.date().iso().greater(Joi.ref('startDate')).required(),
    rentAmount: Joi.number().positive().required(),
    securityDeposit: Joi.number().min(0).optional(),
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
    slug: Joi.string().alphanum().required(),
    category: Joi.string().valid('compliance', 'finance', 'maintenance', 'legal', 'strategy').required(),
    difficulty: Joi.string().valid('beginner', 'intermediate', 'advanced').required(),
    durationMinutes: Joi.number().integer().min(1).required(),
    instructorName: Joi.string().optional(),
    description: Joi.string().optional(),
    passingScore: Joi.number().integer().min(0).max(100).default(70),
  }),

  quizSubmit: Joi.object({
    answers: Joi.array().items(
      Joi.object({
        questionId: Joi.string().required(),
        selectedOptionId: Joi.string().required(),
      })
    ).required(),
  }),

  adCreate: Joi.object({
    title: Joi.string().min(3).max(255).required(),
    description: Joi.string().allow('').optional(),
    adType: Joi.string().required(),
    bannerUrl: Joi.string().uri().required(),
    targetRoles: Joi.array().items(Joi.string().valid('super_admin', 'admin', 'landlord', 'property_manager', 'tenant', 'vendor', 'lms_instructor')).required(),
    latitude: Joi.number().min(-90).max(90).optional(),
    longitude: Joi.number().min(-180).max(180).optional(),
    radiusMeters: Joi.number().min(0).optional(),
    redirectUrl: Joi.string().uri().allow('').optional(),
    isActive: Joi.boolean().default(true),
  }),

  adUpdate: Joi.object({
    title: Joi.string().min(3).max(255).optional(),
    description: Joi.string().allow('').optional(),
    adType: Joi.string().optional(),
    bannerUrl: Joi.string().uri().optional(),
    targetRoles: Joi.array().items(Joi.string().valid('super_admin', 'admin', 'landlord', 'property_manager', 'tenant', 'vendor', 'lms_instructor')).optional(),
    latitude: Joi.number().min(-90).max(90).optional(),
    longitude: Joi.number().min(-180).max(180).optional(),
    radiusMeters: Joi.number().min(0).optional(),
    redirectUrl: Joi.string().uri().allow('').optional(),
    isActive: Joi.boolean().optional(),
  }),

  propertyReject: Joi.object({
    reason: Joi.string().min(3).max(1000).required(),
    deadline: Joi.date().iso().required(),
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
