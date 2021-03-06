# -*- coding: utf-8 -*-
# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
# Please arrange overridden classes alphabetically.
Rails.configuration.to_prepare do
  ContactValidator.class_eval do
    attr_accessor :understand

    validates_acceptance_of :understand,
      :message => N_("Please confirm that you " \
                     "understand that WhatDoTheyKnow " \
                     "is not run by the government, " \
                     "and the WhatDoTheyKnow " \
                     "volunteers cannot help you " \
                     "with personal matters relating " \
                     "to government services.")
  end

  InfoRequest.class_eval do
    def email_subject_request(opts = {})
      html = opts.fetch(:html, true)
      subject_title = html ? self.title : self.title.html_safe
      if (!is_batch_request_template?) && (public_body && public_body.url_name == 'general_register_office')
        # without GQ in the subject, you just get an auto response
        _('{{law_used_full}} request GQ - {{title}}', law_used_full: legislation.to_s(:full),
          title: subject_title)
      else
        _('{{law_used_full}} request - {{title}}', law_used_full: legislation.to_s(:full),
          title: subject_title)
      end
    end

    alias_method :orig_late_calculator, :late_calculator

    def late_calculator
      @late_calculator ||=
        if public_body.has_tag?('school')
          SchoolLateCalculator.new
        else
          orig_late_calculator
        end
    end
  end

  Legislation.refusals = {
    foi: [
      's 11', 's 12', 's 14', 's 21', 's 22', 's 30', 's 31', 's 35', 's 38',
      's 40', 's 41', 's 43'
      # We don't offer refusal advice for these exemption. See:
      #   https://github.com/mysociety/alaveteli/issues/6281
      # 's 23', 's 24', 's 26', 's 27', 's 28', 's 29', 's 32', 's 33', 's 34',
      # 's 36', 's 37', 's 39', 's 42', 's 44'
    ]
  }

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

    def is_school?
      has_tag?('school')
    end
  end

  ReplyToAddressValidator.invalid_reply_addresses = %w(
    FOIResponses@homeoffice.gsi.gov.uk
    FOIResponses@homeoffice.gov.uk
    autoresponder@sevenoaks.gov.uk
    H&FInTouch@lbhf.gov.uk
    tfl@servicetick.com
    cap-donotreply@worcestershire.gov.uk
    NEW_FOISA@dundeecity.gov.uk
    noreply@slc.co.uk
    DoNotReply@dhsc.gov.uk
    OSCTFOI@homeoffice.gov.uk
    SOCGroup_Correspondence@homeoffice.gov.uk
    FOI-E&E@Oxfordshire.gov.uk
    no-reply@bch.ecase.gsi.gov.uk
    new_foisa@dundeecity.gov.uk
    noreply@aberdeencity.gov.uk
    NoReply.FOI@worcester.gov.uk
    auto-reply@castlepoint.gov.uk
    system@share.ons.gov.uk
    foi&dparequest@nmc-uk.org
    lambethinformationrequests@lambeth.gov.uk
    myaccount@coventry.gov.uk
    C&PCCC@highwaysengland.co.uk
    DONOTREPLY@3csharedservices.vuelio.co.uk
  )

  User.class_eval do
    require_relative Rails.root.join('commonlib/rblib/survey')

    # Return this user’s survey
    def survey
      return @survey if @survey
      @survey = MySociety::Survey.new(AlaveteliConfiguration::site_name, self.email)
    end
  end
end
