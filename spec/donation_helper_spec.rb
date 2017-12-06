# If defined, ALAVETELI_TEST_THEME will be loaded in config/initializers/theme_loader
ALAVETELI_TEST_THEME = 'whatdotheyknow-theme'
require 'spec_helper'

describe DonationHelper, type: :helper do
  include DonationHelper

  describe '#donate_now_link' do
    before do
      allow(AlaveteliConfiguration).to receive(:donation_url).
        and_return('http://example.com/foo')
    end

    it 'outputs anchor tag with escaped utm_content param' do
      expect(donate_now_link('foo bar')).to have_xpath(
        '//a[@href="http://example.com/foo?' \
          'utm_campaign=donation_drive_2016&' \
          'utm_content=foo%2Bbar&' \
          'utm_medium=link&' \
          'utm_source=whatdotheyknow.com"]'
      )
    end

    it 'can set class attribute' do
      link = donate_now_link('content', class: 'foo')
      anchor = Nokogiri::HTML(link).xpath('//a')[0]
      expect(anchor['class']).to eq('foo')
    end

  end

end
