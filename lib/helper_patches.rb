# Load our helpers
require 'helpers/user_helper'
require 'helpers/donation_helper'

Rails.configuration.to_prepare do
  ActionView::Base.send(:include, UserHelper)
  ActionView::Base.send(:include, DonationHelper)

  ApplicationHelper.class_eval do
    def is_contact_page?
      controller.controller_name == 'help' && controller.action_name == 'contact'
    end
  end

  AdminRequestsHelper.class_eval do
    def reason_text_immigration_correspondence(public_body = nil)
      text =
        "As it is personal correspondence which it wasn't appropriate " \
        "to send via our public website we have hidden it from other users. " \
        "You will still be able to view it while logged in to the site."
      if public_body && public_body.id == 3
        text +=
          "\n\n" \
          "You should contact the Home Office directly if you want to write " \
          "to them in relation to your, or others', individual " \
          "circumstances. The Home Office's direct email address is:"\
          "\n\n"  \
          "public.enquiries@homeoffice.gsi.gov.uk" \
          "\n\n" \
          "The Home Office also offer a range of contact forms via: " \
          "\n\n" \
          "https://www.gov.uk/government/organisations/home-office#org-contacts" \
          "\n\n" \
          "We understand that it can be very difficult to get a response " \
          "from the Home Office to personal immigration queries. If you are " \
          "in the UK we suggest writing to the Home Office via your local " \
          "Member of Parliament (MP), if you send your correspondence to " \
          "your MP, they or their office, can pass it on to the Home Office " \
          "and ensure you get a response. This has the benefit of " \
          "highlighting difficulties communicating with the Home Office " \
          "to MPs - who are in a position to address the systemic problems." \
          "\n\n" \
          "You can find and write to your MP via:" \
          "\n\n" \
          "http://www.writetothem.com"
      end
      text
    end
  end

end
