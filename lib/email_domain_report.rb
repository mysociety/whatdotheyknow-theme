module EmailDomainReport
  module UserMailer
    def email_domain_report
      @date_range = (1.week.ago.at_beginning_of_day..)
      @month_range = (@date_range.first - 1.month)...@date_range.begin

      weekly_data = count_by_domain(created_at: @date_range)
      monthly_data = count_by_domain(created_at: @month_range)

      # Combine data and calculate deltas
      all_domains = (weekly_data.keys + monthly_data.keys).uniq
      @data = all_domains.map do |domain|
        weekly_count = weekly_data[domain] || 0
        monthly_count = monthly_data[domain] || 0
        next unless weekly_count + monthly_count >= 2

        delta = monthly_count > 0 ?
          ((weekly_count - monthly_count).to_f / monthly_count * 100).round(2) :
          (weekly_count > 0 ? Float::INFINITY : 0)

        {
          domain: domain,
          weekly: weekly_count,
          monthly: monthly_count,
          delta: delta
        }
      end.compact.sort_by { |data| -data[:delta] }

      return if @data.empty?

      from = MailHandler.address_from_name_and_email(
        'WhatDoTheyKnow.com email domain report', blackhole_email
      )

      mail(
        from: from,
        to: contact_from_name_and_email,
        subject: 'WhatDoTheyKnow.com email domain report'
      )
    end

    private

    def count_by_domain(created_at:)
      User.where(created_at: created_at).
           group("LOWER(split_part(email, '@', 2))").
           order(count_all: :desc).
           count
    end
  end
end

Rails.configuration.to_prepare do
  UserMailer.class_eval do
    prepend EmailDomainReport::UserMailer
  end
end
