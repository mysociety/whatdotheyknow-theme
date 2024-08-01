# Please arrange overridden classes alphabetically.
Rails.configuration.to_prepare do
  ContactMailer.class_eval do
    prepend VolunteerContactForm::MailerMethods
    prepend DataBreach::MailerMethods
  end

  RequestMailer.class_eval do
    prepend ExcelAnalyzer::RequestMailer
  end
end
