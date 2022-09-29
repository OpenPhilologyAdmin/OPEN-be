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
                description: 'ID of the project'

      response '200', 'Witnesses can be retrieved' do
        let(:Authorization) { authorization_header_for(user) }

        schema type:       :object,
               properties:
                           {
                             records: {
                               type:  :array,
                               items: { '$ref' => '#/components/schemas/witness' }
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

    post('Adds a new witness to the specified project') do
      let(:witness) do
        { witness:
                   {
                     name:   Faker::Name.name,
                     siglum: 'Siglum'
                   } }
      end

      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Adds a new witness to the project.'

      parameter name: :project_id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of the project'
      parameter name: :witness, in: :body,
                schema: { '$ref' => '#/components/schemas/witness_create' }

      response '200', 'Witnesses created' do
        let(:Authorization) { authorization_header_for(user) }

        schema '$ref' => '#/components/schemas/witness'

        run_test!
      end

      response '422', 'Witness data invalid' do
        let(:Authorization) { authorization_header_for(user) }
        let(:witness) do
          { witness:
                     {
                       name:   Faker::Name.name,
                       siglum: ''
                     } }
        end

        schema '$ref' => '#/components/schemas/invalid_record'

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

  # rubocop:disable RSpec/ScatteredSetup
  path '/api/v1/projects/{project_id}/witnesses/{id}' do
    let(:user) { create(:user, :admin, :approved) }
    let(:project) { create(:project) }
    let(:edited_witness) { project.witnesses.last }
    let(:id) { edited_witness.id }
    let(:project_id) { project.id }
    let(:witness) do
      {
        witness:
                 {
                   name:    Faker::Lorem.characters(number: 10),
                   default: true
                 }
      }
    end

    put('Updates the specified witness') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Update the given witness.'

      parameter name: :project_id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of the project'
      parameter name: :id, in: :path,
                schema: {
                  type: :string
                },
                required: true,
                description: 'ID of the edited witness'
      parameter name: :witness, in: :body,
                schema: { '$ref' => '#/components/schemas/witness_update' }

      before do
        allow(WitnessesManager::Updater).to receive(:perform).and_call_original
      end

      response '200', 'Witnesses updated' do
        let(:Authorization) { authorization_header_for(user) }

        schema '$ref' => '#/components/schemas/witness'

        run_test!

        before { project.reload }

        it 'changes the value of project default_witness as well' do
          expect(project.default_witness).to eq(id)
        end

        it 'saves the current user as last_editor of project' do
          expect(project.last_editor).to eq(user)
        end

        it 'runs the WitnessesManager::Updater' do
          expect(WitnessesManager::Updater).to have_received(:perform)
        end
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!
      end

      response '404', 'Project or witness not found' do
        let(:Authorization) { authorization_header_for(user) }
        let(:id) { 'invalid-id' }

        schema '$ref' => '#/components/schemas/record_not_found'

        run_test!
      end

      response '422', 'Witness is invalid' do
        let(:Authorization) { authorization_header_for(user) }
        let(:witness) do
          {
            witness:
                     {
                       name: Faker::Lorem.characters(number: 60)
                     }
          }
        end

        schema '$ref' => '#/components/schemas/invalid_record'

        run_test!

        it 'runs the WitnessesManager::Updater' do
          expect(WitnessesManager::Updater).to have_received(:perform)
        end
      end
    end

    delete('Deletes the specified witness and its token variants') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description('Deletes the given witness. It also deletes all token variants for this witness. ' \
                  'If any of the token variants was selected, the selection would be removed as well. <br>' \
                  'If the witness was the default one, the **first** of the remaining witnesses would ' \
                  'be a new default witness. <br>' \
                  '**It is not possible to delete witness if there are no other witnesses.**')

      parameter name: :project_id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of the project'
      parameter name: :id, in: :path,
                schema: {
                  type: :string
                },
                required: true,
                description: 'ID of the removed witness'

      before do
        allow(WitnessesManager::Remover).to receive(:perform).and_call_original
      end

      response '200', 'Witness removed' do
        let(:Authorization) { authorization_header_for(user) }

        schema type:       :object,
               properties: {
                 message: {
                   type:    :string,
                   example: I18n.t('general.notifications.deleted')
                 }
               }

        run_test!

        it 'runs the WitnessesManager::Remover' do
          expect(WitnessesManager::Remover).to have_received(:perform).with(
            project:, siglum: id, user:
          )
        end

        it 'saves the current user as last_editor of project' do
          expect(project.reload.last_editor).to eq(user)
        end
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!
      end

      response '403', 'Forbidden if there are no other witnesses' do
        let(:Authorization) { authorization_header_for(user) }
        let(:project) { create(:project, witnesses_number: 1) }

        schema '$ref' => '#/components/schemas/forbidden_request'

        run_test!

        it 'does not run the WitnessesManager::Remover' do
          expect(WitnessesManager::Remover).not_to have_received(:perform)
        end
      end

      response '404', 'Project or witness not found' do
        let(:Authorization) { authorization_header_for(user) }
        let(:id) { 'invalid-id' }

        schema '$ref' => '#/components/schemas/record_not_found'

        run_test!
      end
    end
  end
  # rubocop:enable RSpec/ScatteredSetup
end
