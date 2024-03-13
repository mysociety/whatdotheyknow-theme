require_relative 'spec_helper'

RSpec.describe AuthorityOnlyResponseGatekeeper do
  let(:public_body) do
    FactoryBot.create(
      :public_body,
      id: 27,
      name: 'Cabinet Office',
      request_email: 'foi@localhost'
    )
  end

  let(:info_request) do
    FactoryBot.create(
      :info_request,
      public_body: public_body,
      allow_new_responses_from: 'authority_only'
    )
  end

  def receive_from(from)
    info_request.receive Mail.new(from: from), ''
  end

  it 'allows responses from main request email and extra addresses' do
    expect { receive_from('foi@localhost') }.to change {
      info_request.incoming_messages.count
    }.from(0).to(1)

    expect { receive_from('other@example.com') }.to_not change {
      info_request.incoming_messages.count
    }

    expect { receive_from('no-reply@cabinetoffice.ecase.co.uk') }.to change {
      info_request.incoming_messages.count
    }.from(1).to(2)
  end
end
