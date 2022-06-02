# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
require 'swagger_helper'

RSpec.describe 'v1/users', type: :request do
  path '/api/v1/users' do
    let(:user) { create(:user, :admin, :approved) }

    get('Retrieves paginated list of users') do
      let(:page) { 1 }
      let(:items) { 10 }

      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      description('Allows retrieving all users list.')

      response '200', 'Users can be retrieved' do
        let(:Authorization) { authorization_header_for(user) }

        parameter name: :items, in: :query, schema: {
          type:     :integer,
          required: false,
          example:  'Number of records per page'
        }

        parameter name: :page, in: :query, schema: {
          type:     :integer,
          required: false,
          example:  'Page number'
        }

        before do
          create_list(:user, 3)
        end

        schema type:       :object,
               properties:
                           {
                             records:      {
                               type:  :array,
                               items: { '$ref' => '#/components/schemas/user' }
                             },
                             count:        {
                               type:        :integer,
                               description: 'Number of all records',
                               example:     50
                             },
                             current_page: {
                               type:        :integer,
                               description: 'Current page',
                               example:     1
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
      parameter name: :id, in: :path, schema: {
        type: :integer
      }
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
# rubocop:enable RSpec/MultipleMemoizedHelpers
