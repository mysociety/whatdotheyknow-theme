module AuthorityOnlyResponseGatekeeper
  EXTRA_ALLOWED_EMAILS = [
    { public_body_id: 27, email: 'no-reply@cabinetoffice.ecase.co.uk' }
  ]

  def allow?(mail)
    public_body_id = info_request.public_body_id
    email = MailHandler.get_from_address(mail)

    return true if EXTRA_ALLOWED_EMAILS.any? do |a|
      a[:public_body_id] == public_body_id && a[:email] == email
    end

    super
  end
end

Rails.configuration.to_prepare do
  InfoRequest::ResponseGatekeeper::AuthorityOnly.
    prepend AuthorityOnlyResponseGatekeeper
end
