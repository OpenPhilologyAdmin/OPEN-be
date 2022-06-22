# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/users/session-token', type: :request do
  path '/api/v1/users/session-token' do
    post 'Generates new JWT token' do
      tags 'Authorization'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description "Returns new JWT token to prolong user's session"

      response '204', 'Token has been successfully generated and is available in response headers' do
        let(:Authorization) { authorization_header_for(user) }
        let(:user) { create(:user, :admin, :approved) }

        header 'Authorization',
               type:        :string,
               description: 'The JWT token for user with the following format:'\
                            ' Bearer {token}'

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
    end
  end
end
