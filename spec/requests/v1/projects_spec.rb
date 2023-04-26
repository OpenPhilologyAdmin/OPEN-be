# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/projects' do
  let(:not_accessible_project_id) { create(:project, :with_creator).id }

  path '/api/v1/projects' do
    let(:user) { create(:user, :admin, :approved) }
    get('Retrieves list of projects accessible by the user') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Allows retrieving list of correctly processed projects. The user can see only the projects ' \
                  'they created. The projects are sorted by the updated_at date with the most recently updated ' \
                  'records first.'

      response '200', 'Projects can be retrieved' do
        let(:Authorization) { authorization_header_for(user) }

        before do
          create_list(:project, 2, :status_processed)
          create(:project, :status_invalid)
        end

        schema type:       :object,
               properties:
                           {
                             records: {
                               type:  :array,
                               items: { '$ref' => '#/components/schemas/project' }
                             },
                             count:   {
                               type:        :integer,
                               description: 'Number of all records',
                               example:     50
                             }
                           }

        run_test!

        it 'returns only successfully processed projects' do
          records = response.parsed_body['records']
          records.each do |record|
            expect(record['status']).to eq('processed')
          end
        end
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!
      end
    end

    post('Creates a new project') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Creates a new project. The project data is imported using background job. ' \
                  'Please check `GET /api/v1/projects/{id}` endpoint to review the import result.'

      parameter name: :project, in: :body, schema: {
        type:       :object,
        properties:
                    {
                      project: {
                        type:       :object,
                        properties: {
                          name:                 {
                            type:        :string,
                            maximum:     50,
                            description: 'Project name',
                            example:     'Project name'
                          },
                          source_file:          {
                            type:       :object,
                            properties: {
                              data: {
                                type:        :string,
                                format:      :byte,
                                description: 'Base64 encoded file in the following format: ' \
                                             '`data:text/plain;base64,[base64 data]`. ' \
                                             '[Click here](https://developer.mozilla.org/en-US/docs/Web/HTTP/' \
                                             'Basics_of_HTTP/Data_URLs) for more details on formatting.'
                              }
                            }
                          },
                          default_witness:      {
                            type:        :string,
                            example:     'A',
                            nullable:    true,
                            description: 'It is required only when then source file is text/plain'
                          },
                          default_witness_name: {
                            type:        :string,
                            example:     'Name',
                            nullable:    true,
                            maximum:     50,
                            description: 'Optional, can be provided when then source file is text/plain'
                          }
                        },
                        required:   %w[name source_file]
                      }
                    }
      }

      before do
        allow(ImportProjectJob).to receive(:perform_now)
      end

      response '200', 'Project can be created' do
        let(:Authorization) { authorization_header_for(user) }
        let(:encoded_source_file) do
          Base64.encode64(Rails.root.join('spec/fixtures/sample_project.txt').read)
        end
        let(:source_file) do
          {
            data: "data:text/plain;base64,#{encoded_source_file}"
          }
        end
        let(:default_witness_name) { 'Witness name' }
        let(:project) do
          {
            project:
                     {
                       name:                 Faker::Lorem.word,
                       default_witness_name:,
                       default_witness:      'A',
                       source_file:
                     }
          }
        end

        schema '$ref' => '#/components/schemas/project'

        run_test!

        it 'queues importing project data' do
          expect(ImportProjectJob).to have_received(:perform_now)
            .with(Project.last.id, user.id, default_witness_name)
        end

        it 'updates the user as the last editor of project' do
          expect(Project.last.last_editor).to eq(user)
        end

        it 'updates project as the last edited project by user' do
          expect(user.reload.last_edited_project).to eq(Project.last)
        end
      end

      response '422', 'Project data invalid' do
        let(:Authorization) { authorization_header_for(user) }
        let(:project) do
          {
            project:
                     {
                       name:        nil,
                       source_file: nil
                     }
          }
        end

        schema '$ref' => '#/components/schemas/invalid_record'

        run_test!

        it 'does not queue importing project data' do
          expect(ImportProjectJob).not_to have_received(:perform_now)
        end
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }
        let(:project) { nil }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!

        it 'does not queue importing project data' do
          expect(ImportProjectJob).not_to have_received(:perform_now)
        end
      end
    end
  end

  path '/api/v1/projects/{id}' do
    let(:user) { create(:user, :admin, :approved) }
    let(:record) { create(:project, :with_creator, creator: user) }
    let(:id) { record.id }

    get('Retrieves project details') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Get selected project details. Only projects created by the user are accessible.'

      parameter name: :id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of project'

      response '200', 'Project found' do
        let(:Authorization) { authorization_header_for(user) }

        schema '$ref' => '#/components/schemas/project'

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
          let(:id) { 'invalid-id' }

          run_test!
        end

        context 'when project is not accessible' do
          let(:id) { not_accessible_project_id }

          run_test!
        end
      end
    end

    put('Updates project details') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Update selected project details. Only projects created by the user are accessible.'

      parameter name: :id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of project'
      parameter name: :project, in: :body, schema: {
        type:       :object,
        properties:
                    {
                      project: {
                        type:       :object,
                        properties: {
                          name: {
                            type:        :string,
                            maximum:     50,
                            description: 'Project name',
                            example:     'Project name'
                          }
                        },
                        required:   %w[name]
                      }
                    }
      }

      let(:project) do
        {
          project:
                   {
                     name: 'New name'
                   }
        }
      end

      response '200', 'Project updated' do
        let(:Authorization) { authorization_header_for(user) }

        schema '$ref' => '#/components/schemas/project'

        run_test!

        before { record.reload }

        it 'updates the project' do
          project[:project].each do |key, value|
            expect(record.send(key)).to eq(value)
          end
        end

        it 'updates the user as the last editor of project' do
          expect(record.last_editor).to eq(user)
        end

        it 'updates project as the last edited project by user' do
          expect(user.reload.last_edited_project).to eq(record)
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
          let(:id) { 'invalid-id' }

          run_test!
        end

        context 'when project is not accessible' do
          let(:id) { not_accessible_project_id }

          run_test!
        end
      end

      response '422', 'Project data invalid' do
        let(:Authorization) { authorization_header_for(user) }
        let(:project) do
          {
            project:
                     {
                       name: nil
                     }
          }
        end

        schema '$ref' => '#/components/schemas/invalid_record'

        run_test!
      end
    end

    delete('Deletes the project') do
      let(:record) { create(:project) }
      let(:id) { record.id }

      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Deletes the project. Only projects created by the user are accessible.'

      parameter name: :id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of project'

      response '200', 'Project successfully deleted' do
        let(:user) { create(:project_role, :owner, project: record).user }
        let(:Authorization) { authorization_header_for(user) }

        schema type:       :object,
               properties: {
                 message: {
                   type:    :string,
                   example: I18n.t('general.notifications.deleted')
                 }
               }

        run_test!

        it 'deletes the project' do
          expect(Project).not_to exist(id:)
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
          let(:id) { 'invalid-id' }

          run_test!
        end

        context 'when project is not accessible' do
          let(:id) { not_accessible_project_id }

          run_test!
        end
      end
    end
  end

  path '/api/v1/projects/{id}/export' do
    let(:user) { create(:user, :admin, :approved) }
    let(:record) { create(:project, :with_creator, creator: user) }
    let(:id) { record.id }

    put('Export project to file') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Allows saving the project to a file. Only projects created by the user are accessible.'

      parameter name: :id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of project'

      parameter name: :project, in: :body, schema: {
        type:       :object,
        properties:
                    {
                      project: {
                        type:       :object,
                        properties: {
                          significant_readings:   {
                            type:        :boolean,
                            description: 'Significant readings enabled'
                          },
                          insignificant_readings: {
                            type:        :boolean,
                            description: 'Insignificant readings enabled'
                          },
                          footnote_numbering:     {
                            type:        :boolean,
                            description: 'Footnote numbering enabled'
                          }
                        },
                        required:   %i[
                          significant_readings insignificant_readings footnote_numbering
                        ]
                      }
                    }
      }

      let(:project) do
        {
          project:
                   {
                     significant_readings:   true,
                     insignificant_readings: true,
                     footnote_numbering:     true
                   }
        }
      end

      response '200', 'File successfully generated' do
        let(:Authorization) { authorization_header_for(user) }

        schema '$ref' => '#/components/schemas/exported_project'

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
          let(:id) { 'invalid-id' }

          run_test!
        end

        context 'when project is not accessible' do
          let(:id) { not_accessible_project_id }

          run_test!
        end
      end

      response '422', 'Given options are invalid' do
        let(:Authorization) { authorization_header_for(user) }
        let(:project) do
          {
            project:
                     {
                       significant_readings:       nil,
                       insignificant_readings:     nil,
                       footnote_numbering:         nil,
                       selected_reading_separator: ']',
                       readings_separator:         ',',
                       sigla_separator:            ':'
                     }
          }
        end

        schema '$ref' => '#/components/schemas/invalid_record'

        run_test!
      end
    end
  end
end
