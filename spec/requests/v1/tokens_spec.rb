# frozen_string_literal: true

require 'swagger_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
# rubocop:disable RSpec/ScatteredSetup
RSpec.describe 'v1/projects/{project_id}/tokens' do
  let(:not_accessible_project_id) { create(:project, :with_creator).id }
  let(:user) { create(:user, :admin, :approved) }
  let(:project) { create(:project, :with_creator, creator: user) }
  let(:project_id) { project.id }

  path '/api/v1/projects/{project_id}/tokens' do
    get('Retrieves tokens of the specified project') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Get tokens of the project. Only projects created by the user are accessible. <br />' \
                  'It returns tokens for the *Read mode* by default. <br />' \
                  'When *edit_mode* flag is enabled, the tokens will include additional details (state and index).'

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
            records = response.parsed_body['records']
            expect(records).to match_array(expected_records)
          end
        end

        context 'when edit_mode disabled/not given' do
          let(:edit_mode) { [false, nil].sample }

          it 'passes the correct edit_mode value to the records serializer' do
            records = response.parsed_body['records']
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

  path '/api/v1/projects/{project_id}/tokens/{id}' do
    let(:record) { create(:token, :variant_selected_and_secondary, project:) }
    let(:id) { record.id }

    get('Retrieves token details') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Get the token details. Only tokens from the projects created by the user are accessible. '

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

        schema '$ref' => '#/components/schemas/record_not_found'

        context 'when project does not exist' do
          let(:project_id) { 'invalid-id' }

          run_test!
        end

        context 'when project is not accessible' do
          let(:project_id) { not_accessible_project_id }

          run_test!
        end

        context 'when token not found' do
          let(:id) { 'invalid-id' }

          run_test!
        end
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
      description 'Update the token selections by updating the **grouped_variants**. ' \
                  'Only tokens from the projects created by the user are accessible. <br />' \
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

        it 'updates the user as the last editor of project' do
          expect(project.reload.last_editor).to eq(user)
        end

        it 'updates project as the last edited project by user' do
          expect(user.reload.last_edited_project).to eq(project)
        end
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!
      end

      response '404', 'Project or token not found' do
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

        context 'when token not found' do
          let(:id) { 'invalid-id' }

          run_test!
        end
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
      description 'Update the selected token details. ' \
                  'Only tokens from the projects created by the user are accessible. <br />' \
                  'Use **variants** when editing the content for the specific witness. <br />' \
                  'Use **editorial_remark** when adding or editing the editorial remark, only the following ' \
                  "types are available: *'st.', 'corr.', 'em.', 'conj.'*. '\
                  'The *'em.' and 'conj.'* will become automatically selected. <br />" \
                  'If **variants** or **editorial_remark** are updated, the **grouped_variants** will  ' \
                  'be calculated once again, all previous selections will be cleared.<br />' \
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

        it 'updates the user as the last editor of project' do
          expect(project.reload.last_editor).to eq(user)
        end

        it 'updates project as the last edited project by user' do
          expect(user.reload.last_edited_project).to eq(project)
        end
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!
      end

      response '404', 'Project or token not found' do
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

        context 'when token not found' do
          let(:id) { 'invalid-id' }

          run_test!
        end
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

  path '/api/v1/projects/{project_id}/tokens/resize' do
    patch('Update the width of selected tokens') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Uses given params to merge multiple tokens into one. ' \
                  'Only tokens from the projects created by the user are accessible. <br />' \
                  'The selections, editorial remarks, and comments won\'t be preserved. <br />' \
                  'The number of tokens in the project may be changed by this operation.'

      parameter name:        :project_id, in: :path,
                schema:      {
                  type: :integer
                },
                required:    true,
                description: 'ID of the project'

      parameter name: :token, in: :body, schema: {
        type:       :object,
        properties: {
          token: {
            type:       :object,
            properties: {
              selected_token_ids: {
                type:  :array,
                items: {
                  type:        :integer,
                  description: 'IDs of the selected tokens. All tokens must belong to the given project.' \
                               'The given tokens must be next to each other in the constituted text.'
                }
              }
            },
            required:   %w[selected_token_ids]
          }
        }
      }

      before do
        selected_token1
        selected_token2
        not_selected_token
      end

      let(:selected_token1) { create(:token, :one_grouped_variant, project:, index: 0) }
      let(:selected_token2) { create(:token, :one_grouped_variant, project:, index: 1) }
      let(:not_selected_token) { create(:token, project:, index: 2) }

      let(:token) do
        {
          token: {
            selected_token_ids: [selected_token1.id, selected_token2.id]
          }
        }
      end

      response '200', 'Changes saved' do
        let(:Authorization) { authorization_header_for(user) }

        schema type:       :object,
               properties: {
                 message: {
                   type:    :string,
                   example: I18n.t('tokens.notifications.tokens_width_updated')
                 }
               }

        run_test!

        before { project.reload }

        it 'updates number of project tokens' do
          expect(project.tokens.size).to eq(2)
        end

        it 'sets the correct :index of the new token' do
          new_token = project.tokens.first
          expect(new_token.index).to eq(0)
        end

        it 'sets the given selected_text as :t of the new token' do
          new_token = project.tokens.first
          expected_text = "#{selected_token1.t}#{selected_token2.t}"
          expect(new_token.t).to eq(expected_text)
        end

        it 'updates index of the next not-selected token' do
          expect(not_selected_token.reload.index).to eq(1)
        end

        it 'updates the user as the last editor of project' do
          expect(project.reload.last_editor).to eq(user)
        end

        it 'updates project as the last edited project by user' do
          expect(user.reload.last_edited_project).to eq(project)
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

      response '422', 'Given data invalid' do
        let(:Authorization) { authorization_header_for(user) }
        let(:token) do
          {
            token: {
              selected_token_ids: []
            }
          }
        end

        before do
          allow(TokensManager::Resizer::Preparers::TokenFromMultipleTokens).to receive(:perform)
          allow(TokensManager::Resizer::Processor).to receive(:perform)
        end

        schema '$ref' => '#/components/schemas/invalid_record'

        run_test!

        it 'does not run TokensManager::Resizer::Preparer' do
          expect(TokensManager::Resizer::Preparers::TokenFromMultipleTokens).not_to have_received(:perform)
        end

        it 'does not run TokensManager::Resizer::Processor' do
          expect(TokensManager::Resizer::Processor).not_to have_received(:perform)
        end
      end
    end
  end

  path '/api/v1/projects/{project_id}/tokens/{id}/split' do
    parameter name: 'project_id', in: :path, type: :string, description: 'project_id'
    parameter name: 'id', in: :path, type: :string, description: 'token_id'

    let(:project) do
      create(:project, :with_creator, witnesses: [Witness.new(siglum: 'A'), Witness.new(siglum: 'B')], creator: user)
    end
    let(:project_id) { project.id }
    let(:record) { create(:token, project:) }
    let(:id) { record.id }

    patch('Split token into two new tokens') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Splits given token into two new tokens.  ' \
                  'Only tokens from the projects created by the user are accessible. <br />' \
                  'Variants will be separated between two tokens based on user\'s choice to split'

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

      parameter name: :variants, in: :body, schema: {
        type:       :object,
        properties: {
          variants: {
            type:       :object,
            properties: {
              witness: {
                type:        :string,
                description: 'Witness value with splitting point'
              },
              t:       {
                type:        :string,
                description: 't value with splitting point'
              }
            }
          }
        },
        required:   %w[witness t]
      }

      before do
        record
        not_selected_token
      end

      let(:record) do
        create(:token, project:, index: 0, variants: [
                 build(:token_variant,
                       witness: 'A',
                       t:       'This is a nice text'),

                 build(:token_variant,
                       witness: 'B',
                       t:       'This is quite a bad text')
               ])
      end
      let(:not_selected_token) { create(:token, project:, index: 1) }

      let(:variants) do
        {
          variants: [
            {
              witness: 'A',
              t:       'This is{scissors} a nice text'
            },
            {
              witness: 'B',
              t:       'This is quite a b{scissors}ad text'
            }
          ]
        }
      end

      let(:params) { variants }

      response '200', 'Changes saved' do
        let(:Authorization) { authorization_header_for(user) }

        schema type:       :object,
               properties: {
                 message: {
                   type:    :string,
                   example: I18n.t('tokens.notifications.token_split')
                 }
               }

        run_test!

        before { project.reload }

        it 'saves the current user as last_editor of project' do
          expect(project.last_editor).to eq(user)
        end

        it 'updates number of project tokens' do
          expect(project.tokens.size).to eq(3)
        end

        it 'deletes source token' do
          expect(record.reload.deleted).to be(true)
        end

        it 'sets the first new token\'s index to source token\'s index' do
          first_token = project.tokens.reload.first
          expect(first_token.index).to eq(0)
        end

        it 'sets the second new token\'s index to source token\'s index incremented by one' do
          second_token = project.tokens.second
          expect(second_token.index).to eq(1)
        end

        context 'when splits variants to the first new token' do
          let(:first_token) { project.tokens.reload.first }

          it { expect(first_token.variants.first.witness).to eq('A') }
          it { expect(first_token.variants.first.t).to eq('This is') }
          it { expect(first_token.variants.second.witness).to eq('B') }
          it { expect(first_token.variants.second.t).to eq('This is quite a b') }
        end

        context 'when splits variants to the second new token' do
          let(:second_token) { project.tokens.reload.second }

          it { expect(second_token.variants.first.witness).to eq('A') }
          it { expect(second_token.reload.variants.first.t).to eq(' a nice text') }
          it { expect(second_token.variants.second.witness).to eq('B') }
          it { expect(second_token.variants.second.t).to eq('ad text') }
        end

        it 'updates index of the next not-selected token' do
          expect(not_selected_token.reload.index).to eq(2)
        end

        it 'updates the user as the last editor of project' do
          expect(project.reload.last_editor).to eq(user)
        end

        it 'updates project as the last edited project by user' do
          expect(user.reload.last_edited_project).to eq(project)
        end
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!
      end

      response '404', 'Project or token not found' do
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

        context 'when token not found' do
          let(:id) { 'invalid-id' }

          run_test!
        end
      end

      response '422', 'Given data invalid' do
        let(:Authorization) { authorization_header_for(user) }
        let(:variants) do
          {
            variants: [
              {
                witness: 'A',
                t:       'this is text'
              }
            ]
          }
        end

        before do
          allow(TokensManager::Splitter::Processor).to receive(:perform)
        end

        schema '$ref' => '#/components/schemas/invalid_record'

        run_test!

        it 'does not run TokensManager::Splitter::Processor' do
          expect(TokensManager::Splitter::Processor).not_to have_received(:perform)
        end
      end
    end
  end

  path '/api/v1/projects/{project_id}/tokens/edited' do
    get('Checks if tokens with given ids have comments, editorial remarks, or selected variants.') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Checks if tokens with given ids have comments, editorial remarks, or selected variants. ' \
                  'Only tokens from the projects created by the user are accessible.'

      parameter name:        :project_id, in: :path,
                schema:      {
                  type: :integer
                },
                required:    true,
                description: 'ID of the project'

      parameter name: :selected_token_ids, in: :path,
                schema: {
                  type: :array
                },
                required:   true,
                description: 'IDs of the selected tokens. All tokens must belong to the given project.'

      let!(:selected_token1) { create(:token, :one_grouped_variant, project:, index: 0) }
      let!(:selected_token2) { create(:token, project:, index: 1) }
      let(:selected_token_ids) { [selected_token1.id, selected_token2.id] }

      response '200', 'Tokens checked' do
        let(:Authorization) { authorization_header_for(user) }

        schema type:       :object,
               properties: {
                 comments:            {
                   type:        :boolean,
                   description: 'It is true if any of the given tokens has at least one comment'
                 },
                 editorial_remarks:   {
                   type:        :boolean,
                   description: 'It is true if any of the given tokens has an editorial remark'
                 },
                 variants_selections: {
                   type:        :boolean,
                   description: 'It is true if any of the given tokens has selected variant'
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
# rubocop:enable RSpec/MultipleMemoizedHelpers
# rubocop:enable RSpec/ScatteredSetup
