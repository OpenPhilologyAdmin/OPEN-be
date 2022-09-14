# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/comments', type: :request do
  path '/api/v1/projects/{project_id}/tokens/{token_id}/comments' do
    let(:user) { create(:user, :admin, :approved) }
    let(:user_id) { user.id }
    let(:project) { create(:project) }
    let(:project_id) { project.id }
    let(:token) { create(:token, project:) }
    let(:token_id) { token.id }

    get('Retrieves all the comments for given token') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'List of comments'

      parameter name: 'project_id', in: :path, type: :integer, description: 'ID of the project', required: true
      parameter name: 'token_id', in: :path, type: :integer, description: 'ID of the token', required: true

      response(200, 'OK') do
        let(:Authorization) { authorization_header_for(user) }

        before do
          create(:comment, body: 'I am working')
        end

        schema type:  :array,
               items: { '$ref' => '#/components/schemas/comment' }

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

    delete('Deletes specified comment') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description('Deletes specified comment')

      parameter name: :project_id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of the project'
      parameter name: :token_id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of the token'
      parameter name: :id, in: :path,
                schema: {
                  type: :integer
                },
                required: true,
                description: 'ID of the comment'

      response '200', 'OK' do
        let(:Authorization) { authorization_header_for(user) }
        let(:comment) { create(:comment, body: 'Very nice comment') }

        schema type:       :object,
               properties: {
                 message: {
                   type:    :string,
                   example: I18n.t('general.notifications.deleted')
                 }
               }

        run_test!
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!
      end

      response '403', 'Forbidden if current user doesn\'t match comment creator' do
        let(:Authorization) { authorization_header_for(user) }
        let(:project) { create(:project, witnesses_number: 1) }

        schema '$ref' => '#/components/schemas/forbidden_request'

        run_test!
      end

      response '404', 'Project or comment not found' do
        let(:Authorization) { authorization_header_for(user) }
        let(:id) { 'invalid-id' }

        schema '$ref' => '#/components/schemas/record_not_found'

        run_test!
      end
    end
  end
end
