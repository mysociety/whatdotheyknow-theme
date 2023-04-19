# Please arrange overridden classes alphabetically.
Rails.configuration.to_prepare do
  ContactMailer.class_eval do
    prepend VolunteerContactForm::MailerMethods
  end

  TrackMailer.class_eval do
    def mail(*args)
      super(*args) do |format|
        format.text { render 'event_digest_with_survey' }
      end
    end
  end
end
