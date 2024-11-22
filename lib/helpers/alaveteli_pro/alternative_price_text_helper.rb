module AlaveteliPro::AlternativePriceTextHelper
  def alternative_price_text(price)
    amount = format_currency(
      price.unit_amount_with_tax, no_cents_if_whole: true
    )

    if interval(price) == 'day' && interval_count(price) == 1
      _('or {{amount}} daily', amount: amount)
    elsif interval(price) == 'week' && interval_count(price) == 1
      _('or {{amount}} weekly', amount: amount)
    elsif interval(price) == 'month' && interval_count(price) == 1
      _('or {{amount}} monthly', amount: amount)
    elsif interval(price) == 'year' && interval_count(price) == 1
      _('or {{amount}} annually', amount: amount)
    else
      _('or {{amount}} every {{interval}}',
        amount: amount,
        interval: pluralize_interval(price))
    end
  end
end
