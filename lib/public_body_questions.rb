Rails.configuration.to_prepare do
  next unless ActiveRecord::Base.connection.data_source_exists?(:public_bodies)

  home_office = PublicBody.find_by_url_name('home_office')

  home_office_deny_response = _(
    <<-HTML.strip_heredoc.squish
      <p>
        We understand that it can be difficult to get a response from the Home
        Office to personal immigration queries. We suggest writing to the Home
        Office via a local Member of Parliament, if you <a
        href="http://www.writetothem.com/">send your correspondence to your MP
        </a>, they or their office, can pass it on to the Home Office and ensure
        you get a response. This has the benefit of highlighting difficulties
        communicating with the Home Office to MPs.
      </p>

      <p>
        Misusing our service, which makes all correspondence public, won't help
        you pursue your individual case as the Home Office will not enter into
        correspondence about individual cases via our service.
      </p>
    HTML
  )

  PublicBodyQuestion.build(
    public_body: home_office,
    key: :visa,
    question: _('Asking about your Visa?'),
    response: home_office_deny_response
  )

  PublicBodyQuestion.build(
    public_body: home_office,
    key: :brp,
    question: _('Asking about Biometric Residence Permit (BRP) replacements ' \
                'or refunds?'),
    response: home_office_deny_response
  )

  PublicBodyQuestion.build(
    public_body: home_office,
    key: :foi,
    question: _('Asking for recorded information held by a public body that ' \
                'anyone could reasonably request and expect to receive?'),
    response: :allow
  )
end
