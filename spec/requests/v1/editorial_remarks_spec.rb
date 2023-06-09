# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/editorial_remarks', type: :request do
  path '/api/v1/editorial_remarks' do
    let(:user) { create(:user, :admin, :approved) }

    get('Returns editorial remark types') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Apparatus: Editorial Remark Types'

      response(200, 'successful') do
        let(:Authorization) { authorization_header_for(user) }

        schema type:                 :object,
               additionalProperties: {
                 type: :string
               }

        run_test!
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!
      end
    end
  end
end
