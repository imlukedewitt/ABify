# frozen_string_literal: true

require 'spec_helper'
require_relative '../../payloads/subscriptions/create_subscriptions'

RSpec.describe Payloads::Subscriptions::CreateSubscriptions do
  include FactoryBot::Syntax::Methods

  describe '.create_subscriptions' do
    context 'base subscription row' do
      it 'creates a payload with the correct keys' do
        row =  build(:create_subscription_row)
        payload = described_class.create_subscriptions(row)

        expect(payload).to be_a(Hash)
        expect(payload[:subscription]).to be_a(Hash)
        expect(payload[:subscription][:dunning_exempt]).to eq(row['dunning exempt'])
        expect(payload[:subscription][:import_mrr]).to eq(row['initial billing at'].nil?)
        expect(payload[:subscription][:customer_id]).to eq(row['customer id'])
        expect(payload[:subscription][:customer_reference]).to eq(row['customer reference']).or be_nil
        expect(payload[:subscription][:receives_invoice_emails]).to eq(row['receives invoice emails'])
        expect(payload[:subscription][:reference]).to eq(row['subscription reference'])
        expect(payload[:subscription][:currency]).to eq(row['currency'])
        expect(payload[:subscription][:payment_collection_method]).to eq(row['payment collection method'])
        expect(payload[:subscription][:previous_billing_at]).to eq(row['previous billing at'].to_s)
        expect(payload[:subscription][:next_billing_at]).to eq(row['next billing at'].to_s)
        expect(payload[:subscription][:initial_billing_at]).to eq(row['initial billing at'])
        expect(payload[:subscription][:canceled_at]).to eq(row['canceled at']).or eq(row['cancelled at'])
        expect(payload[:subscription][:activated_at]).to eq(row['activated at'])
        expect(payload[:subscription][:expires_at]).to eq(row['expires at'])
        expect(payload[:subscription][:net_terms]).to eq(row['net terms'])
        expect(payload[:subscription][:service_credit_balance]).to eq(row['service credit balance'])
        expect(payload[:subscription][:prepayment_balance]).to eq(row['prepayment balance'])
        expect(payload[:subscription][:product_handle]).to eq(row['product'])
        expect(payload[:subscription][:product_price_point_handle]).to eq(row['product price point']).or eq(row['product price point handle'])
        expect(payload[:subscription][:ref]).to eq(row['referral code'])
        expect(payload[:subscription][:payment_profile_id]).to eq(row['payment profile id']).or be_nil
        expect(payload[:subscription][:group]).to be_falsey
        expect(payload[:subscription][:coupon_codes]).to be_nil
        expect(payload[:subscription][:components]).to be_nil
      end
    end

    context 'grouped subscription row' do
      it 'creates a payload with group data' do
        row = build(:create_subscription_row, :grouped) 
        payload = described_class.create_subscriptions(row)
        expect(payload[:subscription][:group]).to be_a(Hash)
        expect(payload[:subscription][:group][:target][:type]).to eq(row['group payer'])
        expect(payload[:subscription][:group][:billing][:align_date]).to eq(row['align billing date'])
      end
    end

    context 'subscription row with a coupon' do
      it 'creates a payload with coupon data' do
        row = build(:create_subscription_row, :with_coupon)
        payload = described_class.create_subscriptions(row)
        expect(payload[:subscription][:coupon_codes].first).to eq(row['coupon 1'])
      end
    end

    context 'subscription row with a component' do
      it 'creates a payload with component data' do
        row = build(:create_subscription_row, :with_component)
        payload = described_class.create_subscriptions(row)

        expect(payload[:subscription][:components]).to be_a(Array)
        component = payload[:subscription][:components].first
        expect(component[:component_id]).to eq("handle:#{row['component 1']}")
        expect(component[:allocated_quantity]).to eq(row['component quantity 1'])
        expect(component[:price_point]).to eq("handle:#{row['component price point 1']}")
      end
    end

    context 'subscription row with per_unit component custom price' do
      it 'creates a payload with component custom price data' do
        row = build(:create_subscription_row, :with_component, :with_component_custom_price)
        payload = described_class.create_subscriptions(row)
        component = payload[:subscription][:components].first
        price = component[:custom_price][:prices].first
        overage_price = component[:custom_price][:overage_pricing][:prices].first
        expect(component[:custom_price][:pricing_scheme]).to eq(row['component custom price scheme 1'])
        expect(price[:starting_quantity]).to eq(1)
        expect(price[:ending_quantity]).to be_nil
        expect(price[:unit_price]).to eq(row['component per unit price 1'])
        expect(overage_price[:starting_quantity]).to eq(row['component 1 overage starting quantity 1'])
        expect(overage_price[:unit_price]).to eq(row['component 1 overage unit price 1'])
        expect(overage_price[:ending_quantity]).to eq(row['component 1 overage ending quantity 1'])
      end
    end

    context 'subscription row with tiered component custom price' do
      it 'creates a payload with component custom price data' do
        row = build(:create_subscription_row, :with_component, :with_component_custom_price)
        row['component custom price scheme 1'] = 'tiered'
        payload = described_class.create_subscriptions(row)
        component = payload[:subscription][:components].first
        price = component[:custom_price][:prices].first
        overage_price = component[:custom_price][:overage_pricing][:prices].first
        expect(component[:custom_price][:pricing_scheme]).to eq(row['component custom price scheme 1'])
        expect(price[:starting_quantity]).to eq(row['component 1 starting quantity 1'])
        expect(price[:ending_quantity]).to eq(row['component 1 ending quantity 1'])
        expect(price[:unit_price]).to eq(row['component 1 unit price 1'])
        expect(overage_price[:starting_quantity]).to eq(row['component 1 overage starting quantity 1'])
        expect(overage_price[:unit_price]).to eq(row['component 1 overage unit price 1'])
        expect(overage_price[:ending_quantity]).to eq(row['component 1 overage ending quantity 1'])
      end
    end

    context 'row with custom fields' do
      it 'creates a payload with custom field data' do
        row = build(:create_subscription_row, :with_custom_fields)
        payload = described_class.create_subscriptions(row)
        expect(payload[:subscription][:metafields]).to include('field1' => row['custom field [field1]'])
        expect(payload[:subscription][:metafields]).to include('field2' => row['custom field [field2]'])
      end
    end
  end
end
