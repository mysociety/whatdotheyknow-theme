# Please arrange overridden classes alphabetically.
Rails.configuration.to_prepare do
  ContactMailer.class_eval do
    prepend VolunteerContactForm::MailerMethods
  end
end
