# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
require 'request_mailer'
require 'dispatcher'
Dispatcher.to_prepare do
    User.class_eval do
        # Return this user’s survey
        def survey
            return @survey if @survey
            site_name = MySociety::Config.get("SITE_NAME", "Alaveteli")
            @survey = MySociety::Survey.new(site_name, self.email)
        end
    end
    
    # Now patch the validator for UserInfoRequestSentAlert.alert_type
    # to permit 'survey_1' as a new alert type.
    UserInfoRequestSentAlert.validate_callback_chain[0].options[:in] << 'survey_1'
    
    # Add survey methods to RequestMailer
    RequestMailer.class_eval do
        def survey_alert(info_request)
            user = info_request.user
            
            post_redirect = PostRedirect.new(
                :uri => survey_url,
                :user_id => user.id)
            post_redirect.save!
            url = confirm_url(:email_token => post_redirect.email_token)
            
            @from = contact_from_name_and_email
            headers 'Return-Path' => blackhole_email, 'Reply-To' => @from, # not much we can do if the user's email is broken
                    'Auto-Submitted' => 'auto-generated', # http://tools.ietf.org/html/rfc3834
                    'X-Auto-Response-Suppress' => 'OOF'
            @recipients = user.name_and_email
            @subject = "Can you help us improve WhatDoTheyKnow?"
            @body = { :count => count, :info_request => info_request, :url => url }
        end
        
        class << self
            # Send an email with a link to the survey a week after a request was made,
            # if the user has not already completed the survey.
            def alert_survey
                for info_request in info_requests
                    alert_event_id = info_request.info_request_events[0]
                
                    sent_already = UserInfoRequestSentAlert.find(:first, :conditions => [ "alert_type = ? and user_id = ? and info_request_id = ? and info_request_event_id = ?", 'survey_1', info_request.user_id, info_request.id, alert_event_id])
                    return if !sent_already.nil?
                
                    store_sent = UserInfoRequestSentAlert.new
                    store_sent.info_request = info_request
                    store_sent.user = info_request.user
                    store_sent.alert_type = 'survey_1'
                    store_sent.info_request_event_id = alert_event_id
                    RequestMailer.deliver_survey_alert(info_request)
                    store_sent.save!
                end
            end
            
            def alert_new_response_reminders_with_alert_survey
                alert_new_response_reminders_without_alert_survey
                alert_survey
            end
            
            alias_method_chain :alert_new_response_reminders, :alert_survey
        end
    end
end
