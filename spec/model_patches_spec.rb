# If defined, ALAVETELI_TEST_THEME will be loaded in config/initializers/theme_loader
ALAVETELI_TEST_THEME = 'whatdotheyknow-theme'
require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','..','spec','spec_helper'))

describe UserInfoRequestSentAlert, "when patched by the whatdotheyknow-theme" do

  it 'should allow an alert type of "survey_1"' do
    info_request_sent_alert = UserInfoRequestSentAlert.new(:alert_type => 'survey_1')
    info_request_sent_alert.valid?.should == true
  end

end
