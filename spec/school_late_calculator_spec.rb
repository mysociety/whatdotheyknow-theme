# -*- encoding : utf-8 -*-
# If defined, ALAVETELI_TEST_THEME will be loaded in config/initializers/theme_loader
ALAVETELI_TEST_THEME = 'whatdotheyknow-theme'
require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','..','spec','spec_helper'))

describe SchoolLateCalculator do

  describe '.description' do

    it 'returns the human description' do
      desc = %q(UK Schools have an extra 20 days to respond to FOI requests)
      expect(described_class.description).to eq(desc)
    end

  end

  describe '#reply_late_after_days' do

    it 'returns the value set in config/general.yml' do
      allow(AlaveteliConfiguration).
        to receive(:reply_late_after_days).and_return(7)
      expect(subject.reply_late_after_days).to eq(7)
    end

  end

  describe '#reply_very_late_after_days' do

    it 'returns 60' do
      expect(subject.reply_very_late_after_days).to eq(60)
    end

  end

end
