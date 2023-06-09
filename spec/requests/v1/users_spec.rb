# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/users' do
  path '/api/v1/users' do
    let(:user) { create(:user, :admin, :approved) }

    get('Retrieves list of users') do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Allows retrieving all users list. The users are sorted by the ' \
                  'registration date with the most records first.'

      response '200', 'Users can be retrieved' do
        let(:Authorization) { authorization_header_for(user) }

        before do
          create_list(:user, 3)
        end

        schema type:       :object,
               properties:
                           {
                             records: {
                               type:  :array,
                               items: { '$ref' => '#/components/schemas/user' }
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

    post('Creates new user account') do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description('Creates new account.')

      parameter name: :user, in: :body, schema: {
        type:       :object,
        properties: {
          user: {
            type:       :object,
            properties: {
              email:                 {
                type:    :string,
                example: 'email@example.com'
              },
              password:              {
                type:        :string,
                minimum:     8,
                maximum:     128,
                example:     'password1',
                description: 'must contain at least one digit and one letter'
              },
              password_confirmation: {
                type:        :string,
                example:     'password1',
                description: 'must match password'
              },
              name:                  {
                type:    :string,
                example: 'name'
              }
            },
            required:   %w[email password password_confirmation name]
          }
        }
      }

      response '200', 'User can be created' do
        let(:Authorization) { nil }
        let(:password) { attributes_for(:user)[:password] }
        let(:user) do
          { user:
                  {
                    email:                 Faker::Internet.email,
                    password:,
                    password_confirmation: password,
                    name:                  Faker::Name.name
                  } }
        end

        schema '$ref' => '#/components/schemas/user'

        run_test!
      end

      response '422', 'User data invalid' do
        let(:Authorization) { nil }
        let(:user) do
          { user:
                  {
                    email:                 Faker::Internet.email,
                    password:              '',
                    password_confirmation: '',
                    name:                  Faker::Name.name
                  } }
        end

        schema '$ref' => '#/components/schemas/invalid_record'

        run_test!
      end

      response '403', 'Not Authorized if logged in' do
        let(:user) { create(:user, :approved) }
        let(:Authorization) { authorization_header_for(user) }

        schema '$ref' => '#/components/schemas/forbidden_request'

        run_test!
      end
    end
  end

  path '/api/v1/users/{id}/approve' do
    let(:user) { create(:user, :admin, :approved) }
    let(:new_user) { create(:user, :not_approved) }
    let(:id) { new_user.id }
    let(:mailer_mock) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(NotificationMailer).to receive(:account_approved).and_return(mailer_mock)
      allow(mailer_mock).to receive(:deliver_later)
    end

    patch('Approves the user') do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      parameter name:        :id, in: :path,
                schema:      {
                  type: :integer
                },
                description: 'ID of user to be approved',
                required:    true
      description('Allows approving the new user account.')

      response '200', 'New user can be approved' do
        let(:Authorization) { authorization_header_for(user) }

        schema '$ref' => '#/components/schemas/user'

        run_test!

        it 'approves the new user' do
          expect(new_user.reload).to be_account_approved
        end

        context 'when the user has just been approved' do
          it 'sends a notification to user' do
            expect(NotificationMailer).to have_received(:account_approved)
            expect(mailer_mock).to have_received(:deliver_later)
          end
        end

        context 'when the user has already been approved' do
          let(:new_user) { create(:user, :approved) }

          it 'does not send a notification to user' do
            expect(NotificationMailer).not_to have_received(:account_approved)
            expect(mailer_mock).not_to have_received(:deliver_later)
          end
        end
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!
      end
    end
  end

  path '/api/v1/users/me' do
    let(:user) { create(:user, :admin, :approved) }

    get('Retrieves logged in user details') do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]

      response '200', 'User details can be retrieved' do
        let(:Authorization) { authorization_header_for(user) }

        schema '$ref' => '#/components/schemas/user'

        run_test!

        it 'returns details of logged in user' do
          parsed_response = JSON.parse(response.body, symbolize_names: true)
          expect(parsed_response[:id]).to eq(user.id)
        end
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!
      end
    end
  end

  path '/api/v1/users/{id}/last_edited_project' do
    let(:user) { create(:user, :admin, :approved) }
    let(:id) { user.id }

    get('Retrieves last edited project id by user') do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      parameter name: :id, in: :path,
                schema: {
                  type: :integer
                },
                description: 'User ID',
                required:    true

      response '200', 'Last edited project id can be retrieved' do
        let(:Authorization) { authorization_header_for(user) }

        schema type:       :object,
               properties: {
                 last_edited_project_id: {
                   type:     :integer,
                   nullable: true,
                   example:  123
                 }
               }

        run_test!

        it 'returns last edited project id by user' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response[:last_edited_project_id]).to eq(user.last_edited_project_id)
        end
      end

      response '401', 'Login required' do
        let(:Authorization) { nil }

        schema '$ref' => '#/components/schemas/login_required'

        run_test!
      end

      response '404', 'Record not found' do
        let(:Authorization) { authorization_header_for(user) }
        let(:id) { 'record-id' }

        schema '$ref' => '#/components/schemas/record_not_found'

        run_test!
      end
    end
  end
end
