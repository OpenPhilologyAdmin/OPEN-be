# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/users', type: :request do
  path '/api/v1/users' do
    let(:user) { create(:user, :admin, :approved) }

    get('Retrieves paginated list of users') do
      let(:page) { 1 }
      let(:items) { 10 }

      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description('Allows retrieving all users list.')

      response '200', 'Users can be retrieved' do
        let(:Authorization) { authorization_header_for(user) }

        parameter name: :items, in: :query, schema: {
          type:     :integer,
          required: false,
          example:  'Number of records per page'
        }

        parameter name: :page, in: :query, schema: {
          type:     :integer,
          required: false,
          example:  'Page number'
        }

        before do
          create_list(:user, 3)
        end

        schema type:       :object,
               properties:
                           {
                             records:      {
                               type:  :array,
                               items: { '$ref' => '#/components/schemas/user' }
                             },
                             count:        {
                               type:        :integer,
                               description: 'Number of all records',
                               example:     50
                             },
                             current_page: {
                               type:        :integer,
                               description: 'Current page',
                               example:     1
                             },
                             pages:        {
                               type:        :integer,
                               description: 'Number of all pages',
                               example:     5
                             }
                           }

        run_test!
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }

        schema type:       :object,
               properties: {
                 message: {
                   type:    :string,
                   example: I18n.t('general.errors.login_required')
                 }
               }

        run_test!
      end

      response '403', 'Not Authorized' do
        let(:user) { create(:user, :admin, :not_approved) }
        let(:Authorization) { authorization_header_for(user) }

        schema type:       :object,
               properties: {
                 message: {
                   type:    :string,
                   example: I18n.t('general.errors.forbidden_request')
                 }
               }

        run_test!
      end
    end
  end
end
