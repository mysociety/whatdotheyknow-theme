Rails.configuration.to_prepare do
  next unless ActiveRecord::Base.connection.data_source_exists?(:public_bodies)

  ## Specify public bodies which should be evaluated

  home_office = PublicBody.find_by_url_name('home_office')
  ## LSE
  lse_tsai = PublicBody.find_by_url_name('lse')
  uol_tsai = PublicBody.find_by_url_name('university_of_london')
  uolww_tsai = PublicBody.find_by_url_name('university_of_london_worldwide')

  ## Generic boilerplate templates for reuse

  ## public body specific templates
  dwp = PublicBody.find_by_url_name('dwp')

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
          You could also try contacting the Home Office by email at: <a
        href="mailto:public.enquiries@homeoffice.gov.uk">public.enquiries@
        homeoffice.gov.uk</a>.
      </p>

      <p>
        Misusing our service, <strong>which makes all correspondence
        public</strong>, won't help you pursue your individual case as the Home
        Office will not enter into correspondence about individual cases via our
        service.
      </p>
    HTML
  )

  ## LSE

  lse_tsai_deny_response = _(
    <<-HTML.strip_heredoc.squish
    <article>
    <section>  
      <h3>
        We've noticed a lot of people asking about this.
      </h3>
      <p>
        We know that many people have asked about Dr Tsai Ing-Wen's thesis and 
        qualifications.
      </p>
      <p>
        You cannot request this information on WhatDoTheyKnow, but here's some 
        information that might help:
      </p>
      <ul>
        <li>
          The <abbr title="London School of Economics and Political Science">LSE
          </abbr> has issued a statement, 
          <a href="https://www.lse.ac.uk/News/Latest-news-from-LSE/2019/j-October-2019/LSE-statement-on-PhD-of-Dr-Tsai-Ing-wen"
          target="_blank"
          title="LSE statement on PhD of Dr Tsai Ing-wen (opens in a new window)">
          on their website</a>, which confirms the timelines surrounding 
          Dr Tsai's PhD.
        </li>
        <li>
          The University of London has also confirmed its position 
          <a href="https://london.ac.uk/university-london-statement-missing-thesis"
          target="_blank"
          title="University of London statement (opens in a new window)">
          on its website</a>.
        </li>
        <li>
          You can read Dr Tsai's thesis at the 
          <a href="http://etheses.lse.ac.uk/3976/"
          target="_blank"
          title="View Dr Tsai Ing-Wen's thesis on the LSE Theses Online website
          (opens in a new window)"><abbr title="London School of Economics and 
          Political Science">LSE</abbr> Theses Online website</a>.
        </li>
        <li>
          The Information Commissioner has received queries about this topic. 
          You can find their reply 
          <a href="https://ico.org.uk/about-the-ico/our-information/disclosure-log/requests-about-taiwanese-president-tsai-ing-wen-s-phd-thesis-the-uol-and-lse/"
          target="_blank"
          title="View the Information Commissioner's reply to queries about Dr
          Tsai Ing-Wen's theses and the replies from LSE and University of 
          London (opens in a new window)">on their website</a>.
        </li>
      </ul>
      </section>
      <hr>
      <section>
      <p>
        <h4>Important</h4>
        Please don't use our website to ask for comments from public bodies on 
        this topic, and take care to read our 
        <a href="/help/house_rules">House Rules</a>. These rules tell you how 
        we expect you to use our site, and they also tell you what we might do 
        if you misuse it.
      </p>
      <div style="text-align:center">
        <a class="button" 
        href="/help/house_rules"
        title="View our House Rules">
        View our House Rules »
        </a>
      </div>
      <section>
      </article>
      HTML
  )

  ## build public body questions

  dwp_deny_response_1 = _(<<-HTML.strip_heredoc.squish
      <h3>You cannot make a claim using WhatDoTheyKnow</h3>

      <p>
        You can find information about how to claim benefits on the
        <a href="https://www.gov.uk/browse/benefits">gov.uk website</a>.
      </p>
      <p>
        Information you might find useful:
        <ul>
          <li>
            You can use a <a href="https://www.gov.uk/benefits-calculators">
            benefits calculator</a> to find out what you may be entitled to.
          </li>
          <li>
            In <b>Northern Ireland</b>, some benefits are managed directly by
            the <a href="/body/dfc">Department for Communities</a>. You can find
            information on 
            <a href="https://www.nidirect.gov.uk/campaigns/unclaimed-benefits">
            nidirect.gov.uk</a>
          </li>
          <li>
            In Scotland, some benefits are managed directly by 
            <a href="/body/social_security_scotland">Social Security Scotland</a>.
            You can find information on
            <a href="https://www.mygov.scot/browse/benefits">mygov.scot</a>
          </li>
        </ul>
      </p>

    HTML
  )

  dwp_deny_response_2 = _(<<-HTML.strip_heredoc.squish
      <h3>You cannot claim your State Pension using WhatDoTheyKnow</h3>

      <p>
        You can find information about how to claim benefits on the
        <a href="https://www.gov.uk/get-state-pension">gov.uk website</a>.
      </p>
      <p>
        Information you might find useful:
        <ul>
          <li>In <b>Northern Ireland</b> you need to contact the 
          <a href="/body/dfc">Department for Communities</a> to make your claim.
           You can find more information on:
           <a href="https://www.nidirect.gov.uk/services/get-your-state-pension">
           nidirect.gov.uk</a>.
          </li>
          <li>If you are <b>outside the UK</b> you need to contact the 
          <a href="https://www.gov.uk/state-pension-if-you-retire-abroad">
          International Pensions Centre</a> to make your claim.
          </li>
        </ul>
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

  ## LSE

  PublicBodyQuestion.build(
    public_body: lse_tsai,
    key: :tsai,
    question: _('Find out about Dr Tsai Ing-Wen (蔡英文)'),
    response: lse_tsai_deny_response
  )
  PublicBodyQuestion.build(
    public_body: uol_tsai,
    key: :tsai,
    question: _('Find out about Dr Tsai Ing-Wen (蔡英文)'),
    response: lse_tsai_deny_response
  )
  PublicBodyQuestion.build(
    public_body: uolww_tsai,
    key: :tsai,
    question: _('Find out about Dr Tsai Ing-Wen (蔡英文)'),
    response: lse_tsai_deny_response
  )

  PublicBodyQuestion.build(
    public_body: lse_tsai,
    key: :foi,
    question: _('Ask for recorded information held by a public body ' \
                '<strong>on any other topic</strong> that ' \
                'anyone could reasonably request and expect to receive?'),
    response: :allow
  )
  PublicBodyQuestion.build(
    public_body: uol_tsai,
    key: :foi,
    question: _('Ask for recorded information held by a public body ' \
                '<strong>on any other topic</strong> that ' \
                'anyone could reasonably request and expect to receive?'),
    response: :allow
  )
  PublicBodyQuestion.build(
    public_body: uolww_tsai,
    key: :foi,
    question: _('Ask for recorded information held by a public body ' \
                '<strong>on any other topic</strong> that ' \
  PublicBodyQuestion.build(
    public_body: dwp,
    key: :claim_benefits,
    question: _('Claim social security benefits'),
    response: dwp_deny_response_1
  )

  PublicBodyQuestion.build(
    public_body: dwp,
    key: :claim_pension,
    question: _('Claim my State Pension'),
    response: dwp_deny_response_2
  )
  
  PublicBodyQuestion.build(
    public_body: dwp,
    key: :foi,
    question: _('Asking for recorded information held by a public body that ' \
                'anyone could reasonably request and expect to receive?'),
    response: :allow
  )
end
