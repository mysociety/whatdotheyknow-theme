# If defined, ALAVETELI_TEST_THEME will be loaded in config/initializers/theme_loader
ALAVETELI_TEST_THEME = 'whatdotheyknow-theme'
require 'spec_helper'

describe DonationHelper, type: :helper do
  include DonationHelper

  describe '#show_donation_button?' do
    subject { show_donation_button? }

    context 'without donation URL' do
      it { is_expected.to eq false }
    end

    context 'with donation URL' do
      before do
        allow(AlaveteliConfiguration).to receive(:donation_url).
          and_return('http://example.com')
      end

      context 'Pro not enabled' do
        it { is_expected.to eq true }
      end

      context 'with pro enabled' do
        before(:each) do
          allow(AlaveteliFeatures.backend).
            to receive(:enabled?).with(:alaveteli_pro).and_return(true)
        end

        context 'no current user' do
          let(:current_user) { nil }
          it { is_expected.to eq true }
        end

        context 'current user is not a Pro' do
          let(:current_user) { FactoryBot.create(:user) }
          it { is_expected.to eq true }
        end

        context 'current user is a Pro' do
          let(:current_user) { FactoryBot.create(:pro_user) }
          it { is_expected.to eq false }
        end
      end
    end

  end

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

    it 'outputs anchor tag with custom utm params' do
      params = { utm_campaign: 'new_campaign', utm_content: 'content',
                 utm_medium: 'paper', utm_source: 'example.com' }

      expect(donate_now_link('foo bar', utm_params: params)).to have_xpath(
        '//a[@href="http://example.com/foo?' \
          'utm_campaign=new_campaign&' \
          'utm_content=content&' \
          'utm_medium=paper&' \
          'utm_source=example.com"]'
      )
    end

    it 'can set class attribute' do
      link = donate_now_link('content', class: 'foo')
      anchor = Nokogiri::HTML(link).xpath('//a')[0]
      expect(anchor['class']).to eq('foo')
    end

  end

end
