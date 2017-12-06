module DonationHelper
  def donate_now_link(content, options = {})
    link_to _('Donate Now'),
      donation_url(:utm_content => CGI::escape(content)),
      options
  end

  private

  def donation_url(options = {})
    AlaveteliConfiguration::donation_url + "?" << options.merge(
      :utm_source => 'whatdotheyknow.com',
      :utm_campaign => 'donation_drive_2016',
      :utm_medium => 'link'
    ).to_query
  end
end
