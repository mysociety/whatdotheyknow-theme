# On a first deploy, these tables don't exist yet, so skip this step:
if ['info_requests', 'censor_rules'].all? { |table_name|
        ActiveRecord::Base.connection.table_exists? table_name
    }

    rules_data = [{:text => '\*\*\*+\s+Polly Tucker.*',
                      :replacement => '',
                      :regexp => true,
                      :info_request => InfoRequest.find_by_url_title('total_number_of_objects_in_the_n_6'),
                      :last_edit_editor => 'system',
                      :last_edit_comment => 'Refactored from remove_privacy_sensitive_things!'},

                  {:text => 'Andy 079.*',
                      :replacement => 'Andy [mobile number]',
                      :regexp => true,
                      :info_request => InfoRequest.find_by_url_title('cctv_data_retention_and_use'),
                      :last_edit_editor => 'system',
                      :last_edit_comment => 'Refactored from remove_privacy_sensitive_things!'},

                  {:text => '(Complaints and Corporate Affairs Officer)\s+Westminster Primary Care Trust.+',
                      :replacement => '\\1',
                      :regexp => true,
                      :info_request => InfoRequest.find_by_url_title('how_do_the_pct_deal_with_retirin_113'),
                      :last_edit_editor => 'system',
                      :last_edit_comment => 'Refactored from remove_privacy_sensitive_things!'},

                  {:text => 'Your password:-\s+[^\s]+',
                      :replacement => '[password]',
                      :public_body => PublicBody.find_by_url_name('home_office'),
                      :regexp => true,
                      :last_edit_editor => 'system',
                      :last_edit_comment => 'Refactored from remove_privacy_sensitive_things!'},
                  {:text => 'Password=[^\s]+',
                      :replacement => '[password]',
                      :public_body => PublicBody.find_by_url_name('home_office'),
                      :regexp => true,
                      :last_edit_editor => 'system',
                      :last_edit_comment => 'Refactored from remove_privacy_sensitive_things!'}]
    rules_data.each do |d|
        rule = CensorRule.find_by_text(d[:text])
        if rule.nil?
            new_rule = CensorRule.new(d)
            if new_rule.info_request || new_rule.public_body
                new_rule.save!
            end
        end
    end
end
