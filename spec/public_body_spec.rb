require_relative 'spec_helper'

RSpec.describe PublicBody do
  describe '.excluded_calculated_home_page_domains' do
    subject { described_class.excluded_calculated_home_page_domains }

    it 'includes default global domains' do
      is_expected.to include('aol.com')
    end

    it 'includes expected localise domains' do
      is_expected.to include('aol.co.uk')
    end
  end
end
