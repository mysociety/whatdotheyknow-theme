# -*- coding: utf-8 -*-
# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
Rails.configuration.to_prepare do

    User.class_eval do
        # Return this user’s survey
        def survey
            return @survey if @survey
            @survey = MySociety::Survey.new(AlaveteliConfiguration::site_name, self.email)
        end
    end

    # Now patch the validator for UserInfoRequestSentAlert.alert_type
    # to permit 'survey_1' as a new alert type.

    UserInfoRequestSentAlert._validate_callbacks[0].options[:in] << 'survey_1'

    InfoRequest.class_eval do
        def email_subject_request(opts = {})
            html = opts.fetch(:html, true)
            subject_title = html ? self.title : self.title.html_safe
            if (!is_batch_request_template?) && (public_body.url_name == 'general_register_office')
                # without GQ in the subject, you just get an auto response
                _('{{law_used_full}} request GQ - {{title}}', :law_used_full => law_used_human(:full),
                                                              :title => subject_title)
            else
                _('{{law_used_full}} request - {{title}}', :law_used_full => law_used_human(:full),
                                                           :title => subject_title)
            end
        end
    end

    PublicBody.class_eval do
      # Return the domain part of an email address, canonicalised and with common
      # extra UK Government server name parts removed.
      #
      # TODO: Extract to library class
      def self.extract_domain_from_email(email)
        email =~ /@(.*)/
        if $1.nil?
          return nil
        end

        # take lower case
        ret = $1.downcase

        # remove special email domains for UK Government addresses
        %w(gsi x pnn).each do |subdomain|
          if ret =~ /.*\.*#{ subdomain }\.*.*\.gov\.uk$/
            ret.sub!(".#{ subdomain }.", '.')
          end
        end

        return ret
      end
    end

    # Add survey methods to RequestMailer
    RequestMailer.class_eval do
        def survey_alert(info_request)
            user = info_request.user

            post_redirect = PostRedirect.new(
                :uri => survey_url,
                :user_id => user.id)
            post_redirect.save!
            @url = confirm_url(:email_token => post_redirect.email_token)

            headers('Return-Path' => blackhole_email, 'Reply-To' => contact_from_name_and_email, # not much we can do if the user's email is broken
                    'Auto-Submitted' => 'auto-generated', # http://tools.ietf.org/html/rfc3834
                    'X-Auto-Response-Suppress' => 'OOF')
            @info_request = info_request
            mail(:to => user.name_and_email,
                 :from => contact_from_name_and_email,
                 :subject => "Can you help us improve WhatDoTheyKnow?")
        end

        class << self
            # Send an email with a link to the survey two weeks after a request was made,
            # if the user has not already completed the survey.
            def alert_survey
                # Exclude requests made by users who have already been alerted about the survey
                info_requests = InfoRequest.find(:all,
                    :conditions => [
                        " created_at between now() - '2 weeks + 1 day'::interval and now() - '2 weeks'::interval" +
                        " and user_id is not null" +
                        " and not exists (" +
                        "     select *" +
                        "     from user_info_request_sent_alerts" +
                        "     where user_id = info_requests.user_id" +
                        "      and  alert_type = 'survey_1'" +
                        " )"
                    ],
                    :include => [ :user ]
                )
                for info_request in info_requests
                    # Exclude users who have already completed the survey
                    logger.debug "[alert_survey] Considering #{info_request.user.url_name}"
                    next if info_request.user.survey.already_done?

                    store_sent = UserInfoRequestSentAlert.new
                    store_sent.info_request = info_request
                    store_sent.user = info_request.user
                    store_sent.alert_type = 'survey_1'
                    store_sent.info_request_event_id = info_request.info_request_events[0].id

                    RequestMailer.survey_alert(info_request).deliver
                    store_sent.save!
                end
            end

            def alert_new_response_reminders_with_alert_survey
                alert_new_response_reminders_without_alert_survey
                alert_survey if AlaveteliConfiguration::send_survey_mails
            end

            alias_method_chain :alert_new_response_reminders, :alert_survey
        end
    end
end
