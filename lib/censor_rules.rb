rules_data = [{:text => '\*\*\*+\nPolly Tucker.*',
                  :replacement => '',
                  :regexp => true,
                  :last_edit_editor => 'system',
                  :last_edit_comment => 'Refactored from remove_privacy_sensitive_things!'},

              {:text => 'Andy 079.*',
                  :replacement => 'Andy [mobile number]',
                  :regexp => true,
                  :last_edit_editor => 'system',
                  :last_edit_comment => 'Refactored from remove_privacy_sensitive_things!'},

              {:text => '(Complaints and Corporate Affairs Officer},\s+Westminster Primary Care Trust.+',
                  :replacement => 'Andy [mobile number]',
                  :regexp => true,
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
    rule = CensorRule.regexps.find_by_text(d[:text])
    if rule.nil?
        CensorRule.create(d)
    end
end
