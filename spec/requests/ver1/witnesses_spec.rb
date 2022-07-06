# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/projects/{project_id}/witnesses', type: :request do
  path '/api/v1/projects/{project_id}/witnesses' do
    let(:user) { create(:user, :admin, :approved) }
    let(:project_id) { create(:project).id }

    get('Retrieves witnesses of the specified project') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Get witnesses of the project.'

      parameter name: :project_id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of project'

      response '200', 'Witnesses can be retrieved' do
        let(:Authorization) { authorization_header_for(user) }

        schema type:       :object,
               properties:
                           {
                             records:      {
                               type:  :array,
                               items: { '$ref' => '#/components/schemas/witness' }
                             },
                             count:        {
                               type:        :integer,
                               description: 'Number of all records',
                               example:     50
                             },
                             current_page: {
                               type:        :integer,
                               description: 'Current page',
                               example:     1,
                               default:     1
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
