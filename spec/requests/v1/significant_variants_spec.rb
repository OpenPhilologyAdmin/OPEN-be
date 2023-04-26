# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/projects/{project_id}/significant_variants' do
  let(:not_accessible_project_id) { create(:project, :with_creator).id }

  path '/api/v1/projects/{project_id}/significant_variants' do
    let(:user) { create(:user, :admin, :approved) }
    let(:project) { create(:project, :with_creator, creator: user) }
    let(:project_id) { project.id }

    get('Retrieves significant variants of the specified project') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Apparatus: Significant variants of the project. ' \
                  'Only projects created by the user are accessible. '

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

        schema '$ref' => '#/components/schemas/record_not_found'

        context 'when project does not exist' do
          let(:project_id) { 'invalid-id' }

          run_test!
        end

        context 'when project is not accessible' do
          let(:project_id) { not_accessible_project_id }

          run_test!
        end
      end
    end
  end
end
