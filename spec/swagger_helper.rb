# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.swagger_root   = Rails.root.join('swagger').to_s
  config.swagger_docs   = {
    'v1/swagger.yaml' => {
      openapi:    '3.0.1',
      info:       {
        title:   'API V1',
        version: 'v1'
      },
      components: {
        securitySchemes: {
          bearer: {
            type: :apiKey,
            name: 'Authorization',
            in:   :header
          }
        },
        schemas:         {
          invalid_record:      {
            type:       :object,
            properties: {
              '$field_name': {
                type:  :array,
                items: {
                  type:        :string,
                  description: 'Errors related to $field_name',
                  example:     '$field_name can\'t be blank'
                }
              }
            }
          },
          user:                {
            type:       :object,
            properties: {
              id:               { type: :integer },
              email:            { type: :string, format: :email },
              name:             { type: :string },
              role:             { type: :string, enum: %i[admin], default: :admin },
              account_approved: { type: :boolean }
            },
            required:   %w[email name]
          },
          credentials:         {
            type:       :object,
            properties: {
              user: {
                type:       :object,
                properties: {
                  email:    { type: :string, format: :email },
                  password: { type: :string, format: :password }
                },
                required:   %w[email password]
              }
            }
          },
          user_email:          {
            type:       :object,
            properties: {
              user: {
                type:       :object,
                properties: {
                  email: { type: :string, format: :email }
                },
                required:   ['email']
              }
            }
          },
          user_reset_password: {
            type:       :object,
            properties: {
              user: {
                type:       :object,
                properties: {
                  reset_password_token:  { type: :string, example: 'reset_password_token' },
                  password:              {
                    type:        :string,
                    minimum:     8,
                    maximum:     128,
                    example:     'password1',
                    description: 'must contain at least one digit and one letter'
                  },
                  password_confirmation: {
                    type:        :string,
                    example:     'password1',
                    description: 'must match password'
                  }
                },
                required:   %w[reset_password_token password password_confirmation]
              }
            }
          },
          project:             {
            type:       :object,
            properties: {
              id:              { type: :integer },
              name:            { type: :string, maximum: 50 },
              default_witness: {
                type:        :string,
                nullable:    true,
                example:     'A',
                description: 'It is required when then source file is text/plain'
              },
              witnesses:       {
                type:     :array,
                nullable: true,
                items:    {
                  type:       :object,
                  properties: {
                    id:      {
                      type:        :string,
                      description: 'ID, It is the same as Siglum',
                      example:     'A'
                    },
                    name:    {
                      type:        :string,
                      description: 'Full name of witness',
                      example:     'Lorem ipsum'
                    },
                    siglum:  {
                      type:        :string,
                      description: 'Siglum',
                      example:     'A'
                    },
                    default: {
                      type:    :boolean,
                      example: false
                    }
                  }
                }
              },
              witnesses_count: { type: :integer, description: 'Number of witnesses' },
              status:          { type: :string, enum: %i[processing processed invalid], default: :processing },
              created_by:      { type: :string, default: 'John Doe', nullable: true },
              creation_date:   {
                type:        :string,
                format:      :date_time,
                description: 'Date in ISO 8601 format',
                example:     '2022-06-30T00:00:00.000+02:00'
              },
              last_edit_date:  {
                type:        :string,
                format:      :date_time,
                description: 'Date in ISO 8601 format',
                example:     '2022-07-01T00:00:00.000+02:00'
              }
            },
            required:   ['name']
          },
          witness:             {
            type:       :object,
            properties: {
              id:      {
                type:        :string,
                description: 'ID, It is the same as Siglum',
                example:     'A'
              },
              name:    {
                type:        :string,
                description: 'Full name of witness',
                example:     'Lorem ipsum',
                maximum:     50,
                nullable:    true
              },
              siglum:  {
                type:        :string,
                description: 'Siglum',
                example:     'A'
              },
              default: {
                type:    :boolean,
                example: false
              }
            }
          },
          witness_update:      {
            type:       :object,
            properties: {
              witness: {
                type:       :object,
                properties: {
                  name:    {
                    type:        :string,
                    description: 'Full name of witness',
                    example:     'Lorem ipsum',
                    maximum:     50,
                    nullable:    true
                  },
                  default: {
                    type:        :boolean,
                    description: 'Whether it should be a default witness of the project',
                    example:     false
                  }
                }
              }
            }
          },
          login_required:      {
            type:       :object,
            properties: {
              error: {
                type:    :string,
                example: I18n.t('general.errors.login_required')
              }
            }
          },
          record_not_found:    {
            type:       :object,
            properties: {
              error: {
                type:    :string,
                example: I18n.t('general.errors.not_found')
              }
            }
          },
          forbidden_request:   {
            type:       :object,
            properties: {
              error: {
                type:    :string,
                example: I18n.t('general.errors.forbidden_request')
              }
            }
          }
        }
      },
      paths:      {},
      servers:    [
        {
          url:       'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: ENV.fetch('APP_HOST', nil).to_s
            }
          }
        }
      ]
    }
  }
  config.swagger_format = :yaml
end
