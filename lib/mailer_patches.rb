# Please arrange overridden classes alphabetically.
Rails.configuration.to_prepare do
  ContactMailer.class_eval do
    prepend VolunteerContactForm::MailerMethods
    prepend DataBreach::MailerMethods
  end

  RequestMailer.class_eval do
    prepend ExcelAnalyzer::RequestMailer
  end

  AlaveteliPro::SubscriptionMailer.class_eval do
    include CurrencyHelper

    def notify_price_increase(user, price_id)
      auto_generated_headers(user)

      subject = _('Changes to your {{pro_site_name}} subscription',
                  pro_site_name: pro_site_name)

      @user_name = user.name

      price = AlaveteliPro::Price.new(Stripe::Price.retrieve(price_id))
      @amount = format_currency(
        price.unit_amount_with_tax, no_cents_if_whole: true
      )
      @interval = price.recurring['interval']
      case @interval
      when 'month'; @intervally = 'monthly'
      when 'year'; @intervally = 'yearly'
      end

      mail_user(
        user,
        from: contact_for_user(@user),
        subject: subject
      )
    end
  end
end
