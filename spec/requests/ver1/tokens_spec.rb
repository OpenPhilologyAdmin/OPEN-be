# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/projects/{project_id}/tokens', type: :request do
  let(:user) { create(:user, :admin, :approved) }
  let(:project_id) { create(:project).id }

  path '/api/v1/projects/{project_id}/tokens' do
    get('Retrieves tokens of the specified project') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Get tokens of the project. It returns tokens for the *Read mode* by default. <br>' \
                  'When *edit_mode* flag is enabled, the tokens will include additional details (token state).'

      parameter name: :project_id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of the project'

      parameter name: :edit_mode, in: :query,
                schema: {
                  type: :boolean
                },
                required: false,
                description: 'When true, the returned tokens will include additional details (token state)'

      response '200', 'Tokens can be retrieved' do
        let(:Authorization) { authorization_header_for(user) }

        schema type:       :object,
               properties:
                           {
                             records: {
                               type:  :array,
                               items: { '$ref' => '#/components/schemas/token' }
                             },
                             count:   {
                               type:        :integer,
                               description: 'Number of all records',
                               example:     50
                             }
                           }

        before { create_list(:token, 3, project_id:) }

        run_test!

        context 'when edit_mode enabled' do
          let(:edit_mode) { true }

          it 'includes token\'s state in response' do
            expect(JSON.parse(response.body)['records']).to all(have_key('state'))
          end
        end

        context 'when edit_mode disabled/not given' do
          let(:edit_mode) { [false, nil].sample }

          it 'does not include token\'s state in response' do
            JSON.parse(response.body)['records'].each do |record|
              expect(record).not_to have_key('state')
            end
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
  path '/api/v1/projects/{project_id}/tokens/{id}' do
    let(:record) { create(:token, project_id:) }
    let(:id) { record.id }

    get('Retrieves token details') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Get the token details.'

      parameter name: :project_id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of the project'

      parameter name: :id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of token'

      response '200', 'Token found' do
        let(:Authorization) { authorization_header_for(user) }

        schema '$ref' => '#/components/schemas/token_verbose'

        run_test!
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!
      end

      response '404', 'Project or token not found' do
        let(:Authorization) { authorization_header_for(user) }
        let(:id) { 'invalid-id' }

        schema '$ref' => '#/components/schemas/record_not_found'

        run_test!
      end
    end
  end
end
