# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/projects/{project_id}/significant_variants', type: :request do
  path '/api/v1/projects/{project_id}/significant_variants' do
    let(:user) { create(:user, :admin, :approved) }
    let(:project_id) { create(:project).id }

    get('Retrieves significant variants of the specified project') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Apparatus: Significant variants of the project.'

      parameter name: :project_id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of the project'

      response '200', 'Significant variants can be retrieved' do
        let(:Authorization) { authorization_header_for(user) }

        schema type:       :object,
               properties:
                           {
                             records: {
                               type:  :array,
                               items: { '$ref' => '#/components/schemas/significant_variant' }
                             },
                             count:   {
                               type:        :integer,
                               description: 'Number of all records',
                               example:     50
                             }
                           }

        run_test!
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!
      end

      response '404', 'Project not found' do
        let(:Authorization) { authorization_header_for(user) }
        let(:project_id) { 'invalid-id' }

        schema '$ref' => '#/components/schemas/record_not_found'

        run_test!
      end
    end
  end
end
