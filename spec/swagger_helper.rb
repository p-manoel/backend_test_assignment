# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.swagger_root = Rails.root.join('swagger').to_s
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Cars API V1',
        version: 'v1',
        description: 'API for car recommendations with user preferences'
      },
      servers: [
        {
          url: 'http://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'localhost:3000'
            }
          }
        }
      ],
      paths: {},
      components: {
        schemas: {
          car: {
            type: 'object',
            properties: {
              id: { type: 'integer' },
              brand: { type: 'string' },
              model: { type: 'string' },
              price: { type: 'integer' },
              label: {
                type: 'string',
                enum: ['perfect_match', 'good_match', nil],
                nullable: true,
                description: 'Match level based on user preferences'
              }
            },
            required: ['id', 'brand', 'model', 'price']
          },
          error: {
            type: 'object',
            properties: {
              error: { type: 'string' }
            }
          }
        }
      }
    }
  }
end
