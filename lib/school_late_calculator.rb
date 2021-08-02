class SchoolLateCalculator
  def self.description
    %q(UK Schools have an extra 20 days to respond to FOI requests)
  end

  def reply_late_after_days
    AlaveteliConfiguration.reply_late_after_days
  end

  def reply_very_late_after_days
    60
  end
end
