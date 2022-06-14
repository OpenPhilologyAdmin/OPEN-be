# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/projects', type: :request do
  path '/api/v1/projects' do
    let(:user) { create(:user, :admin, :approved) }

    post('Creates a new project') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Creates a new project.'

      parameter name: :project, in: :body, schema: {
        type:       :object,
        properties: {
          name:        {
            type:    :string,
            example: 'Project name'
          },
          source_file: {
            type:    :string,
            format:  :binary,
            example: "Base64 encoded file in the following format: 'data:text/plain;base64,[base64 data]'"
          }
        }
      }

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

        schema type:       :object,
               properties: {
                 message: {
                   type:  :array,
                   items: {
                     type:    :string,
                     example: 'Name can\'t be blank'
                   }
                 }
               }

        run_test!
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }
        let(:project) { nil }

        schema type:       :object,
               properties: {
                 message: {
                   type:    :string,
                   example: I18n.t('general.errors.login_required')
                 }
               }

        run_test!
      end
    end
  end
end
