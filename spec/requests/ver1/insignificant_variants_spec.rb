# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/projects/{project_id}/insignificant_variants', type: :request do
  path '/api/v1/projects/{project_id}/insignificant_variants' do
    let(:user) { create(:user, :admin, :approved) }
    let(:project_id) { create(:project).id }

    get('Retrieves insignificant variants of the specified project') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Apparatus: Insignificant variants of the project.'

      parameter name: :project_id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of the project'

      response '200', 'Insignificant variants can be retrieved' do
        let(:Authorization) { authorization_header_for(user) }

        before do
          create_list(:token, 3, :variant_selected, project_id:)
          create(:token, :variant_selected_and_secondary, project_id:)
          create(:token, project_id:)
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
          expect(JSON.parse(response.body)['count']).to eq(3)
        end

        it 'fetches only the tokens that have apparatus and some insignificant variants' do
          JSON.parse(response.body)['records'].each do |record|
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
        let(:project_id) { 'invalid-id' }

        schema '$ref' => '#/components/schemas/record_not_found'

        run_test!
      end
    end
  end
end
