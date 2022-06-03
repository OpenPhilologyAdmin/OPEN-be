# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'confirmation', type: :request do
  path '/api/v1/users/confirmation' do
    post 'Re-sends the confirmation email' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      response '200', 'Email confirmation sent' do
        description 'The confirmation email will be sent to user if email exists in the database.'
        let(:user) { { email: 'email@example.com' } }

        before do
          allow(User).to receive(:send_confirmation_instructions)
        end

        parameter name:   :user,
                  in:     :body,
                  type:   :object,
                  schema: {
                    type:       :object,
                    properties: {
                      email: {
                        type:    :string,
                        example: 'example@example.com'
                      }
                    }
                  }

        schema type:       :object,
               properties: {
                 message: {
                   type:    :string,
                   example: I18n.t('devise.confirmations.send_paranoid_instructions')
                 }
               }

        run_test!

        it 'triggers User.send_confirmation_instructions method' do
          expect(User).to have_received(:send_confirmation_instructions)
        end
      end
    end

    get 'Confirms user\'s email' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :confirmation_token, in: :query, schema: {
        type:    :string,
        example: 'confirmation_token'
      }

      response '200', 'Email confirmed' do
        let(:user) { create(:user, :not_confirmed) }
        let(:confirmation_token) { user.confirmation_token }

        schema type:       :object,
               properties: {
                 message: {
                   type:    :string,
                   example: I18n.t('devise.confirmations.confirmed')
                 }
               }

        run_test!

        it 'confirms the user' do
          expect(user.reload).to be_confirmed
        end
      end

      response '422', 'Invalid confirmation_token' do
        let(:confirmation_token) { '' }

        schema type:       :object,
               properties: {
                 message: {
                   type:    :array,
                   example: ["Confirmation token can't be blank"]
                 }
               }

        run_test!
      end
    end
  end
end
