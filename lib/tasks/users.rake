namespace :users do
  task tag_disposable_emails: :environment do
    count = email_domains.count

    email_domains.each_with_index do |email_domain, index|
      erase_line
      print "Checking disposable email domains #{index + 1}/#{count} (#{email_domain})"

      result = UserCheck.check_domain(email_domain)
      next unless result[:success] && result[:disposable]

      tag = 'disposable_email'

      users = User.where("split_part(email, '@', 2) = ?", email_domain).
        without_tag(tag)

      users.pluck(:id).each do |user_id|
        HasTagStringTag.create(
          model_type: 'User', model_id: user_id, name: tag
        )
      end
    end

    erase_line
    puts "Checking disposable email domains completed."
  end

  def email_domains
    @email_domains ||= ActiveRecord::Base.connection.
      execute(<<-SQL).map { _1.fetch('domain') }
        SELECT split_part(email, '@', 2) AS domain
        FROM users
        GROUP BY domain
      SQL
  end

  def erase_line
    # https://en.wikipedia.org/wiki/ANSI_escape_code#Escape_sequences
    print "\e[1G\e[K"
  end
end
