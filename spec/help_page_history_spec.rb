require_relative 'spec_helper'

RSpec.describe HelpPageHistory do
  describe '#commits_url' do
    subject { described_class.new(template).commits_url }

    context 'with a custom help page' do
      let(:template) do
        double(short_identifier: 'lib/themes/whatdotheyknow-theme/lib/views/' \
                                 'help/house_rules.html.erb')
      end

      it do
        is_expected.to eq('https://github.com/mysociety/whatdotheyknow-theme/' \
                          'commits/master/lib/views/help/house_rules.html.erb')
      end
    end
  end
end
