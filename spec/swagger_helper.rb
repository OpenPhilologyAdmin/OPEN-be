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
          invalid_record:        {
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
          user:                  {
            type:       :object,
            properties: {
              id:                     { type: :integer },
              email:                  { type: :string, format: :email },
              name:                   { type: :string },
              role:                   { type: :string, enum: %i[admin], default: :admin },
              account_approved:       { type:        :boolean,
                                        description: 'The account has been approved/activated by the admin' },
              registration_date:      {
                type:        :string,
                format:      :date_time,
                description: 'Registration date in ISO 8601 format',
                example:     '2022-06-30T00:00:00.000+02:00'
              },
              last_edited_project_id: { type: :integer }
            },
            required:   %w[email name]
          },
          credentials:           {
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
          user_email:            {
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
          user_reset_password:   {
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
          project:               {
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
              creator_id:      { type: :integer, default: '1', nullable: true },
              creation_date:   {
                type:        :string,
                format:      :date_time,
                description: 'Date in ISO 8601 format',
                example:     '2022-06-30T00:00:00.000+02:00'
              },
              last_edit_by:    { type: :string, default: 'John Doe', nullable: true },
              last_edit_date:  {
                type:        :string,
                format:      :date_time,
                description: 'Date in ISO 8601 format',
                example:     '2022-07-01T00:00:00.000+02:00'
              },
              import_errors:   {
                type:       :object,
                nullable:   true,
                properties: {
                  file_format: {
                    type:     :array,
                    nullable: true,
                    items:    {
                      type:        :string,
                      description: 'The list of errors that happened during data import',
                      example:     'The file format is not supported.'
                    }
                  }
                }
              }
            },
            required:   ['name']
          },
          witness:               {
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
          witness_create:        {
            type:       :object,
            properties: {
              witness: {
                type:       :object,
                properties: {
                  name:   {
                    type:        :string,
                    description: 'Full name of witness',
                    example:     'Lorem ipsum',
                    maximum:     50,
                    nullable:    true
                  },
                  siglum: {
                    type:        :string,
                    description: 'Siglum',
                    example:     'A'
                  }
                },
                required:   [:siglum]
              }
            }
          },
          witness_update:        {
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
          token:                 {
            type:       :object,
            properties: {
              id:              {
                type:    :integer,
                example: 1
              },
              t:               {
                type:        :string,
                description: "Token value. The *#{FormattableT::NIL_VALUE_PLACEHOLDER}* means that " \
                             'the value is empty.',
                example:     'Lorem ipsum',
                nullable:    false
              },
              apparatus_index: {
                type:        :integer,
                description: 'Index of apparatus, available only if the token is listed there',
                example:     1,
                nullable:    true
              },
              state:           {
                type:        :string,
                enum:        %i[one_variant not_evaluated evaluated_with_single evaluated_with_multiple],
                default:     :not_evaluated,
                description: 'The state of token is returned only when edit_mode enabled.<br>' \
                             '*:one_variant* - all witnesses have the same reading,<br>' \
                             '*:not_evaluated* - has not been evaluated yet (no reading selected),<br>' \
                             '*:evaluated_with_single* - only a single significant reading selected,<br>' \
                             '*:evaluated_with_multiple* - multiple significant readings selected'
              }
            }
          },
          token_edit:            {
            type:       :object,
            properties: {
              id:               {
                type:    :integer,
                example: 1
              },
              apparatus:        {
                type:        :object,
                description: 'Significant readings for token. Can be blank if there was no selection.',
                nullable:    true,
                properties:  {
                  selected_reading: {
                    type:        :string,
                    description: "Selected reading value. The *#{FormattableT::NIL_VALUE_PLACEHOLDER}* " \
                                 'means that the reading value is empty.',
                    example:     'Lorem ipsum]'
                  },
                  details:          {
                    type:        :string,
                    description: 'The witnesses of the selected variant and then possible readings with their ' \
                                 "witnesses. The *#{FormattableT::NIL_VALUE_PLACEHOLDER}* means that the " \
                                 'reading value is empty.',
                    example:     'A B, Lorem ipsam st., Lorem ipsem E F'
                  }
                }
              },
              grouped_variants: {
                type:        :array,
                description: 'Available variants, grouped by the same t (value)',
                items:       {
                  type:       :object,
                  properties: {
                    id:        {
                      type:        :string,
                      example:     'AB',
                      description: 'The ID is auto-generated from the witnesses. ' \
                                   "For example, for witnesses: ['A', 'B', 'E'] it would be 'ABE'."
                    },
                    witnesses: {
                      type:  :array,
                      items: {
                        type:        :string,
                        description: 'List of witnesses that use this variant',
                        example:     'A'
                      }
                    },
                    t:         {
                      type:        :string,
                      description: 'Variant value',
                      example:     'Lorem ipsum',
                      nullable:    true
                    },
                    selected:  {
                      type:        :boolean,
                      description: 'Whether is selected as a primary reading'
                    },
                    possible:  {
                      type:        :boolean,
                      description: 'Whether is selected as a secondary reading'
                    }
                  }
                }
              },
              variants:         {
                type:        :array,
                description: 'Available variants with their values (t)',
                items:       {
                  type:       :object,
                  properties: {
                    witness: {
                      type:        :string,
                      example:     'A',
                      description: 'ID of the witness that includes this variant'
                    },
                    t:       {
                      type:        :string,
                      description: 'Variant value',
                      example:     'Lorem ipsum',
                      nullable:    true
                    }
                  }
                }
              },
              editorial_remark: {
                type:       :object,
                properties: {
                  type: {
                    type:        :string,
                    enum:        ['st.', 'corr.', 'em.', 'conj.'],
                    description: 'Editorial remark type',
                    example:     'st.'
                  },
                  t:    {
                    type:        :string,
                    description: 'Variant value',
                    example:     'Lorem ipsam',
                    nullable:    true
                  }
                }
              }
            }
          },
          grouped_variant:       {
            type:       :object,
            properties: {
              id:       {
                type:        :string,
                example:     'AB',
                description: 'The ID is auto-generated from the witnesses. ' \
                             "For example, for witnesses: ['A', 'B', 'E'] it would be 'ABE'."
              },
              selected: {
                type:        :boolean,
                description: 'Whether is selected as a primary reading'
              },
              possible: {
                type:        :boolean,
                description: 'Whether is selected as a secondary reading'
              }
            }
          },
          variant:               {
            type:       :object,
            properties: {
              witness: {
                type:        :string,
                description: 'Witness ID',
                example:     'A'
              },
              t:       {
                type:        :string,
                description: 'Variant value',
                example:     'Lorem ipsum',
                nullable:    true
              }
            }
          },
          editorial_remark:      {
            type:       :object,
            properties: {
              type: {
                type:        :string,
                enum:        ['st.', 'corr.', 'em.', 'conj.'],
                description: 'Editorial remark type',
                example:     'st.'
              },
              t:    {
                type:        :string,
                description: 'Variant value',
                example:     'Lorem ipsum',
                nullable:    true
              }
            }
          },
          significant_variant:   {
            type:       :object,
            properties: {
              token_id: {
                type:        :integer,
                description: 'The ID of token',
                example:     1
              },
              index:    {
                type:        :integer,
                description: 'Index of apparatus, starting with 1',
                example:     1
              },
              value:    {
                type:       :object,
                properties: {
                  selected_reading: {
                    type:        :string,
                    description: "Selected reading value. The *#{FormattableT::NIL_VALUE_PLACEHOLDER}* " \
                                 'means that the reading value is empty.',
                    example:     'raged]'
                  },
                  details:          {
                    type:        :string,
                    description: 'The witnesses of the selected variant and then possible readings with their ' \
                                 "witnesses. The *#{FormattableT::NIL_VALUE_PLACEHOLDER}* means that the " \
                                 'reading value is empty.',
                    example:     'A B, continued C D, group E F'
                  }
                }
              }
            }
          },
          insignificant_variant: {
            type:       :object,
            properties: {
              token_id: {
                type:        :integer,
                description: 'The ID of token',
                example:     1
              },
              index:    {
                type:        :integer,
                description: 'Index of apparatus, starting with 1',
                example:     1
              },
              value:    {
                type:       :object,
                properties: {
                  selected_reading: {
                    type:        :string,
                    description: "Selected reading value. The *#{FormattableT::NIL_VALUE_PLACEHOLDER}* " \
                                 'means that the reading value is empty.',
                    example:     'raged]'
                  },
                  details:          {
                    type:        :string,
                    description: 'Insignificant readings with their witnesses. The ' \
                                 "*#{FormattableT::NIL_VALUE_PLACEHOLDER}* means that " \
                                 'the reading value is empty.',
                    example:     'continued C D, group E F'
                  }
                }
              }
            }
          },
          login_required:        {
            type:       :object,
            properties: {
              error: {
                type:    :string,
                example: I18n.t('devise.failure.unauthenticated')
              }
            }
          },
          record_not_found:      {
            type:       :object,
            properties: {
              error: {
                type:    :string,
                example: I18n.t('general.errors.not_found')
              }
            }
          },
          forbidden_request:     {
            type:       :object,
            properties: {
              error: {
                type:    :string,
                example: I18n.t('general.errors.forbidden_request')
              }
            }
          },
          comment:               {
            type:       :object,
            properties: {
              id:           {
                type:        :integer,
                description: 'ID of the comment',
                example:     1
              },
              body:         {
                type:        :string,
                description: 'Body of the comment',
                example:     'I like to comment on things and pancakes are nice!'
              },
              token_id:     {
                type:        :integer,
                description: 'ID of the token',
                example:     1
              },
              user_id:      {
                type:        :integer,
                description: 'ID of the user who created given comment',
                example:     1
              },
              created_at:   {
                type:        :date_time,
                description: 'Creation date',
                example:     DateTime.new(2021, 2, 3.5)
              },
              created_by:   {
                type:        :string,
                description: 'Name of the user who created given comment',
                example:     'Jonny Bravo'
              },
              last_edit_at: {
                type:        :date_time,
                description: 'Last edit date if exists',
                example:     DateTime.new(2021, 2, 3.5)
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
