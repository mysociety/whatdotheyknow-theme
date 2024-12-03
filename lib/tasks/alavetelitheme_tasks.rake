# desc "Explaining what the task does"
# task :alavetelitheme do
#   # Task goes here
# end

namespace :subscriptions do
  task send_price_update_notice: :environment do
    old_price, new_price = *load_prices

    scope = Stripe::Subscription.list(price: old_price.id)
    count = scope.data.size

    scope.auto_paging_each.with_index do |subscription, index|
      coupon = subscription.discount&.coupon
      next if coupon&.percent_off == 100 && coupon&.duration == "forever"

      user = User.joins(:pro_account).find_by(
        pro_accounts: { stripe_customer_id: subscription.customer }
      )
      next unless user

      AlaveteliPro::SubscriptionMailer.notify_price_increase(
        user, new_price.id
      ).deliver_later

      erase_line
      print "Queued email to WDTK Pro subscribers: #{index + 1}/#{count}"
    end

    erase_line
    puts "Queued email to WDTK Pro subscribers: completed"
  end

  def load_prices
    old_price = Stripe::Price.retrieve(ENV['OLD_PRICE']) if ENV['OLD_PRICE']
    new_price = Stripe::Price.retrieve(ENV['NEW_PRICE']) if ENV['NEW_PRICE']

    if !old_price
      puts "ERROR: Can't find OLD_PRICE"
      exit 1
    elsif !new_price
      puts "ERROR: Can't find NEW_PRICE"
      exit 1
    elsif old_price.recurring != new_price.recurring
      puts "ERROR: Price interval and interval_count need to match"
      exit 1
    elsif !AlaveteliPro::Price.list.map(&:id).include?(new_price.id)
      puts "ERROR: New price is not defined in general.yml"
      exit 1
    end

    [old_price, new_price]
  end
end
