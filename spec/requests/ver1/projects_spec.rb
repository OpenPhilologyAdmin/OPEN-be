# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/projects', type: :request do
  path '/api/v1/projects' do
    let(:user) { create(:user, :admin, :approved) }
    get('Retrieves paginated list of projects') do
      let(:page) { 1 }
      let(:items) { 10 }

      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description('Allows retrieving all projects list.')

      response '200', 'Projects can be retrieved' do
        let(:Authorization) { authorization_header_for(user) }

        parameter name:        :items, in: :query,
                  schema:      {
                    type:    :integer,
                    example: 1,
                    default: 10
                  },
                  required:    false,
                  description: 'Number of records per page'

        parameter name:        :page, in: :query,
                  schema:      {
                    type:    :integer,
                    default: 1,
                    example: 1
                  },
                  required:    false,
                  description: 'Page number'

        before do
          create_list(:project, 3)
        end

        schema type:       :object,
               properties:
                           {
                             records:      {
                               type:  :array,
                               items: { '$ref' => '#/components/schemas/project' }
                             },
                             count:        {
                               type:        :integer,
                               description: 'Number of all records',
                               example:     50
                             },
                             current_page: {
                               type:        :integer,
                               description: 'Current page',
                               example:     1,
                               default:     1
                             },
                             pages:        {
                               type:        :integer,
                               description: 'Number of all pages',
                               example:     5
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
      description 'Creates a new project.'

      parameter name: :project, in: :body, schema: {
        type:       :object,
        properties: {
          name:                 {
            type:        :string,
            maximum:     50,
            description: 'Project name',
            example:     'Project name'
          },
          source_file:          {
            type:        :string,
            format:      :byte,
            description: 'Base64 encoded file in the following format: `data:text/plain;base64,[base64 data]`. ' \
                         '[Click here](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URLs) ' \
                         'for more details on formatting.'
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

      before do
        allow(ImportProjectJob).to receive(:perform_now)
      end

      response '200', 'Project can be created' do
        let(:Authorization) { authorization_header_for(user) }
        let(:encoded_source_file) do
          Base64.encode64(File.read(Rails.root.join('spec/fixtures/sample_project.txt')))
        end
        let(:source_file) { "data:text/plain;base64,#{encoded_source_file}" }
        let(:project) do
          {
            project:
                     {
                       name:        Faker::Lorem.word,
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
    let(:id) { create(:project).id }

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
          expect(Project.where(id:)).to be_empty
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
