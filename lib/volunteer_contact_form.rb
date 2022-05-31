module VolunteerContactForm
  TASKS = {
    admin: _('Administration tasks such as updating our database of public authorities'),
    comms: _('Communications tasks such as blog writing or updating public notes on the site'),
    legal: _('Legal tasks such as being involved in reviewing GDPR requests'),
    user_support: _('User assistance tasks, such as responding to requests for help and advice in using WhatDoTheyKnow or making requests'),
    campaign: _('Campaign-focused tasks such as helping to shape and put into effect  our activism around FOI'),
    other: _('Other - please let us know what type of task you would like to take on'),
    not_sure: _('I’m not sure yet')
  }.freeze

  module ControllerMethods
    private

    def contact_validator
      return super unless contact_volunteer_form?

      ContactVolunteerValidator.new(contact_params)
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
      params[:current_form] == 'wdtk_volunteer'
    end
  end

  module MailerMethods
    def volunteer_message(contact, logged_in_user)
      @contact = contact
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

      mail(
        from: from,
        to: contact_from_name_and_email,
        subject: _('Message from WDTK volunteer contact form')
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

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    private

    def email_format
      unless MySociety::Validate.is_valid_email(email)
        errors.add(:email, _("Email doesn't look like a valid address"))
      end
    end
  end
end
