module DonationHelper
  def show_donation_button?
    AlaveteliConfiguration::donation_url.present? &&
      !(feature_enabled?(:alaveteli_pro) && current_user && current_user.is_pro?)
  end

  def donate_now_link(content, options = {})
    utm_params = options.delete(:utm_params) || { utm_content: CGI::escape(content) }
    link_to _('Donate Now'),
      donation_url(utm_params),
      options
  end

  private

  def donation_url(options = {})
    AlaveteliConfiguration::donation_url + "?" << options.reverse_merge(
      :utm_source => 'whatdotheyknow.com',
      :utm_campaign => 'donation_drive_2016',
      :utm_medium => 'link'
    ).to_query
  end
end
