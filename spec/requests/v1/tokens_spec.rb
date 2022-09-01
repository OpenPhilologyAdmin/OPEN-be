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
        let(:expected_records) do
          TokensSerializer.new(records: project.tokens, edit_mode:).as_json[:records]
        end

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

          it 'passes the correct edit_mode value to the records serializer' do
            records = JSON.parse(response.body)['records']
            expect(records).to match_array(expected_records)
          end
        end

        context 'when edit_mode disabled/not given' do
          let(:edit_mode) { [false, nil].sample }

          it 'passes the correct edit_mode value to the records serializer' do
            records = JSON.parse(response.body)['records']
            expect(records).to match_array(expected_records)
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
    let(:record) { create(:token, :variant_selected_and_secondary, project:) }
    let(:id) { record.id }

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

  path '/api/v1/projects/{project_id}/tokens/{id}/grouped_variants' do
    let(:record) { create(:token, project:, grouped_variants: [grouped_variant, grouped_variant2]) }
    let(:grouped_variant) { build(:token_grouped_variant, :insignificant) }
    let(:grouped_variant2) { build(:token_grouped_variant, :insignificant) }
    let(:id) { record.id }

    patch('Updates token grouped variants') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Update the token selections by updating the **grouped_variants**.<br>' \
                  'Use *selected* when setting the main reading and *possible* for secondary readings. <br>' \
                  'The user who edits the token will be saved as the last editor of the project.'

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
                                  'id'       => grouped_variant.id,
                                  'selected' => true,
                                  'possible' => true
                                },
                                {
                                  'id'       => grouped_variant2.id,
                                  'selected' => false,
                                  'possible' => true
                                }
                              ]
          }
        }
      end

      response '200', 'Token updated' do
        let(:Authorization) { authorization_header_for(user) }

        schema '$ref' => '#/components/schemas/token_edit'

        run_test!

        before { record.reload }

        it 'saves the current user as last_editor of project' do
          expect(record.project.last_editor).to eq(user)
        end

        it 'selects the correct grouped variant' do
          updated_grouped_variant = record.grouped_variants.find { |variant| variant.id == grouped_variant.id }
          expect(updated_grouped_variant).to be_selected
          expect(updated_grouped_variant).to be_possible
        end

        it 'saves the possible grouped variant' do
          updated_grouped_variant = record.grouped_variants.find { |variant| variant.id == grouped_variant2.id }
          expect(updated_grouped_variant).not_to be_selected
          expect(updated_grouped_variant).to be_possible
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

  path '/api/v1/projects/{project_id}/tokens/{id}/variants' do
    let(:record) { create(:token, project:) }
    let(:id) { record.id }

    patch('Updates token variants and editorial remark') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Update the selected token details.<br>' \
                  'Use **variants** when editing the content for the specific witness. <br>' \
                  'Use **editorial_remark** when adding or editing the editorial remark, only the following ' \
                  "types are available: *'st.', 'corr.', 'em.', 'conj.'*. '\
                  'The *'em.' and 'conj.'* will become automatically selected. <br>" \
                  'If **variants** or **editorial_remark** are updated, the **grouped_variants** will  ' \
                  'be calculated once again, all previous selections will be cleared.<br>' \
                  'The user who edits the token will be saved as the last editor of the project.'

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
              variants:         {
                type:  :array,
                items: { '$ref' => '#/components/schemas/variant' }
              },
              editorial_remark: { '$ref' => '#/components/schemas/editorial_remark' }
            },
            required:   %w[variants]
          }
        }
      }

      let(:token) do
        {
          token: {
            variants:
                              [
                                {
                                  'witness' => project.witnesses_ids.first,
                                  't'       => 'lorem'
                                },
                                {
                                  'witness' => project.witnesses_ids.last,
                                  't'       => 'ipsum '
                                }
                              ],
            editorial_remark: {
              type: 'st.',
              t:    'Lorem ipsum'
            }
          }
        }
      end

      response '200', 'Token updated' do
        let(:Authorization) { authorization_header_for(user) }

        schema '$ref' => '#/components/schemas/token_edit'

        run_test!

        before { record.reload }

        it 'saves the current user as last_editor of project' do
          expect(record.project.last_editor).to eq(user)
        end

        it 'updates the token variants' do
          token[:token][:variants].each do |variant_to_update|
            updated_variant = record.variants.find { |resource| resource.witness == variant_to_update['witness'] }
            expect(updated_variant.t).to eq(variant_to_update['t'])
          end
        end

        it 'updates the editorial_remark' do
          token[:token][:editorial_remark].each do |key, value|
            expect(record.editorial_remark.send(key)).to eq(value)
          end
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
              variants: []
            }
          }
        end

        schema '$ref' => '#/components/schemas/invalid_record'

        run_test!
      end
    end
  end
end
