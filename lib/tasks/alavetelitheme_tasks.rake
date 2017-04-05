# desc "Explaining what the task does"
# task :alavetelitheme do
#   # Task goes here
# end

namespace :wdtk do
  desc "Reindex events in batches of 300"
  task :reindex_events => :environment do
    reindex_log = Logger.new("#{Rails.root}/log/reindex.log")
    last_id = ENV["LAST_EVENT_ID"] || 0
    batch_size = (ENV["BATCH_SIZE"] || 300).to_i

    reindex_log.info("\nrun started... #{Time.now}")

    begin
      InfoRequestEvent.where("id > #{last_id}").find_in_batches(:batch_size => batch_size) do |events|
        events.each(&:xapian_mark_needs_index)
        reindex_log.info("* queued batch ending: #{events.last.id}")
        sleep 300 # 5 mins so that the next batch gets collected by the next indexing run
      end
      reindex_log.info("reindex queuing complete!")
    rescue Exception => e
      reindex_log.error("uncaught #{e} exception while handling connection: #{e.message}")
      reindex_log.error("Stack trace: #{e.backtrace.map {|l| "  #{l}\n"}.join}")
      abort
    end
  end
end
