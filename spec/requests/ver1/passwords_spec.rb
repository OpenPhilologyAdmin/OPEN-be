# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'v1/passwords', type: :request do
  path '/api/v1/users/password' do
    post 'Sends the reset password email' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'If email can be found in the database, the reset password email will be sent.'
      parameter name: :user, in: :body, schema: { '$ref' => '#/components/schemas/user_email' }

      response '200', 'Reset password sent' do
        let(:Authorization) { nil }
        let(:requester) { create(:user, :admin, :approved) }
        let(:user) do
          {
            user: { email: requester.email }
          }
        end

        before do
          allow(User).to receive(:send_reset_password_instructions).and_return(requester)
        end

        schema type:       :object,
               properties: {
                 message: {
                   type:    :string,
                   example: I18n.t('devise.passwords.send_paranoid_instructions')
                 }
               }

        run_test!

        it 'triggers User.send_reset_password_instructions' do
          expect(User).to have_received(:send_reset_password_instructions)
        end
      end

      response '422', 'Invalid or empty email address given' do
        let(:Authorization) { nil }
        let(:user) do
          {
            user: { email: 'invalid' }
          }
        end

        schema '$ref' => '#/components/schemas/invalid_record'

        run_test!

        it 'returns only email related errors' do
          parsed_response = JSON.parse(response.body, symbolize_names: true)
          expect(parsed_response.keys).to match_array(%i[email])
        end
      end
    end

    put 'Sets new password' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description 'Updating the password using reset_password_token'
      parameter name: :user, in: :body,
                schema: { '$ref' => '#/components/schemas/user_reset_password' }

      let(:user) do
        user  = create(:user, :approved)
        token = user.send_reset_password_instructions
        {
          user:
                {
                  reset_password_token:  token,
                  password:,
                  password_confirmation: password
                }
        }
      end

      response '200', 'Password updated' do
        let(:Authorization) { nil }
        let(:password) { attributes_for(:user)[:password] }

        header 'Authorization',
               schema:      { type: :string },
               description: 'The JWT token for user with the following format: ' \
                            'Bearer {token}'

        schema type:       :object,
               properties: {
                 message: {
                   type:    :string,
                   example: I18n.t('devise.passwords.updated')
                 }
               }

        run_test!
      end

      response '401', 'Not confirmed/approved yet' do
        let(:Authorization) { nil }
        let(:password) { attributes_for(:user)[:password] }

        schema type: :object, properties: {
          error: {
            type:        :string,
            description: 'Specifies why the user cannot be signed in after updating their password: ' \
                         "\"#{I18n.t('devise.failure.unconfirmed')}\", " \
                         "\"#{I18n.t('devise.failure.not_approved')}\".",
            example:     I18n.t('devise.failure.unconfirmed')
          }
        }

        context 'when the user has not confirmed their email yet' do
          let(:user) do
            user  = create(:user, :not_confirmed)
            token = user.send_reset_password_instructions
            {
              user:
                    {
                      reset_password_token:  token,
                      password:,
                      password_confirmation: password
                    }
            }
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

        context 'when the user has confirmed their email but has not been approved' do
          let(:user) do
            user  = create(:user, :not_approved)
            token = user.send_reset_password_instructions
            {
              user:
                    {
                      reset_password_token:  token,
                      password:,
                      password_confirmation: password
                    }
            }
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
      end

      response '422', 'Invalid password or reset password token' do
        let(:Authorization) { nil }
        let(:password) { '' }

        schema '$ref' => '#/components/schemas/invalid_record'

        run_test!
      end
    end
  end
end
