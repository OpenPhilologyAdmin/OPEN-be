# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/projects', type: :request do
  path '/api/v1/projects' do
    let(:user) { create(:user, :admin, :approved) }
    get('Retrieves list of projects') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Allows retrieving all projects list. The projects are sorted by the ' \
                  'updated_at date with the most recently updated records first.'

      response '200', 'Projects can be retrieved' do
        let(:Authorization) { authorization_header_for(user) }

        before do
          create_list(:project, 3)
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
          Base64.encode64(File.read(Rails.root.join('spec/fixtures/sample_project.txt')))
        end
        let(:source_file) do
          {
            data: "data:text/plain;base64,#{encoded_source_file}"
          }
        end
        let(:project) do
          {
            project:
                     {
                       name:            Faker::Lorem.word,
                       default_witness: 'A',
                       source_file:
                     }
          }
        end

        schema '$ref' => '#/components/schemas/project'

        run_test!

        it 'queues importing project data' do
          expect(ImportProjectJob).to have_received(:perform_now)
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
    let(:record) { create(:project) }
    let(:id) { record.id }

    get('Retrieves project details') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Get selected project details.'

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
        let(:id) { 'invalid-id' }

        schema '$ref' => '#/components/schemas/record_not_found'

        run_test!
      end
    end

    put('Updates project details') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Update selected project details.'

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

        it 'saves the current user as last_editor of project' do
          expect(record.last_editor).to eq(user)
        end

        it 'updates the project' do
          project[:project].each do |key, value|
            expect(record.send(key)).to eq(value)
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
        let(:id) { 'invalid-id' }

        schema '$ref' => '#/components/schemas/record_not_found'

        run_test!
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
      description 'Deletes the project. Available only for project creators.'

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

      response '403', 'Request forbidden if not created the project' do
        let(:Authorization) { authorization_header_for(user) }

        schema '$ref' => '#/components/schemas/forbidden_request'

        run_test!
      end

      response '404', 'Project not found' do
        let(:Authorization) { authorization_header_for(user) }
        let(:id) { 'invalid-id' }

        schema '$ref' => '#/components/schemas/record_not_found'

        run_test!
      end
    end
  end
end
