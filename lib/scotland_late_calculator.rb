# -*- encoding : utf-8 -*-
class ScotlandLateCalculator
  def self.description
    %q(Scotland has extended deadlines during COVID-19)
  end

  def reply_late_after_days
    60
  end

  def reply_very_late_after_days
    100
  end
end
