const Joi = require('joi');

const schema = Joi.object({
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
    tax_identifier: Joi.string().optional(),
  }).required(),
});

const payload = {
  step: 3,
  data: {
    documents: [
      {
        type: "passport",
        url: "https://example.com/kyc_placeholder.pdf"
      }
    ]
  }
};

const result = schema.validate(payload);
console.log(JSON.stringify(result, null, 2));
