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
        let(:Authorization) {} # rubocop:disable Lint/EmptyBlock
        let(:user) do
          {
            user: { email: 'email@example.com' }
          }
        end

        before do
          allow(User).to receive(:send_reset_password_instructions)
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
    end
  end
end
