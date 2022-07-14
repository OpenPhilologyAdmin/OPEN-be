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

        parameter name: :user, in: :body, schema: { '$ref' => '#/components/schemas/user_email' }

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
      parameter name: :confirmation_token, in: :query,
                schema: { type: :string },
                description: 'Confirmation token from the URL',
                required: true

      let(:notifier_mock) { instance_double(SignupNotifier) }

      before do
        allow(SignupNotifier).to receive(:new).and_return(notifier_mock)
        allow(notifier_mock).to receive(:perform!)
      end

      response '200', 'Email confirmed' do
        let(:user) { create(:user, :not_confirmed) }
        let(:confirmation_token) { user.confirmation_token }

        schema type:       :object,
               properties: {
                 message: {
                   type:        :string,
                   description: 'Specifies whether the user can already sign in, or needs to wait for Admin to ' \
                                'approve their account: ' \
                                "\"#{I18n.t('devise.confirmations.confirmed')}\", " \
                                "\"#{I18n.t('devise.confirmations.confirmed_but_not_approved')}\".",
                   example:     I18n.t('devise.confirmations.confirmed_but_not_approved')
                 }
               }

        run_test!

        context 'when account has already been accepted by the admin' do
          let(:user) { create(:user, :not_confirmed, :approved) }
          let(:expected_response) do
            { message: I18n.t('devise.confirmations.confirmed') }
          end

          it 'returns correct message' do
            parsed_response = JSON.parse(response.body, symbolize_names: true)
            expect(parsed_response).to eq(expected_response)
          end

          it 'confirms the user' do
            expect(user.reload).to be_confirmed
          end

          it 'does not notify the admins' do
            expect(SignupNotifier).not_to have_received(:new)
            expect(notifier_mock).not_to have_received(:perform!)
          end
        end

        context 'when account has not been accepted by the admin yet' do
          let(:user) { create(:user, :not_confirmed, :not_approved) }
          let(:expected_response) do
            { message: I18n.t('devise.confirmations.confirmed_but_not_approved') }
          end

          it 'returns correct message' do
            parsed_response = JSON.parse(response.body, symbolize_names: true)
            expect(parsed_response).to eq(expected_response)
          end

          it 'confirms the user' do
            expect(user.reload).to be_confirmed
          end

          it 'notifies the admins' do
            expect(SignupNotifier).to have_received(:new)
            expect(notifier_mock).to have_received(:perform!)
          end
        end
      end

      response '422', 'Invalid/blank confirmation_token or already confirmed' do
        schema '$ref' => '#/components/schemas/invalid_record'

        context 'when token is invalid/blank' do
          let(:confirmation_token) { '' }

          run_test!

          it 'does not notify the admins' do
            expect(SignupNotifier).not_to have_received(:new)
            expect(notifier_mock).not_to have_received(:perform!)
          end
        end

        context 'when the user already confirmed their account' do
          let(:user) { create(:user, :not_confirmed) }
          let(:confirmation_token) { user.confirmation_token }
          let(:expected_response) do
            {
              confirmation_token: ["Email #{I18n.t('errors.messages.already_confirmed')}"]
            }
          end

          before { user.confirm }

          run_test!

          it 'assigns all errors to :confirmation_token field' do
            parsed_response = JSON.parse(response.body, symbolize_names: true)
            expect(parsed_response).to eq(expected_response)
          end
        end
      end
    end
  end
end
