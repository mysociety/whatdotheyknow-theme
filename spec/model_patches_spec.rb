require_relative 'spec_helper'

RSpec.describe InfoRequest, "when creating an email subject for a request" do

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

end

RSpec.describe InfoRequest do

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

RSpec.describe InfoRequest, "when calculating the status for a school" do

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

RSpec.describe PublicBody do

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

RSpec.describe User::EmailAlerts do
  describe '#disable' do
    context 'with the internal admin user' do
      let(:user) { double(name: 'Admin', url_name: 'internal_admin_user') }

      it 'prevents alerts being disabled' do
        expect { described_class.new(user).disable }.
          to raise_error('Email alerts should not be disabled for Admin!')
      end
    end
  end
end
