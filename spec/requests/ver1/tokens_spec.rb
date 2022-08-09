# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/projects/{project_id}/tokens', type: :request do
  let(:user) { create(:user, :admin, :approved) }
  let(:project) { create(:project) }
  let(:project_id) { project.id }

  path '/api/v1/projects/{project_id}/tokens' do
    get('Retrieves tokens of the specified project') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Get tokens of the project. It returns tokens for the *Read mode* by default. <br>' \
                  'When *edit_mode* flag is enabled, the tokens will include additional details (token state).'

      parameter name:        :project_id, in: :path,
                schema:      {
                  type: :integer
                },
                required:    true,
                description: 'ID of the project'

      parameter name:        :edit_mode, in: :query,
                schema:      {
                  type: :boolean
                },
                required:    false,
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

        before { create_list(:token, 3, project:) }

        run_test!

        context 'when edit_mode enabled' do
          let(:edit_mode) { true }
          let(:mode) { :edit_project }

          it 'passes the correct mode to TokenSerializer' do
            records = JSON.parse(response.body)['records']
            project.tokens.each do |token|
              expect(records).to include(TokenSerializer.new(token, mode:).as_json)
            end
          end
        end

        context 'when edit_mode disabled/not given' do
          let(:edit_mode) { [false, nil].sample }
          let(:mode) { TokenSerializer::DEFAULT_MODE }

          it 'passes the correct mode to TokenSerializer' do
            records = JSON.parse(response.body)['records']
            project.tokens.each do |token|
              expect(records).to include(TokenSerializer.new(token, mode:).as_json)
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
    let(:mode) { :edit_token }

    get('Retrieves token details') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Get the token details.'

      parameter name:        :project_id, in: :path,
                schema:      {
                  type: :integer
                },
                required:    true,
                description: 'ID of the project'

      parameter name:        :id, in: :path,
                schema:      {
                  type: :integer
                },
                required:    true,
                description: 'ID of token'

      response '200', 'Token found' do
        let(:Authorization) { authorization_header_for(user) }

        schema '$ref' => '#/components/schemas/token_edit'

        run_test!

        it 'passes the correct mode to TokenSerializer' do
          expect(response.body).to eq(TokenSerializer.new(record, mode:).to_json)
        end
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

    put('Updates token details') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Update selected token details.<br>' \
                  'Use **grouped_variants** when selecting the reading (*selected*: main reading, ' \
                  '*possible*: secondary reading). <br>' \
                  'Use **variants** when editing the content for specific witness. <br>' \
                  'If **variants** are updated, the **grouped_variants** will be calculated once again, ' \
                  'all previous selections will be cleared.<br>' \
                  'The user who edits the token will be saved as last editor of the project.'

      parameter name:        :project_id, in: :path,
                schema:      {
                  type: :integer
                },
                required:    true,
                description: 'ID of the project'

      parameter name:        :id, in: :path,
                schema:      {
                  type: :integer
                },
                required:    true,
                description: 'ID of token'

      parameter name: :token, in: :body, schema: {
        type:       :object,
        properties: {
          token: {
            type:       :object,
            properties: {
              grouped_variants: {
                type:  :array,
                items: { '$ref' => '#/components/schemas/grouped_variant' }
              },
              variants:         {
                type:  :array,
                items: { '$ref' => '#/components/schemas/variant' }
              }
            },
            required:   %w[grouped_variants]
          }
        }
      }

      let(:token) do
        {
          token: {
            grouped_variants:
                              [
                                {
                                  'witnesses' => ['A'],
                                  't'         => 'lorem',
                                  'selected'  => true,
                                  'possible'  => true
                                },
                                {
                                  'witnesses' => ['B'],
                                  't'         => 'ipsum ',
                                  'selected'  => false,
                                  'possible'  => true
                                }
                              ]
          }
        }
      end

      response '200', 'Token updated' do
        let(:Authorization) { authorization_header_for(user) }
        let(:mode) { :edit_token }

        schema '$ref' => '#/components/schemas/token_edit'

        run_test!

        before { record.reload }

        it 'saves the current user as last_editor of project' do
          expect(record.project.last_editor).to eq(user)
        end

        it 'updates the token' do
          token[:token][:grouped_variants].each_with_index do |variant, index|
            variant.each do |key, value|
              expect(record.grouped_variants[index].send(key)).to eq(value)
            end
          end
        end

        it 'passes the correct mode to TokenSerializer' do
          expect(response.body).to eq(TokenSerializer.new(record, mode:).to_json)
        end
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

      response '422', 'Token data invalid' do
        let(:Authorization) { authorization_header_for(user) }
        let(:token) do
          {
            token: {
              grouped_variants: []
            }
          }
        end

        schema '$ref' => '#/components/schemas/invalid_record'

        run_test!
      end
    end
  end
end
