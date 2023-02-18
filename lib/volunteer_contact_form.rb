module VolunteerContactForm
  TASKS = {
    admin: _('Administration tasks such as updating our database of public authorities'),
    comms: _('Communications tasks such as updating public notes on the site'),
    legal: _('Legal tasks such as being involved in reviewing GDPR requests'),
    user_support: _('User assistance tasks, such as responding to requests for help and advice in using WhatDoTheyKnow or making requests'),
    campaign: _('Campaign-focused tasks such as helping to shape and put into effect  our activism around FOI'),
    other: _('Other - please let us know what type of task you would like to take on'),
    not_sure: _('I’m not sure yet')
  }.freeze

  module ControllerMethods
    def contact
      super

      return unless contact_volunteer_form?
      return unless params[:submitted_contact_form]
      return if flash.now[:error] # return if reCAPTCHA hasn't passed

      # Volunteer form spam tends to have repeated text in the why, experience,
      # or anything_else fields, if this happens then fake sending form
      if contact_validator.errors.added?(:base, :repeated_text)
        flash[:notice] = _("Your message has been sent. Thank you for " \
                           "getting in touch! We'll get back to you soon.")
        redirect_to frontpage_url
      end
    end

    private

    def contact_validator
      return super unless contact_volunteer_form?

      @contact_validator ||= ContactVolunteerValidator.new(contact_params)
    end

    def contact_mailer
      return super unless contact_volunteer_form?

      ContactMailer.volunteer_message(contact_validator, @user)
    end

    def contact_params
      return super unless contact_volunteer_form?

      params.require(:contact).except(:comment).permit(
        :name, :email, :why, :experience, :anything_else, :age,
        tasks: TASKS.keys
      ).tap do |p|
        p[:tasks] = p[:tasks].to_h.inject([]) do |m, (_, v)|
          m << v if v != '0'
          m
        end
      end
    end

    def contact_volunteer_form?
      params[:current_form] == 'wdtk-volunteer'
    end
  end

  module MailerMethods
    def volunteer_message(contact, logged_in_user)
      @contact = contact
      # Setup a case reference so we can find this in the mailbox
      @contact_caseref = "VAPP/#{Time.now.strftime('%Y%m%d')}-#{SecureRandom.base36(4).upcase}"
      @logged_in_user = logged_in_user

      # From is an address we control so that strict DMARC senders don't get
      # refused
      from = MailHandler.address_from_name_and_email(
        contact.name, blackhole_email
      )
      reply_to_address = MailHandler.address_from_name_and_email(
        contact.name, contact.email
      )
      set_reply_to_headers(nil, 'Reply-To' => reply_to_address)

      # Set a header so we can filter in the mailbox
      headers['X-WDTK-Contact'] = 'wdtk-volunteer'
      headers['X-WDTK-CaseRef'] = @contact_caseref

      mail(
        from: from,
        to: contact_from_name_and_email,
        subject: _('Message from {{name}} via WDTK volunteer contact form [{{reference}}]',
                   name: contact.name,
                   reference: @contact_caseref)
      )
    end
  end

  class ContactVolunteerValidator
    include ActiveModel::Validations

    attr_accessor :name, :email, :why, :tasks, :experience, :anything_else,
                  :age, :comment

    validates_presence_of :name, :message => N_("Please enter your name")
    validates_presence_of :email, :message => N_("Please enter your email address")
    validates_presence_of :why, :message => N_("Please tell us why you're interested in becoming a volunteer")
    validates_presence_of :experience, :message => N_("Please list any relevant experience")
    validates_presence_of :age, :message => N_("Please confim your age")
    validate :email_format
    validate :repeated_text

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    private

    def email_format
      return if MySociety::Validate.is_valid_email(email)
      errors.add(:email, _("Email doesn't look like a valid address"))
    end

    def repeated_text
      return if why != experience || why != anything_else
      errors.add(:base, :repeated_text)
    end
  end
end
