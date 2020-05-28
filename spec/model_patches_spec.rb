# If defined, ALAVETELI_TEST_THEME will be loaded in config/initializers/theme_loader
ALAVETELI_TEST_THEME = 'whatdotheyknow-theme'
require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','..','spec','spec_helper'))

describe UserInfoRequestSentAlert, "when patched by the whatdotheyknow-theme" do

  it 'should allow an alert type of "survey_1"' do
    info_request_sent_alert = UserInfoRequestSentAlert.new(:alert_type => 'survey_1')
    expect(info_request_sent_alert).to be_valid
  end

end

describe User, 'when patched by whatdotheyknow-theme' do

  describe '#can_send_survey?' do
    let(:user) { FactoryBot.create(:user) }
    subject { user.can_send_survey? }

    before do
      allow(AlaveteliConfiguration).
        to receive(:send_survey_mails).and_return(true)
    end

    context 'a survey has not been sent to an active user' do

      before do
        allow(user).to receive(:survey).
          and_return(double('survey', :already_done? => false))
      end

      it { is_expected.to eq(true) }

    end

    context 'a survey has already been sent' do

      before do
        allow(user).to receive(:survey).
          and_return(double('survey', :already_done? => true))
      end

      it { is_expected.to eq(false) }

    end

    context 'the user is not active' do

      before do
        allow(user).to receive(:active?).and_return(false)
      end

      it { is_expected.to eq(false) }

    end

  end

end

describe RequestMailer, 'when patched by whatdotheyknow-theme' do

  context 'when SEND_SURVEY_MAILS is set' do

    before do
      allow(AlaveteliConfiguration).to receive(:send_survey_mails).and_return(true)
      InfoRequest.destroy_all
      ActionMailer::Base.deliveries = []
    end

    def get_surveyable_request(user=nil)
      info_request = if user
        FactoryBot.create(:info_request, :user => user)
      else
        FactoryBot.create(:info_request)
      end
      info_request.created_at = Time.now - (2.weeks + 1.hour)
      info_request.save!
      info_request
    end

    it 'sends survey alerts' do
        expect(RequestMailer).to receive(:alert_survey)
        RequestMailer.alert_new_response_reminders
    end

    context 'when there is a requester who has not been sent a survey alert' do

      it 'sends a survey alert' do
        allow_any_instance_of(User).to receive(:survey).
          and_return(double('survey', :already_done? => false))
        get_surveyable_request
        RequestMailer.alert_new_response_reminders
        expect(ActionMailer::Base.deliveries.size).to eq(1)
      end

      it 'records the sending of the alert' do
        allow_any_instance_of(User).to receive(:survey).
          and_return(double('survey', :already_done? => false))
        info_request = get_surveyable_request
        RequestMailer.alert_new_response_reminders
        expect(info_request.user.user_info_request_sent_alerts.size).
          to eq(1)
      end

    end

    context 'when there is a requester who has been sent a survey alert' do

      it 'does not send a survey alert' do
        allow_any_instance_of(User).to receive(:survey).
          and_return(double('survey', :already_done? => false))
        info_request = get_surveyable_request
        info_request.user.user_info_request_sent_alerts.
          create(:alert_type => 'survey_1',
                  :info_request_id => info_request.id)
        RequestMailer.alert_new_response_reminders
        expect(ActionMailer::Base.deliveries.size).to eq(0)
      end

    end

    context 'when there is a requester who has previously filled in the survey' do

      it 'does not send a survey alert' do
        allow_any_instance_of(User).to receive(:survey).
          and_return(double('survey', :already_done? => true))
        get_surveyable_request
        RequestMailer.alert_new_response_reminders
        expect(ActionMailer::Base.deliveries.size).to eq(0)
      end
    end

    context 'when a user has made multiple qualifying requests' do

      it 'does not send multiple alerts' do
        allow_any_instance_of(User).to receive(:survey).
          and_return(double('survey', :already_done? => false))
        request = get_surveyable_request
        get_surveyable_request(request.user)
        RequestMailer.alert_new_response_reminders
        expect(ActionMailer::Base.deliveries.size).to eq(1)
      end
    end

    context 'when a user is inactive' do

      it 'does not send a survey alert' do
        allow_any_instance_of(User).to receive(:survey).
          and_return(double('survey', :already_done? => false))
        allow_any_instance_of(User).to receive(:active?).
          and_return(false)
        get_surveyable_request
        RequestMailer.alert_new_response_reminders
        expect(ActionMailer::Base.deliveries.size).to eq(0)
      end

    end

  end

  context 'when SEND_SURVEY_MAILS is not set' do

    before do
      allow(AlaveteliConfiguration).to receive(:send_survey_mails).and_return(false)
    end

    it 'does not send survey alerts ' do
      expect(RequestMailer).not_to receive(:alert_survey)
      RequestMailer.alert_new_response_reminders
    end

  end

end

describe InfoRequest, "when creating an email subject for a request" do

  it 'should create a standard request subject' do
    info_request = FactoryBot.build(:info_request)
    expect(info_request.email_subject_request).
      to eq("Freedom of Information request - #{info_request.title}")
  end

  it 'should create a special request subject for requests to the General Register Office' do
    info_request = FactoryBot.build(:info_request)
    allow(info_request.public_body).to receive(:url_name).and_return('general_register_office')
    expect(info_request.email_subject_request).
      to eq("Freedom of Information request GQ - #{info_request.title}")
  end

  it 'should be able to create an email subject request for a batch request template without
      a public body' do
    info_request = FactoryBot.build(:info_request)
    info_request.public_body = nil
    info_request.is_batch_request_template = true
    expect(info_request.email_subject_request).
      to eq("Freedom of Information request - #{info_request.title}")
  end

end

describe InfoRequest do

  describe '#late_calculator' do
    subject { InfoRequest.new(:public_body => FactoryBot.build(:public_body)) }

    it 'returns a DefaultLateCalculator' do
      expect(subject.late_calculator).
        to be_instance_of(DefaultLateCalculator)
    end

    it 'caches the late calculator' do
      expect(subject.late_calculator).to equal(subject.late_calculator)
    end

    it 'returns a SchoolLateCalculator if the associated body is a school' do
      subject.public_body = FactoryBot.build(:public_body, :tag_string => 'school')
      expect(subject.late_calculator).
        to be_instance_of(SchoolLateCalculator)
    end

  end

end

describe InfoRequest, "when calculating the status for a school" do

  before do
    @ir = info_requests(:naughty_chicken_request)
    @ir.public_body.tag_string = "school"
    expect(@ir.public_body.is_school?).to eq(true)
  end

  it "has expected sent date" do
    expect(@ir.last_event_forming_initial_request.outgoing_message.last_sent_at.strftime("%F")).to eq('2007-10-14')
  end

  it "has correct due date" do
    expect(@ir.date_response_required_by.strftime("%F")).to eq('2007-11-09')
  end

  it "has correct very overdue after date" do
    expect(@ir.date_very_overdue_after.strftime("%F")).to eq('2008-01-11') # 60 working days for schools
  end

  it "isn't overdue on due date (20 working days after request sent)" do
    allow(Time).to receive(:now).and_return(Time.utc(2007, 11, 9, 23, 59))
    expect(@ir.calculate_status).to eq('waiting_response')
  end

  it "is overdue a day after due date (20 working days after request sent)" do
    allow(Time).to receive(:now).and_return(Time.utc(2007, 11, 10, 00, 01))
    expect(@ir.calculate_status).to eq('waiting_response_overdue')
  end

  it "is still overdue 40 working days after request sent" do
    allow(Time).to receive(:now).and_return(Time.utc(2007, 12, 10, 23, 59))
    expect(@ir.calculate_status).to eq('waiting_response_overdue')
  end

  it "is still overdue the day after 40 working days after request sent" do
    allow(Time).to receive(:now).and_return(Time.utc(2007, 12, 11, 00, 01))
    expect(@ir.calculate_status).to eq('waiting_response_overdue')
  end

  it "is still overdue 60 working days after request sent" do
    allow(Time).to receive(:now).and_return(Time.utc(2008, 01, 11, 23, 59))
    expect(@ir.calculate_status).to eq('waiting_response_overdue')
  end

  it "is very overdue the day after 60 working days after request sent" do
    allow(Time).to receive(:now).and_return(Time.utc(2008, 01, 12, 00, 01))
    expect(@ir.calculate_status).to eq('waiting_response_very_overdue')
  end

end

describe PublicBody do

  describe '.extract_domain_from_email' do

    it 'extracts the domain part of a valid email address' do
      result = PublicBody.
        extract_domain_from_email('some.email+address@example.com')
      expect(result).to eq('example.com')
    end

    it 'returns nil if the email is invalid' do
      result = PublicBody.
        extract_domain_from_email('invalid.email+address.example.com')
      expect(result).to be_nil
    end

    it 'replaces various uk-specific government domains' do
      emails = ['person@example.gsi.gov.uk',
                'person@example.x.gov.uk',
                'person@example.pnn.gov.uk']

      emails.each do |email|
        result = PublicBody.extract_domain_from_email(email)
        expect(result).to eq('example.gov.uk')
      end
    end

    it 'does not replace addresses similar to uk-specific government domains' do
      emails = ['attacker@example.gov.gsi.uk',
                'attacker@example.gov.x.uk',
                'attacker@example.gov.pnn.uk',
                'attacker@example.gsi.gov.uk.example.com']

      emails.each do |email|
        result = PublicBody.extract_domain_from_email(email)
        expect(result).to_not eq('example.gov.uk')
      end
    end

  end

end
