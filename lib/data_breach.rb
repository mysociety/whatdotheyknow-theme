module DataBreach
  class Report
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :url, :string
    attribute :special_category_or_criminal_offence_data, :boolean
    attribute :message, :string
    attribute :contact_email, :string
    attribute :dpo_contact_email, :string
    attribute :is_public_body, :boolean
    attribute :current_user

    validates_presence_of :url, :message => N_("Please enter the URL of the page where the data breach occurred")
    validates_presence_of :message, :message => N_("Please describe the data breach")
    validates_presence_of :contact_email, message: N_('Please include your email address'), unless: :current_user

    validates :is_public_body, inclusion: { in: [true, false], message: N_("Please confirm whether you are reporting on behalf of the public body responsible for the data breach") }
  end

  module ControllerMethods
    def report_a_data_breach
      @report = Report.new
    end

    def report_a_data_breach_handle_form_submission
      @report = Report.new(report_params_with_current_user)
      if @report.valid?
        # TODO: Handle a successful submission
        ContactMailer.data_breach(@report, current_user).deliver_now

        # Redirect to a thank you page
        flash[:notice] = _('Thank you for reporting a data breach. We will review your report and get back to you if we need any more information.')
        redirect_to help_report_a_data_breach_thank_you_path
      else
        render :report_a_data_breach
      end
    end

    def report_a_data_breach_thank_you; end

    private

    def report_params
      permittable_attrs = %i[
        url
        special_category_or_criminal_offence_data
        message
        contact_email
        dpo_contact_email
        is_public_body
      ]

      params.require(:data_breach_report).permit(permittable_attrs)
    end

    def report_params_with_current_user
      report_params.merge(current_user: current_user)
    end
  end

  module MailerMethods
    def data_breach(report, logged_in_user)
      @report = report
      @logged_in_user = logged_in_user

      # From is an address we control so that strict DMARC senders don't get
      # refused
      from = MailHandler.address_from_name_and_email(
        'WhatDoTheyKnow.com data breach report', blackhole_email
      )

      if report.dpo_contact_email
        set_reply_to_headers(nil, 'Reply-To' => report.dpo_contact_email)
      end

      # Set a header so we can filter in the mailbox
      headers['X-WDTK-Contact'] = 'wdtk-data-breach-report'

      mail(
        from: from,
        to: contact_from_name_and_email,
        subject: _('New data breach report [{{reference}}]',
                   reference: case_reference('BR'))
      )
    end
  end
end
