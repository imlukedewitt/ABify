# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../models/config'

RSpec.describe Config do
  subject { described_class.new(api_key: '123', subdomain: 'test') }

  describe '#initialize' do
    it 'sets the domain to chargify.com by default' do
      expect(subject.domain).to eq('chargify.com')
    end
  end

  describe '#base_url' do
    it 'returns the base url' do
      expect(subject.base_url).to eq('https://test.chargify.com')
    end
  end
end
