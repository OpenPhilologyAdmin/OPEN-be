# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/comments' do
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

    post('Creates a new comment for given token') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Creates a new comment'

      parameter name: 'project_id', in: :path, type: :integer, description: 'ID of the project', required: true
      parameter name: 'token_id', in: :path, type: :integer, description: 'ID of the token', required: true

      parameter name: :comment, in: :body, schema: {
        type:       :object,
        properties: {
          body: {
            type:        :string,
            maximum:     250,
            description: 'Body of the comment',
            example:     'This is a really nice comment.'
          }
        }, required: %w[body]
      }

      response(200, 'OK') do
        let(:Authorization) { authorization_header_for(user) }
        let(:comment) { create(:comment, body: 'This went well.', token:, user:) }

        schema '$ref' => '#/components/schemas/comment'

        run_test!
      end

      response '422', 'Comment data invalid' do
        let(:Authorization) { authorization_header_for(user) }
        let(:comment) do
          {
            comment:
                     {
                       body:    '',
                       user_id: nil
                     }
          }
        end

        schema '$ref' => '#/components/schemas/invalid_record'

        run_test!
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }
        let(:comment) { create(:comment, body: 'Dont forget about logins', token:, user:) }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!
      end

      response '404', 'Project not found' do
        let(:Authorization) { authorization_header_for(user) }
        let(:comment) { create(:comment, body: 'Not so nice.', token:, user:) }
        let(:project_id) { 'invalid-id' }

        schema '$ref' => '#/components/schemas/record_not_found'

        run_test!
      end
    end
  end

  path '/api/v1/projects/{project_id}/tokens/{token_id}/comments/{id}' do
    let(:user) { create(:user, :admin, :approved) }
    let(:user_id) { user.id }
    let(:project) { create(:project) }
    let(:project_id) { project.id }
    let(:token) { create(:token, project:) }
    let(:token_id) { token.id }

    put('Updates a comment') do
      tags 'Projects'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Updates a body of given comment'

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
      parameter name: :body, in: :body,
                schema: {
                  type:       :object,
                  properties: {
                    body: {
                      type:        :string,
                      maximum:     250,
                      description: 'Comment\'s body',
                      example:     'This is an updated body'
                    }
                  }
                }, required: %w[body]

      response '200', 'OK' do
        let(:Authorization) { authorization_header_for(user) }
        let(:comment) { create(:comment, body: 'Test body', token:, user:) }
        let(:id) { comment.id }
        let(:body) { { body: 'This is a new body' } }

        schema '$ref' => '#/components/schemas/comment'

        run_test!

        it 'updates a comment' do
          expect(comment.reload.body).to eq('This is a new body')
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
        let(:id) { create(:comment, body: 'Test body', token:, user:).id }

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
        let(:comment) { create(:comment, body: 'This is a nice comment', token:, user:) }
        let(:id) { comment.id }

        schema type:       :object,
               properties: {
                 message: {
                   type:    :string,
                   example: I18n.t('general.notifications.deleted')
                 }
               }

        run_test!

        it 'deletes a comment' do
          expect(comment.reload.deleted).to be(true)
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
        let(:id) { create(:comment, body: 'This is a nice comment', token:, user:).id }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!
      end

      response '403', 'Forbidden if current user doesn\'t match comment creator' do
        let(:Authorization) { authorization_header_for(user) }
        let(:id) { create(:comment, body: 'Fancy comment').id }

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
