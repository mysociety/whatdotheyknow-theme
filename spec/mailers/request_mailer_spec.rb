# -*- encoding : utf-8 -*-
require 'spec_helper'

describe RequestMailer do

  describe "when mail to a user through RequestMailer" do

    let(:info_request) { FactoryBot.create(:info_request) }
    let(:mail) { RequestMailer.old_unclassified_updated(info_request) }

    before do
      # ToDo: find better way to add the theme's view path than this hack
      # (without the hack it doesn't use the theme's view customisations)
      RequestMailer.prepend_view_path(File.join(File.dirname(__FILE__), '..', '..', "lib/views"))
      allow(info_request).to receive(:display_status).and_return("refused.")
      allow(AlaveteliConfiguration).to receive(:site_name).and_return("Test")
    end

    it "appends the custom footer after the site team sign-off" do
      expected = <<-EOF.strip_heredoc
        -- the Test team


        ----------------------------------------------------------

        Help WDTK - https://www.whatdotheyknow.com/help/volunteers
        EOF
      expect(mail.body).to include(expected)
    end

  end

end
