##
# Module so we can track when raw emails are used, the context, and how often.
#
module RawEmailUsage
  def data
    app_path = /#{Rails.root}/
    non_app_paths = Regexp.union(*Gem.path.join('|'))

    app_call_stack = caller.grep(app_path).grep_v(non_app_paths).map do |line|
      line.sub(Rails.root.to_s, '.')
    end

    params = {
      method: 'RawEmail#data',
      raw_email_id: id,
      caller: app_call_stack
    }

    ActiveSupport::Notifications.instrument('raw_email_usage', params) do
      super
    end
  end
end

Rails.configuration.to_prepare do
  RawEmail.prepend RawEmailUsage
end

Rails.application.config.before_initialize do
  ActiveSupport::Notifications.subscribe('raw_email_usage') do |event|
    logger = Logger.new(Rails.root.join('log', 'raw_email_usage.log'))

    context = 'xapian' if ActsAsXapian.writable_db
    context ||= ActiveSupport::ExecutionContext.to_h[:controller]&.class
    context ||= ActiveSupport::ExecutionContext.to_h[:job]&.class
    context ||= Rails.env

    logger.info(
      "#{event.name} (#{event.duration.round(1)}ms) [#{context}] " +
      event.payload.inspect
    )
  end
end
