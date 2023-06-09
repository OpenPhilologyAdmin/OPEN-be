# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/sessions', type: :request do
  path '/api/v1/users/sign_in' do
    context 'when user credentials are empty' do
      let(:user_params) do
        {
          user: {
            password: '',
            email:    ''
          }
        }
      end
      let(:expected_response) do
        {
          error: I18n.t('devise.failure.invalid', authentication_keys: 'email')
        }.stringify_keys
      end

      before do
        post '/api/v1/users/sign_in', params: user_params
      end

      it 'returns correct error message' do
        expect(JSON.parse(response.body)).to eq(expected_response)
      end
    end

    post 'Signs the user in' do
      tags 'Authorization'
      consumes 'application/json'
      produces 'application/json'
      description 'Signs the user in using email and password combination'
      parameter name: :user, in: :body, schema: { '$ref' => '#/components/schemas/credentials' }

      response '201', 'User has been successfully signed in' do
        let(:Authorization) { nil }
        let(:password) { attributes_for(:user)[:password] }
        let(:user) do
          user = create(:user, :approved, password:)
          { user: { email: user.email, password: } }
        end

        header 'Authorization',
               schema:      { type: :string },
               description: 'The JWT token for user with the following format: ' \
                            'Bearer {token}'

        schema '$ref' => '#/components/schemas/user'

        run_test!
      end

      response '401', 'Login credentials are incorrect, email not confirmed or user has not been approved yet' do
        schema type: :object, properties: {
          error: {
            type:        :string,
            description: 'Specifies why the user cannot be logged in: ' \
                         "\"#{I18n.t('devise.failure.invalid', authentication_keys: 'email')}\", " \
                         "\"#{I18n.t('devise.failure.unconfirmed')}\", " \
                         "\"#{I18n.t('devise.failure.not_approved')}\"",
            example:     I18n.t('devise.failure.invalid', authentication_keys: 'email')
          }
        }

        context 'when credentials are incorrect' do
          let(:user) { create(:user) }
          let(:expected_response) do
            { error: I18n.t('devise.failure.invalid', authentication_keys: 'email') }
          end

          run_test!

          it 'returns correct message' do
            parsed_response = JSON.parse(response.body, symbolize_names: true)
            expect(parsed_response).to eq(expected_response)
          end
        end

        context 'when the user not confirmed their email address yet' do
          let(:password) { attributes_for(:user)[:password] }
          let(:user) do
            user = create(:user, :not_confirmed, :not_approved, password:)
            { user: { email: user.email, password: } }
          end
          let(:expected_response) do
            { error: I18n.t('devise.failure.unconfirmed') }
          end

          run_test!

          it 'returns correct message' do
            parsed_response = JSON.parse(response.body, symbolize_names: true)
            expect(parsed_response).to eq(expected_response)
          end
        end

        context 'when the user has not been approved yet' do
          let(:password) { attributes_for(:user)[:password] }
          let(:user) do
            user = create(:user, :not_approved, password:)
            { user: { email: user.email, password: } }
          end
          let(:expected_response) do
            { error: I18n.t('devise.failure.not_approved') }
          end

          run_test!

          it 'returns correct message' do
            parsed_response = JSON.parse(response.body, symbolize_names: true)
            expect(parsed_response).to eq(expected_response)
          end
        end

        context 'when login credentials empty' do
          let(:user) do
            { user: { email: '', password: '' } }
          end
          let(:expected_response) do
            { error: I18n.t('devise.failure.invalid', authentication_keys: 'email') }
          end

          run_test!

          it 'returns correct message' do
            parsed_response = JSON.parse(response.body, symbolize_names: true)
            expect(parsed_response).to eq(expected_response)
          end
        end
      end
    end
  end

  path '/api/v1/users/sign_out' do
    delete 'Logs out the user' do
      tags 'Authorization'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Signs out the user and invalidates the token.'

      response '204', 'User has been signed out ' do
        let(:Authorization) { authorization_header_for(user) }
        let(:user) { create(:user) }

        it 'returns a valid 204 response' do |example|
          submit_request(example.metadata)
          assert_response_matches_metadata(example.metadata)
        end

        it 'updates JwtDenylist' do |example|
          expect { submit_request(example.metadata) }.to change { JwtDenylist.all.size }.by(1)
        end
      end
    end
  end
end
