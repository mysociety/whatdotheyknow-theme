# -*- coding: utf-8 -*-
# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
# Please arrange overridden classes alphabetically.
Rails.configuration.to_prepare do
  SPAM_TERMS_CONFIG ||= Rails.root + 'config/spam_terms.txt'

  if File.exist?(SPAM_TERMS_CONFIG)
    custom_terms =
      File.read(SPAM_TERMS_CONFIG).
        split("\n").
        reject { |line| line.starts_with?('#') || line.empty? }

    AlaveteliSpamTermChecker.default_spam_terms =
      AlaveteliSpamTermChecker::DEFAULT_SPAM_TERMS + custom_terms
  end

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
      if public_body && public_body.url_name == 'general_register_office'
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

  ProAccount.class_eval do
    prepend ProAccountBans::ModelMethods
  end

  # Educational institutions
  PublicBody.batch_excluded_tags += %w[
    academies
    fei
    school
  ]

  # Independent Monitoring Boards for prisons etc
  PublicBody.batch_excluded_tags += %w[
    hmp_imb
    irc_imb
    special_imb
    sthf_imb
    yoi_imb
  ]

  # Local government — lowest tier
  PublicBody.batch_excluded_tags += %w[
    city_parish_council
    community_council
    town_council
    parish_council
    parish_meeting
  ]

  # Healthcare — smaller healthcare providers only subject to FOI in respect of
  # specific functions
  PublicBody.batch_excluded_tags += %w[
    dentist
    optician
    pharmacy
    surgery
  ]

  # Other
  PublicBody.batch_excluded_tags += %w[
    engrsl
    signpost
    unit
  ]

  PublicBody.excluded_calculated_home_page_domains += %w[
    aol.co.uk
    blueyonder.co.uk
    btconnect.com
    btinternet.com
    btopenworld.com
    hotmail.co.uk
    live.co.uk
    ntlworld.com
    sky.com
    talk21.com
    talktalk.net
    tiscali.co.uk
    virginmedia.com
    yahoo.co.uk
  ]

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

  PublicBody.instance_eval do
    module SignpostMissingEmail
      def update_missing_email_tag
        return remove_tag('missing_email') if has_tag?('signpost')

        super
      end
    end

    prepend SignpostMissingEmail
  end

  RawEmail.class_eval do
    alias original_data data

    def data
      original_data&.sub(/
        ^(Date: [^\n]+\n)
        \s+(To: [^\n]+\n)
        \s+(From: [^\n]+)
      /x, '\1\2\3')
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
    D&TCDIO_Office@justice.gov.uk
    FOI.Enquiries@ukaea.uk
    mail@sf-notifications.com
    Paul.D.O'Shea@met.police.uk
    no-reply@somersetwestandtaunton.gov.uk
    csfinanceplanning&performance.briefingteam@hmrc.gov.uk
    foi.foi@lincs.police.uk
    microsoftoffice365@messaging.microsoft.com
    mft@cambridgeshire.gov.uk
    hou&com.fois@bcpcouncil.gov.uk
    foi@dudley.gov.uk
    no-reply@sharepointonline.com
    dvla.donotreply@dvla.gov.uk
    noreply@my.tewkesbury.gov.uk
    donotreply.foi@publicagroup.uk
    do_not_reply@icasework.com
    mailer@donotreply.icasework.com
    website@digital.sthelens.gov.uk
    noreply@m.onetrust.com
    no-reply@notify.microsoft.com
    MPSdataoffice-IRU-DONOTREPLY@met.police.uk
    noreply@rugby.gov.uk
    no-reply@cheshire.pnn.police.uk
    Information-rights@nhsbsa.nhs.uk
    noreply-horsham@axlr8.com
    donotreply@plymouth.gov.uk
    do_not_reply@sandwell.gov.uk
    request@ig.northlincs.gov.uk
    noreply@infreemation.co.uk
    noreply@leeds.gov.uk
    nhsbsa.foirequests@nhs.net
    donotreply@hillingdon.gov.uk
    no-reply@fcdo.ecase.co.uk
    foiresponses_NO-REPLY@york.gov.uk
    pt&e.rfi@bcpcouncil.gov.uk
    NoReply@tandridge.gov.uk
    final@homeoffice.gov.uk
    no-reply@oxford.ecase.co.uk
    noreply.digitalservices@emails.lisburncastlereagh.gov.uk
    noreply@ams-sar.com
    foi@cheshireeast.gov.uk
    OneTrustEmail@surrey.ac.uk
    account-security-noreply@accountprotection.microsoft.com
    msonlineservicesteam@microsoftonline.com
    DataRightsDONOTREPLY@met.police.uk
    no.reply@met.police.uk
    noreply@casetracker.uk
    foi@westlondon.nhs.uk
    no-reply@south-ayrshire.gov.uk
    noreply@north-ayrshire.gov.uk
    noreply@corestream.co.uk
    NHSFife@axlr8.com
    do-not-reply=midlothian.gov.uk@email.firmstep.com
    do-not-reply@midlothian.gov.uk
  )

  User.content_limits = {
    info_requests: AlaveteliConfiguration.max_requests_per_user_per_day,
    comments: AlaveteliConfiguration.max_requests_per_user_per_day,
    user_messages: 2
  }

  User.class_eval do
    alias_method :orig_can_make_comments?, :can_make_comments?
    def can_make_comments?
      return true if no_limit?
      orig_can_make_comments?
    end

    private

    def exceeded_user_message_limit?
      !Time.zone.now.between?(Time.zone.parse('9am'), Time.zone.parse('5pm'))
    end
  end

  User::EmailAlerts.instance_eval do
    module DisableWithProtection
      def disable
        if user.url_name == 'internal_admin_user'
          raise "Email alerts should not be disabled for #{user.name}!"
        end

        super
      end
    end

    prepend DisableWithProtection
  end

  ActiveStorage::Blob.class_eval do
    def delete
      service.delete(key)
      # Prevent deletion of variants. We don't currently use variants and this
      # causes timeouts (when doing a remote globs to find variant files to be
      # deleted) when using a ActiveStorage SFTP service
      # service.delete_prefixed("variants/#{key}/") if image?
    end
  end
end
