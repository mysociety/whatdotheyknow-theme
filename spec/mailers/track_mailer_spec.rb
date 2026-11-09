require_relative '../spec_helper'

RSpec.describe TrackMailer do
  describe '.event_digest' do
    let(:mail) { TrackMailer.event_digest(FactoryBot.create(:user), []) }

    it 'explains the unsubscribe links' do
      body = mail.body.to_s
      expect(body).to include(
        'Please click on the link below to cancel or alter these emails.'
      )
      expect(body).to include(
        'Please click on the link below to stop these emails.'
      )
    end
  end
end
