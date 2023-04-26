# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/projects/{project_id}/insignificant_variants' do
  let(:not_accessible_project_id) { create(:project, :with_creator).id }

  path '/api/v1/projects/{project_id}/insignificant_variants' do
    let(:user) { create(:user, :admin, :approved) }
    let(:project) { create(:project, :with_creator, creator: user) }
    let(:project_id) { project.id }

    get('Retrieves insignificant variants of the specified project') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Apparatus: Insignificant variants of the project. ' \
                  'Only projects created by the user are accessible. '

      parameter name: :project_id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of the project'

      response '200', 'Insignificant variants can be retrieved' do
        let(:Authorization) { authorization_header_for(user) }

        before do
          create_list(:token, 3, :variant_selected, project:)
          create(:token, :variant_selected_and_secondary, project:)
          create(:token, project:)
        end

        schema type:       :object,
               properties:
                           {
                             records: {
                               type:  :array,
                               items: { '$ref' => '#/components/schemas/insignificant_variant' }
                             },
                             count:   {
                               type:        :integer,
                               description: 'Number of all records',
                               example:     50
                             }
                           }

        run_test!

        it 'fetches correct number of records' do
          expect(response.parsed_body['count']).to eq(3)
        end

        it 'fetches only the tokens that have apparatus and some insignificant variants' do
          response.parsed_body['records'].each do |record|
            expect(record['value']).not_to be_empty
          end
        end
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
