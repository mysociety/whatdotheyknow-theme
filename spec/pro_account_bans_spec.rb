require_relative 'spec_helper'
require 'stripe_mock'

RSpec.describe ProAccountBans, feature: :pro_pricing do
  around { |example| StripeMock.mock(&example) }

  let(:stripe_helper) { StripeMock.create_test_helper }

  describe '#update_stripe_customer' do
    let(:bans_config) { [{ foo: 'bar' }] }
    let(:card_params) { { number: '4242424242424242', address_zip: 'AB1 1AB' } }

    let(:pro_account) { FactoryBot.build(:pro_account, token: stripe_token) }
    let(:customer) { Stripe::Customer.create(id: 'test_cus_123') }

    let(:stripe_token) do
      token_id = stripe_helper.generate_card_token(card_params)
      Stripe::Token.retrieve(token_id)
    end

    before do
      allow(pro_account).to receive(:bans_config).and_return(bans_config)
      allow(pro_account).to receive(:stripe_customer).and_return(customer)
      allow(Stripe::Customer).to receive(:update).and_return(customer)
    end

    context 'with a valid token' do
      it 'updates the Stripe customer successfully' do
        expect(pro_account.update_stripe_customer).to be_truthy
        expect(Stripe::Customer).to have_received(:update)
      end
    end

    context 'when the account is banned' do
      it 'raises card error' do
        allow(pro_account).to receive(:pro_account_banned?).and_return(true)
        expect { pro_account.update_stripe_customer }.to raise_error(
          ProAccount::CardError, "The card issuer couldn't authorize payment."
        )
      end
    end

    context 'when the card fingerprint is banned' do
      let(:bans_config) { [{ fingerprint: 'eXWMGVNbMZcworZC' }] }

      it 'raises card error' do
        expect { pro_account.update_stripe_customer }.to raise_error(
          ProAccount::CardError, "The card issuer couldn't authorize payment."
        )
      end
    end

    context 'when the card address_zip is banned' do
      let(:bans_config) { [{ address_zip: 'AB11AB' }] }

      it 'raises card error' do
        expect { pro_account.update_stripe_customer }.to raise_error(
          ProAccount::CardError, "The card issuer couldn't authorize payment."
        )
      end
    end

    context 'when ban config has string keys' do
      let(:bans_config) { [{ 'address_zip' => 'AB11AB' }] }

      it 'raises card error' do
        expect { pro_account.update_stripe_customer }.to raise_error(
          ProAccount::CardError, "The card issuer couldn't authorize payment."
        )
      end
    end

    context 'when ban config has lowercase values' do
      let(:card_params) { { address_zip: 'AB11AB' } }
      let(:bans_config) { [{ address_zip: 'ab11ab' }] }

      it 'raises card error' do
        expect { pro_account.update_stripe_customer }.to raise_error(
          ProAccount::CardError, "The card issuer couldn't authorize payment."
        )
      end
    end

    context 'when address_zip has spaces' do
      let(:card_params) { { address_zip: 'AB1 1A B' } }
      let(:bans_config) { [{ address_zip: 'A B11AB' }] }

      it 'raises card error' do
        expect { pro_account.update_stripe_customer }.to raise_error(
          ProAccount::CardError, "The card issuer couldn't authorize payment."
        )
      end
    end

    context 'when the card address_zip is not provided' do
      let(:card_params) { { address_zip: nil } }

      it 'does not raise error' do
        expect { pro_account.update_stripe_customer }.to_not raise_error
      end
    end
  end
end
