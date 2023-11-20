Rails.configuration.to_prepare do
  next unless ActiveRecord::Base.connection.data_source_exists?(:public_bodies)

  ## Specify public bodies which should be evaluated

  home_office = PublicBody.find_by_url_name('home_office')
  ## LSE
  lse_tsai = PublicBody.find_by_url_name('lse')
  uol_tsai = PublicBody.find_by_url_name('university_of_london')
  uolww_tsai = PublicBody.find_by_url_name('university_of_london_worldwide')
  dfc = PublicBody.find_by_url_name('dfc')
  dwp = PublicBody.find_by_url_name('dwp')
  socsecscot = PublicBody.find_by_url_name('social_security_scotland')
  ## Generic boilerplate templates for reuse

    generic_deny_boilerplate = _(<<-HTML.strip_heredoc.squish
      <hr>  
      <p>
       <p>
        <h4>Important</h4>
        Misusing our service, <strong><u>which makes all correspondence public
        </u></strong>, won't help you pursue your individual case. This is 
        because, to keep your personal information safe, organisations will not 
        discuss your personal circumstances when you contact them using our 
        service.
      </p>
      <p>
        Please also take care to read our <a href="/help/house_rules">House 
        Rules</a>. These rules tell you how we expect you to use our site, and 
        they also tell you what we might do if you misuse it.
      </p>
      <div style="text-align:center">
        <a class="button" 
        href="/help/house_rules"
        title="View our House Rules">
        View our House Rules »
        </a>
      </div>
    HTML
    # we reuse this multiple times with #{generic_deny_boilerplate}
  )
  ## Generic boilerplate templates for reuse

  generic_deny_askcouncil  = _(<<-HTML.strip_heredoc.squish
      <p>
        Your local Council might also offer a Welfare Rights 
        service, or be able to signpost you to a service in your area 
        that can help.
      </p>
    HTML
    # we reuse this multiple times with #{generic_deny_askcouncil}
  )
  generic_deny_gdpr_rightofaccess = _(<<-HTML.strip_heredoc.squish
      <h3>You cannot do this using WhatDoTheyKnow</h3>
      <p>
        You have the right to access personal information that an organisation 
        holds about you. This can sometimes be called a Subject Access or Right
        of Access Request (SAR / RoAR).
      </p>
      <p>
        Each organisation will have their own processes for this; but it is 
        generally quick, and free of charge. You can get advice on your rights, 
        at no cost, from the <a href="https://ico.org.uk/your-data-matters/">
        Information Commisioner's Office</a>.
      </p>
      <hr>
    HTML
    # we reuse this multiple times with #{generic_deny_gdpr_rightofaccess}
  )

  ## public body specific templates

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

  ## home office

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
  
  home_office_deny_response_immi = _(
    <<-HTML.strip_heredoc.squish
      <h3>
        You cannot do this using WhatDoTheyKnow
      </h3>
      <p>
        We understand that it can be difficult to get a response from the Home
        Office to personal immigration queries - but you must not use 
        WhatDoTheyKnow to contact the Home Office about this.
      </p>
      <p>
        You can contact the Home Office, or UK Visas and Immigration, by:
        <ul>
          <li>
            contacting the 
            <a href="https://www.gov.uk/contact-ukvi-inside-outside-uk">
            UKVI helpline</a>
          </li>
          <li>
            sending an email to 
            <a href="mailto:public.enquiries@homeoffice.gov.uk">
            public.enquiries@homeoffice.gov.uk</a>
          </li>
          <li>
            calling or writing to the 
            <a href="https://www.homeoffice.gov.uk#org-contacts">
            Direct Communications Unit</a>
          </li>
        </ul>
      </p>
      <h4>If you're having trouble getting an answer</h4>
      <section>
      <p>
        If you are in the UK, we suggest writing to the Home Office via a local 
        Member of Parliament. Your MP (or their staff) can pass your query onto 
        on to the Home Office and ensure you get a response. This has the 
        benefit of highlighting difficulties communicating with the Home Office 
        to MPs.
      </p>
      <div style="text-align:center">
        <a class="button" 
        onclick="if (ga) { ga('send','event','Outbound Link','Write To Them Exit','Public Body Questions',1) };" 
        href="http://www.writetothem.com">
        Send a message to your MP using WriteToThem »
        </a>
      </div>
      <p>
        You could also seek help from:
        <ul>
          <li>
            <a href="https://www.migranthelpuk.org/contact">
            Migrant Help</a>
          </li>
          <li>
            <a href="https://www.citizensadvice.org.uk/immigration/">
            Citizens Advice</a>
          </li>
          <li>
            <a href="https://www.jcwi.org.uk/our-helplines">
            the <abbr title="Joint Council for the Welfare of Immigrants">
            JCWI</abbr> </a>
          </li>
          <li>
            <a href="https://www.libertyhumanrights.org.uk/advice_information/i-need-immigration-advice/">
            your local advice services</a>
          </li>
          <li>
            <a href="https://www.gov.uk/find-an-immigration-adviser">
            a registered Immigration Adviser
            </a>
          </li>
        </ul>
      <strong>Please note: WhatDoTheyKnow are unable to provide you with advice 
      regarding Immigration matters.</strong>
      </section>
      &nbsp;
      #{generic_deny_boilerplate}
    HTML
  )

  home_office_deny_response_passport = _(<<-HTML.strip_heredoc.squish
      <h3>
        You cannot do this using WhatDoTheyKnow
      </h3>
      <p>
        Passports are handled by 
        <a href="/body/hm_passport_office">HM Passport Service</a>, 
        which is an agency of the Home Office. 
      </p>
      <div style="text-align:center">
        <a class="button" 
        href="https://www.gov.uk/browse/abroad/passports">
        Find out about Passports on gov.uk »
        </a>
      </div>
      <h4>How do I contact HM Passport Service?</h4>
      <p>
        You can find contact details for the Passport Advice Line on the 
        <a href="https://www.gov.uk/passport-advice-line">gov.uk website</a>.
      </p>
      &nbsp;
      #{generic_deny_boilerplate}
    HTML
  )

  home_office_deny_response_rightofaccess = _(<<-HTML.strip_heredoc.squish 
      #{generic_deny_gdpr_rightofaccess}
      <h4>
        Getting access to your personal information held by the Home Office 
        and its agencies
      </h4>
      <p>
        Sometimes, you don't need to make a formal request - if you simply need 
        proof of your immigration status, or have a query, contacting the 
        office that handles your case can often be quicker.
      </p>
      <p>  
        You can find details on how to make a <strong>Right of Access request
        </strong> to the Home Office and its agencies 
        <a href="https://www.gov.uk/government/organisations/home-office/about/personal-information-charter#how-to-ask-for-your-personal-information">
        on gov.uk</a>.
      </p>
      <p>
      <div style="text-align:center">
        <a class="button" 
        href="https://www.gov.uk/government/organisations/home-office/about/personal-information-charter#how-to-ask-for-your-personal-information">
        Make a Right of Access request on the Home Office website»
        </a>
      </div>
      &nbsp;
      #{generic_deny_boilerplate}
    HTML
  )

  ## department for communities (DfC)

  dfc_deny_response_benefits_claim = _(<<-HTML.strip_heredoc.squish
      <h3>You cannot do this using WhatDoTheyKnow</h3>

      <p>
        You can find information about how to claim benefits on the
        <a href="https://www.nidirect.gov.uk/campaigns/unclaimed-benefits">
        NIDirect website</a>.
      </p>
      <div style="text-align:center">
        <a class="button" 
        href="https://www.nidirect.gov.uk/campaigns/unclaimed-benefits"
        target="_blank"
        title="Find out more about benefits on the NIDirect website
        (opens in a new window)">
        Find out about benefits on NIDirect »</a>
      </div>
      <p>
        Information you might find useful:
        <ul>
          <li>
            You can get free advice on what benefits you may be entitled to  
            from the 
            <a href="https://www.nidirect.gov.uk/contacts/make-call-service"
            target="_blank"
            title="Find out more about the Make the Call service on the 
            NIDirect website (opens in a new window)">
            Make the Call service</a>.
          </li>
          <li>
            You can use an independent 
            <a href="https://www.nidirect.gov.uk/articles/benefits-calculator"
            target="_blank"
            title="Use a benefits calculator (opens in a new window)">
            benefits calculator</a> to find out what benefits and services that 
            you may be entitled to.
          </li>
          <li>
            In <strong>other parts of the UK</strong>, most benefits are managed 
            directly by the 
            <a href="/body/dwp">Department for Work and Pensions</a> or 
            <a href="/body/social_security_scotland">
            Social Security Scotland</a>. 
            You can find further information on 
            <a href="https://www.gov.uk/browse/benefits"
            target="_blank"
            title="Find out about UK wide benefits on gov.uk 
            (opens in a new window)">
            gov.uk</a> and 
            <a href="https://www.mygov.scot/browse/benefits" 
            target="_blank"
            title="Find out about benefits from Social Security Scotland  
            on mygov.scot (opens in a new window)">
            mygov.scot</a>.
          </li>
          <li>
            If you are unsure about benefits and need advice, you could contact 
            You can also seek independent advice, from:
            <ul>
              <li>
                <a href="https://www.adviceni.net/benefits"
                target="_blank"
                title="Link to the Advice NI website (opens in a new window)">
                Advice NI</a>
              <li>
                your local 
                <a href="https://www.adviceni.net/local-advice"
                target="_blank"
                title="Find a local advice agency on the Advice NI website 
                (opens in a new window)">
                Advice Agency</a>
              </li>
              <li>
                <a href="https://advicefinder.turn2us.org.uk/"
                target="_blank"
                title="Link a local advice charity or service on the Turn2Us
                website (opens in a new window)">
                Turn2Us</a>
              </li>
              <li>
                or your local 
                <a href="https://www.lawcentreni.org/"
                target="_blank"
                title="Link to the Law Centre NI website 
                (opens in a new window)">
                Law Centre</a>.
              </li>
            </ul>
            #{generic_deny_askcouncil}
          </li>
        </ul>
      </p>
      #{generic_deny_boilerplate}
    HTML
  )
  
  dfc_deny_response_benefits_contact = _(<<-HTML.strip_heredoc.squish
      <h3>You cannot do this using WhatDoTheyKnow</h3>

      <p>
        You should contact the office that handles your claim directly with any 
        concerns that you might have. You'll find their details on the  
        <a href="https://www.communities-ni.gov.uk/social-security-phone-services">
        Department for Communities website</a>, or below.
      </p>
      <hr>
        To contact the Department for Communities about your benefits, 
        you will need to do so using another method. If you're unsure who to 
        contact, ask the 
        <a href="https://www.communities-ni.gov.uk/contacts/customer-service-social-security">
        Customer Services team</a> for help.
      </p>
      <section>
      <h4>Employment and Support Allowance (ESA)</h4>
      <ul>
          <li>
            To contact <strong>Attendance Allowance</strong>, 
            <strong>Carers Allowance</strong>, or
            <strong>Disability Living Allowance</strong>, visit the
            <a href="https://www.nidirect.gov.uk/contacts/employment-and-support-allowance-centre">
            NIDirect website</a>.
          </li>
        </ul>
      </section>
      <section>
      <h4>Jobs and Benefit Offices</h4>
        <ul>
          <li>
            To contact your local Jobs and Benefit Office via phone, email, or 
            Video Relay, find their details on the
            <a href="https://www.nidirect.gov.uk/contacts/jobs-and-benefits-offices">
            NIDirect website</a>
          </li>
        </ul>
      </section>
      <section>
      <h4>Disability Benefits</h4>
        <ul>
          <li>
            To contact <strong>Attendance Allowance</strong>, 
            <strong>Carers Allowance</strong>, or
            <strong>Disability Living Allowance</strong>, visit the
            <a href="https://www.nidirect.gov.uk/contacts/disability-and-carers-service">
            NIDirect website</a>.
          </li>
          <li>
            <strong>Personal Independence Payment</strong> is handled by the 
            PIP Centre. You can find their details 
            <a href="https://www.nidirect.gov.uk/contacts/personal-independence-payment-pip-centre">
            here</a>.
          </li>
        </ul>
      </section>
      <section>
      <h4>Universal Credit</h4>
      <p>
        <ul>
          <li>
            You can find out more about Universal Credit on the 
            <a href="https://www.nidirect.gov.uk/campaigns/universal-credit">
            NIDirect website</a>.
          </li>
          <li>
            If you've an <strong>existing claim</strong> you can manage it, and 
            send messages to the Universal Credit Service Centre via the 
            <a href="https://www.universal-credit.service.gov.uk/sign-in">
            Universal Credit journal</a>.
          </li>
          <li>
            You can also contact the 
            <a href="https://www.nidirect.gov.uk/contacts/universal-credit-service-centre">
            Universal Credit Service Centre</a> by phone or video relay.
          </li>
          <li>
            You can also find details about <strong>other help and financial
            support</strong> on the
            <a href="https://www.adviceni.net/benefits/universal-credit">
            Advice NI</a> website.
          </li>
        </ul>
      </p>
      </section>
      #{generic_deny_boilerplate}
    HTML
  )

  dfc_deny_response_make_complaint = _(<<-HTML.strip_heredoc.squish
      <h3>You cannot make a complaint using WhatDoTheyKnow</h3>

      <p>
        You should contact the office that handles your claim directly.
        You can find their complaints procedure and contact details on the 
        <a href="https://www.communities-ni.gov.uk/social-security-complaints">
        NIDirect website</a>.
          <ul>
          <li>
            You could also try emailing DfC Customer Services team directly at 
            <a href="mailto:customerservice.unit@communities-ni.gov.uk">
            customerservice.unit@communities-ni.gov.uk
            </a>
          </li>
          <li>
            You can also <a onclick="if (ga) { ga('send','event','Outbound Link','Write To Them Exit','Public Body Questions',1) };" 
            href="http://www.writetothem.com">
            write to your elected members</a> for help.
          </li>
          <li>
            You can also seek independent advice, from:
            <ul>
              <li>
                <a href="https://www.adviceni.net/benefits">
                Advice NI</a>
              <li>
                your local 
                <a href="https://www.adviceni.net/local-advice">
                Advice Agency</a>
              </li>
              <li>
              <a href="https://advicefinder.turn2us.org.uk/">Turn2Us</a>
              </li>
              <li>
                or your local 
                <a href="https://www.lawcentreni.org/">
                Law Centre</a>.
              </li>
            </ul>
            #{generic_deny_askcouncil}
          </li>
        </ul> 
      </p>
      #{generic_deny_boilerplate}
    HTML
  )

  dfc_deny_response_rightofaccess = _(<<-HTML.strip_heredoc.squish 
      #{generic_deny_gdpr_rightofaccess}
      <h4>Getting access to information held by Department for Communities</h4>
      <p>
        Sometimes, you don't need to make a formal request - if you simply need 
        proof of your benefits, contacting the Benefit Office that handles your 
        claim can often be quicker.
      </p>
      <p>  
        You can find details on how to make a <strong>Right of Access request
        </strong> to the Department for Communities and its agencies 
        <a href="https://www.communities-ni.gov.uk/right-access-request">
        on nidirect.gov.uk</a>.
      </p>
      <p>
      <div style="text-align:center">
        <a class="button" 
        href="https://www.communities-ni.gov.uk/right-access-request">
        Make a Right of Access request on the DfC website»</a>
      </div>
      &nbsp;
      #{generic_deny_boilerplate}
    HTML
  )

  ## department for work and pensions (DWP)

  dwp_deny_response_contact_boilerplate = _(<<-HTML.strip_heredoc.squish
      <h3>You cannot do this using WhatDoTheyKnow</h3>
      <p>
        You should contact the office that handles your claim directly with any 
        concerns that you might have. You'll find their details at 
        <a href="http://www.dwp.gov.uk">dwp.gov.uk</a>, or below.<br><br>
        In Northern Ireland, most benefits are managed by the
        <a href="/body/dfc">Department for Communities</a>.
      </p>
      <hr>
    HTML
    # we reuse this multiple times with #{dwp_deny_response_contact_boilerplate}
  )

  dwp_deny_response_claim_benefits = _(<<-HTML.strip_heredoc.squish
      <h3>You cannot make a claim using WhatDoTheyKnow</h3>

      <p>
        You can find information about how to claim benefits on the
        <a href="https://www.gov.uk/browse/benefits">gov.uk website</a>.
      </p>
      <div style="text-align:center">
        <a class="button" 
        href="https://www.gov.uk/browse/benefits">
        Find out about benefits on gov.uk »</a>
      </div>
      <p>
        Information you might find useful:
        <ul>
          <li>
            You can use an independent 
            <a href="https://www.gov.uk/benefits-calculators">
            benefits calculator</a> to find out what benefits and services 
            that you may be entitled to.
          </li>
          <li>
            In <strong>Northern Ireland</strong>, some benefits are managed 
            directly by the <a href="/body/dfc">Department for Communities</a>. 
            You can find further information on 
            <a href="https://www.nidirect.gov.uk/campaigns/unclaimed-benefits">
            nidirect.gov.uk</a>
          </li>
          <li>
            In <strong>Scotland</strong>, some benefits are managed directly 
            by <a href="/body/social_security_scotland">
            Social Security Scotland</a>. You can find further information on
            <a href="https://www.mygov.scot/browse/benefits">mygov.scot</a>
          </li>
          <li>
            If you are unsure about benefits and need advice, you could get 
            independent help and support by contacting:
            <ul>
              <li>
                <a href="https://www.citizensadvice.org.uk/benefits/">
                Citizens Advice</a>
              <li>
                your local 
                <a href="https://www.citizensadvice.org.uk/about-us/contact-us/contact-us/search-for-your-local-citizens-advice/">
                Citizens Advice Bureaux</a> (in England or Wales)
              </li>
              <li>
                your local 
                <a href="https://www.cas.org.uk/bureaux">
                Citizens Advice Bureaux</a> (in Scotland)
              </li>
              <li>
              <a href="https://advicefinder.turn2us.org.uk/">Turn2Us</a>
              </li>
              <li>
                or your local 
                <a href="https://www.lawcentres.org.uk/i-am-looking-for-advice">
                Law Centre</a>.
              </li>
            </ul>
            #{generic_deny_askcouncil}
          </li>
        </ul>
      </p>
      #{generic_deny_boilerplate}
    HTML
  )

  dwp_deny_response_claim_pension = _(<<-HTML.strip_heredoc.squish
      <h3>You cannot claim your State Pension using WhatDoTheyKnow</h3>

      <p>
        You can find information about how to start a claim for the State
        Pension on the
        <a href="https://www.gov.uk/get-state-pension">gov.uk website</a>.
      </p>
      <div style="text-align:center">
        <a class="button" 
        href="https://www.gov.uk/get-state-pension">
        Find out about the State Pension on gov.uk »</a>
      </div>
      <p>
        Information you might find useful:
        <ul>
          <li>
            In <b>Northern Ireland</b>, you need to contact the 
            <a href="/body/dfc">Department for Communities</a> to make your 
            claim. You can find more information on:
            <a href="https://www.nidirect.gov.uk/services/get-your-state-pension">
            nidirect.gov.uk</a>.
          </li>
          <li>
            If you are <b>outside the UK</b>, you need to contact the 
            <a href="https://www.gov.uk/state-pension-if-you-retire-abroad">
            International Pensions Centre</a> to make your claim.
          </li>
          <li>
            Advice on retirement options is available on the 
            <a href="https://www.gov.uk/plan-for-retirement">
            gov.uk website</a>, and from 
            <a href="http://moneyhelper.org.uk/pensionwise">Pension Wise</a>, a 
            free government service provided by 
            <a href="/body/maps">MoneyHelper</a>.
          </li>
        </ul>
        <strong>Protect yourself against pension scams</strong> by following the 
        <a href="https://www.actionfraud.police.uk/a-z-of-fraud/pension-scams">
        useful tips</a> provided by Action Fraud.
      </p>
      #{generic_deny_boilerplate}
    HTML
  )

  dwp_deny_response_contact_dwp_disability = _(<<-HTML.strip_heredoc.squish 
      #{dwp_deny_response_contact_boilerplate}
      <h4>Disability and Carers Benefits
        (<abbr title="Attendance Allowance">AA</abbr> /
        <abbr title="Carers Allowance">CA</abbr> /
        <abbr title="Disability Living Allowance">DLA</abbr> /
        <abbr title="Personal Independence Payment">PIP</abbr>)</h4>
      <p>
        <ul>
          <li>
            You can find direct contact details for the Disability Service 
            Centre on the 
            <a href="https://www.gov.uk/disability-benefits-helpline">
            gov.uk website</a>.
          </li>
          <li>
            There's different details for the Carers Allowance Unit. You can 
            find them on the <a href="https://www.gov.uk/carers-allowance-unit">
            gov.uk website</a>
        </ul>
      </p>
      #{generic_deny_boilerplate}
    HTML
  )

  dwp_deny_response_contact_dwp_jcp = _(<<-HTML.strip_heredoc.squish 
      #{dwp_deny_response_contact_boilerplate}
      <h4>JobCentre Plus services (including 
        <abbr title="Employment and Support Allowance">ESA</abbr> /
        <abbr title="Jobseekers Allowance">JSA</abbr> /
        <abbr title="Incapacity Benefit">IB</abbr> /
        <abbr title="Income Support">IS</abbr>)
      </h4>
      <p>
        <ul>
          <li>
            You can find direct contact details for JobCentre Plus services on  
            the <a href="https://www.gov.uk/contact-jobcentre-plus">
            gov.uk website</a>.
          </li>
          <li>
            There's also specific information available for Access to Work on
            the <a href="https://www.gov.uk/access-to-work/apply#access-to-work-helpline">
            gov.uk website</a>
          <li>
            You can also find out where your local JobCentre Plus office is 
            located, along with their contact details, on the 
            <a href="https://find-your-nearest-jobcentre.dwp.gov.uk/">
            Local Office Search</a> website.
          </li>
        </ul>
      </p>
      #{generic_deny_boilerplate}
    HTML
  )

  dwp_deny_response_contact_dwp_pensions = _(<<-HTML.strip_heredoc.squish 
      #{dwp_deny_response_contact_boilerplate}
      <h4>The Pensions Service</h4>
      <p>
        <ul>
          <li>
            You can find details on how to contact The Pension Service on the 
            <a href="https://www.gov.uk/contact-pension-service">
            gov.uk website</a>.
          </li>
          <li>
            In <strong>Northern Ireland</strong>, you should contact the 
            <a href="https://www.nidirect.gov.uk/contacts/northern-ireland-pension-centre">
            Northern Ireland Pension Centre</a>, which is part of the
            <a href="/body/dfc">Department for Communities</a>.
          </li>
          <li>
            If you are <strong>outside of the UK</strong>, you should contact 
            the <a href="https://www.gov.uk/international-pension-centre">
            International Pensions Centre</a>.
          </li>
        </ul>
      </p>
      #{generic_deny_boilerplate}
    HTML
  )

  dwp_deny_response_contact_dwp_uc = _(<<-HTML.strip_heredoc.squish 
      #{dwp_deny_response_contact_boilerplate}
      <h4>Universal Credit</h4>
      <p>
        <ul>
          <li>
            You can find details on how to contact Universal Credit, on the 
            <a href="https://www.gov.uk/universal-credit/contact-universal-credit#guide-contents">
            gov.uk website</a>.
          </li>
          <li>
            If you've an <strong>existing claim</strong> you can manage it, and 
            send messages to the Universal Credit Service Centre via the 
            <a href="https://www.universal-credit.service.gov.uk/sign-in">
            Universal Credit journal</a>.
          </li>
          <li>
            You can also find details about <strong>other help and financial
            support</strong> on the
            <a href="https://www.gov.uk/universal-credit/other-financial-support">
            gov.uk</a> and 
            <a href="https://www.citizensadvice.org.uk/benefits/universal-credit/">
            Citizens Advice</a> websites.
          </li>
        </ul>
      </p>
      #{generic_deny_boilerplate}
    HTML
  )

  dwp_deny_response_contact_dwp_other = _(<<-HTML.strip_heredoc.squish 
      #{dwp_deny_response_contact_boilerplate}
      <h4>Other DWP benefits and services</h4>
        <ul>
          <li>
            You can find a full list of DWP services, along with their contact 
            details on their website at: 
            <a href="http://www.dwp.gov.uk#what-we-do">dwp.gov.uk</a>.
          </li>
          <li>
            If you have questions, you can contact the DWP Ministerial 
            Correspondence Team via the 
            <a href="https://www.gov.uk/guidance/contact-the-department-for-work-and-pensions-about-its-policies">
            gov.uk website</a>.
          </li>
        </ul>
      </p>
      #{generic_deny_boilerplate}
    HTML
  )

  dwp_deny_response_challenge_dwp = _(<<-HTML.strip_heredoc.squish
      <h3>You cannot challenge a benefits decision using WhatDoTheyKnow</h3>

      <p>
        WhatDoTheyKnow isn't the right place to challenge a benefits decision, 
        as your correspondence would be automatically published for everyone
        to see.
      </p>
      <p>
        Here's what to do:
        <ul>
          <li>
            Contact your benefits centre 
            <a href="https://www.gov.uk/mandatory-reconsideration">
            for assistance</a>.
          </li>
          <li>
            You can ask for help from:
            <ul>
              <li>
                <a href="https://www.citizensadvice.org.uk/benefits/benefits-introduction/problems-with-benefits-and-tax-credits/challenging-benefit-decisions/">
                Citizens Advice</a>
              <li>
                your local 
                <a href="https://www.citizensadvice.org.uk/about-us/contact-us/contact-us/search-for-your-local-citizens-advice/">
                Citizens Advice Bureaux</a> (in England or Wales)
              </li>
              <li>
                your local 
                <a href="https://www.cas.org.uk/bureaux">
                Citizens Advice Bureaux</a> (in Scotland)
              </li>
              <li>
              <a href="https://advicefinder.turn2us.org.uk/">Turn2Us</a>
              </li>
              <li>
                an advocacy charity, Welfare Rights adviser, or law centre.
              </li>
            </ul>
            #{generic_deny_askcouncil}
          </li>
          <li>
            You can also contact your <a onclick="if (ga) { ga('send','event','Outbound Link','Write To Them Exit','Public Body Questions',1) };" 
            href="http://www.writetothem.com">elected members</a> for help.
          </li>
        </ul>
      </p>
      #{generic_deny_boilerplate}
    HTML
  )

  dwp_deny_response_manage_csa = _(<<-HTML.strip_heredoc.squish
      <h3>You cannot manage your Child Support case using WhatDoTheyKnow</h3>
      <p>
        WhatDoTheyKnow isn't the right place to manage your Child Support,
        as your correspondence would be automatically published for everyone
        to see.
      </p>      
      <h4>To set up Child Maintenance</h4>
      <p>
        <ul>
          <li>
            Visit the 
            <a href="https://www.gov.uk/making-child-maintenance-arrangement">
            gov.uk website</a> to learn more about your options
          </li>
          <li>
            contact an advice service, such as 
            <a href="https://www.gingerbread.org.uk/what-we-do/contact-us/">
            Gingerbread</a>, or 
            <a href="https://www.citizensadvice.org.uk/family/children-and-young-people/child-maintenance1">
            Citizens Advice</a>.
          </li>
        </ul>
      </p>
      <h4>To manage your Child Maintenance case</h4>
      <p>
        To manage an existing Child Maintenance case, or if you have queries,
        you should:
        <ul>
          <li>
            Manage your case on the
            <a href="https://childmaintenanceservice.direct.gov.uk">
            Child Maintenance Service website</a>.
          </li>
          <li>
            Contact the 
            <a href="https://www.gov.uk/manage-child-maintenance-case/contact">
            Child Maintenance Service</a> directly.
          </li>
          <li>
            In <strong>Northern Ireland</strong>, you should contact the 
            <a href="https://www.nidirect.gov.uk/contacts/child-maintenance-service">
            Northern Ireland Child Maintenance Service</a> instead.
          </li>
        </ul>
      </p>
      <h4>If you are unhappy</h4>
      <p>  
        If you are unhappy with a decision made by Child Maintenance Service, 
        you may wish to:
        <ul>
          <li>
            contact an advice service, such as 
            <a href="https://www.gingerbread.org.uk/what-we-do/contact-us/">
            Gingerbread</a>, or 
            <a href="https://www.citizensadvice.org.uk/family/children-and-young-people/child-maintenance1">
            Citizens Advice</a>.
          </li>
          <li>
            make a complaint to the 
            <a href="https://www.gov.uk/manage-child-maintenance-case/complaints-and-appeals">
            Child Maintenance Service
            </a>
          </li>
          <li>
            write to your <a onclick="if (ga) { ga('send','event','Outbound Link','Write To Them Exit','Public Body Questions',1) };" 
              href="http://www.writetothem.com">elected members</a> for help.
          </li>
        </ul>
      </p>
      #{generic_deny_boilerplate}
    HTML
  )

  dwp_deny_response_make_complaint = _(<<-HTML.strip_heredoc.squish
      <h3>You cannot make a complaint using WhatDoTheyKnow</h3>

      <p>
        You should contact the DWP Complaints team directly.
        You can find their complaints procedure and contact details on the 
        <a href="https://www.gov.uk/government/organisations/department-for-work-pensions/about/complaints-procedure">
        gov.uk website</a>.
          <ul>
          <li>
            You could also try emailing DWP directly at 
            <a href="mailto:correspondence@dwp.gov.uk">
            correspondence@dwp.gov.uk
            </a>
          </li>
          <li>
            You can also <a onclick="if (ga) { ga('send','event','Outbound Link','Write To Them Exit','Public Body Questions',1) };" 
            href="http://www.writetothem.com">
            write to your elected members</a> for help.
          </li>
          <li>
            There's also information on what to do if you are unhappy with the 
            DWP response to your complaint on the 
            <a href="https://www.gov.uk/government/publications/how-to-take-a-complaint-to-the-independent-case-examiner">
            Independent Case Examiner's website</a>.
          </li>
        </ul> 
      </p>
      #{generic_deny_boilerplate}
    HTML
  )

  dwp_deny_response_rightofaccess = _(<<-HTML.strip_heredoc.squish 
      #{generic_deny_gdpr_rightofaccess}
      <h4>Getting access to information held by the DWP</h4>
      <p>
        Sometimes, you don't need to make a formal request - if you simply need 
        proof of your benefits, contacting the Benefit Office that handles your 
        claim can often be quicker.
      </p>
      <p>  
        You can find details on how to make a <strong>Right of Access request
        </strong> to the DWP and its agencies 
        <a href="https://www.gov.uk/guidance/request-your-personal-information-from-the-department-for-work-and-pensions">
        on gov.uk</a>.
      </p>
      <p>
      <div style="text-align:center">
        <a class="button" 
        href="https://www.gov.uk/guidance/request-your-personal-information-from-the-department-for-work-and-pensions#if-you-need-a-copy-of-any-other-information-that-dwp-holds-about-you">
        Make a Right of Access request on the DWP website»</a>
      </div>
      &nbsp;
      #{generic_deny_boilerplate}
    HTML
  )

  ## social security scotland

  socsecscot_deny_response_benefits_claim = _(<<-HTML.strip_heredoc.squish
      <h3>You cannot do this using WhatDoTheyKnow</h3>

      <p>
        You can find information about how to claim benefits on the
        <a href="https://www.mygov.scot/browse/benefits/how-to-find-out">
        mygov.scot website</a>.
      </p>
      <div style="text-align:center">
        <a class="button" 
        href="https://www.mygov.scot/browse/benefits/how-to-find-out">
        Find out about benefits on mygov.scot »</a>
      </div>
      <p>
        Information you might find useful:
        <ul>
          <li>
            Not all benefits in Scotland are 
            <a href="https://www.gov.scot/publications/responsibility-for-benefits-overview/">
            devolved</a>, meaning that some are looked after by the 
            <a href="/body/dwp">Department for Work and Pensions</a> instead.
            <br><br>
            You can find more infomation about other benefits on the
            <a href="https://www.gov.uk/browse/benefits">gov.uk website</a>.
          </li>
          <li>
            You can get free, independent advice on what benefits you may be   
            entitled to from the 
            <a href="https://moneytalkteam.org.uk/services/accessing-benefits">
            Money Talk Team</a>, part of Citizens Advice Scotland.
          </li>
          <li>
            You can use an independent 
            <a href="https://www.gov.uk/benefits-calculators">
            benefits calculator</a> to find out what benefits and services that 
            you may be entitled to.
          </li>
          <li>
            If you are unsure about benefits and need advice, you could get 
            independent help and support by contacting:
            <ul>
              <li>
                <a href="https://www.citizensadvice.org.uk/scotland/">
                Citizens Advice Scotland</a>
              <li>
                your local 
                <a href="https://www.cas.org.uk/bureaux">
                Citizens Advice Bureaux</a>
              </li>
              <li>
              <a href="https://advicefinder.turn2us.org.uk/">Turn2Us</a>
              </li>
              <li>
                or your local 
                <a href="https://scotland.shelter.org.uk/housing_advice/complaints_and_court_action/legal_representation/law_centres">
                Law Centre</a>.
              </li>
            </ul>
            #{generic_deny_askcouncil}
          </li>
        </ul>
      </p>
      #{generic_deny_boilerplate}
    HTML
  )
  
  socsecscot_deny_response_benefits_contact = _(<<-HTML.strip_heredoc.squish
      <h3>You cannot do this using WhatDoTheyKnow</h3>

      <p>
        You should contact the office that handles your claim directly with any 
        concerns that you might have. You'll find their details on the  
        <a href="https://www.mygov.scot/contact-social-security-scotland">
        mygov.scot website</a>. You can usually contact them via 
        Web Chat, the telephone, Contact Scotland BSL, or by post.
      </p>
      <div style="text-align:center">
        <a class="button" 
        href="https://www.mygov.scot/contact-social-security-scotland">
        Contact Social Security Scotland »</a>
      </div>
      <section>
        <h4>Are you contacting the correct agency?</h4>
        <p>
          Not all benefits in Scotland are 
          <a href="https://www.gov.scot/publications/responsibility-for-benefits-overview/">
          devolved</a>, meaning that some are looked after by the 
          <a href="/body/dwp">Department for Work and Pensions</a> instead.
        </p>
        <p>
          You can find more infomation on how to contact the DWP on the
          <a href="https://www.gov.uk/browse/benefits">gov.uk website</a>
        </p>
      </section>
      #{generic_deny_boilerplate}
    HTML
  )

  socsecscot_deny_response_make_complaint = _(<<-HTML.strip_heredoc.squish
      <h3>You cannot make a complaint using WhatDoTheyKnow</h3>

      <p>
        You should contact the office that handles your claim directly.
        You can find their complaints procedure and contact details on the 
        <a href="https://www.mygov.scot/complain-social-security-scotland">
        mygov.scot website</a>.
          <ul>
          <li>
            You could also try contacting the agency directly, using their web 
            chat service at: 
            <a href="https://chat.socialsecurity.gov.scot/">
            chat.socialsecurity.gov.scot
            </a>
          </li>
          <li>
            You can make a complaint 
            <a href="https://www.socialsecurity.gov.scot/contact/feedback/how-to-make-a-complaint">
            online</a>, via the telephone, Contact Scotland BSL, or by post.
          <li>
            You can also <a onclick="if (ga) { ga('send','event','Outbound Link','Write To Them Exit','Public Body Questions',1) };" 
            href="http://www.writetothem.com">
            write to your elected members</a> for help.
          </li>
          <li>
            You can also seek independent advice, from:
            <ul>
              <li>
                <a href="https://www.citizensadvice.org.uk/scotland/">
                Citizens Advice Scotland</a>
              <li>
                your local 
                <a href="https://www.cas.org.uk/bureaux">
                Citizens Advice Bureaux</a>
              </li>
              <li>
              <a href="https://advicefinder.turn2us.org.uk/">Turn2Us</a>
              </li>
              <li>
                or your local 
                <a href="https://scotland.shelter.org.uk/housing_advice/complaints_and_court_action/legal_representation/law_centres">
                Law Centre</a>.
              </li>
            </ul>
            #{generic_deny_askcouncil}
          </li>
        </ul> 
      </p>
      #{generic_deny_boilerplate}
    HTML
  )

  socsecscot_deny_response_rightofaccess = _(<<-HTML.strip_heredoc.squish 
      #{generic_deny_gdpr_rightofaccess}
      <h4>Getting access to information held by Social Security Scotland</h4>
      <p>
        Sometimes, you don't need to make a formal request - if you simply need 
        proof of your benefits, contacting the Benefit Office that handles your 
        claim can often be quicker.
      </p>
      <p>  
        You can find details on how to make a <strong>Right of Access request
        </strong> to the Social Security Scotland and its agencies 
        <a href="https://www.mygov.scot/social-security-data">
        on mygov.scot</a>.
      </p>
      <p>
      <div style="text-align:center">
        <a class="button" 
        href="https://www.socialsecurity.gov.scot/contact/subject-access">
        Make a Right of Access request on the Social Security Scotland website»
        </a>
      </div>
      &nbsp;
      #{generic_deny_boilerplate}
    HTML
  )

  ## build public body questions

  ## Home Office
  
  PublicBodyQuestion.build(
    public_body: home_office,
    key: :visa,
    question: _('Get information about my Visa'),
    response: home_office_deny_response_immi
  )

  PublicBodyQuestion.build(
    public_body: home_office,
    key: :immigration,
    question: _('Get advice on my immigration case'),
    response: home_office_deny_response_immi
  )

  PublicBodyQuestion.build(
    public_body: home_office,
    key: :brp,
    question: _('Find out about Biometric Residence Permit (BRP) ' \
                'replacements or refunds?'),
    response: home_office_deny_response_immi
  )

  PublicBodyQuestion.build(
    public_body: home_office,
    key: :passport,
    question: _('Get or replace a passport'),
    response: home_office_deny_response_passport
  )

  PublicBodyQuestion.build(
    public_body: home_office,
    key: :contact_rightofaccess,
    question: _('Get a copy of information held about me'),
    response: home_office_deny_response_rightofaccess
  )

  PublicBodyQuestion.build(
    public_body: home_office,
    key: :foi,
    question: _('Ask for recorded information that <strong>anyone</strong> ' \
                'could reasonably request and expect to receive'),
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
                'anyone could reasonably request and expect to receive?'),
    response: :allow
  )
  ## Department for Communities

  PublicBodyQuestion.build(
    public_body: dfc,
    key: :dfc_claim_benefits,
    question: _('Make a claim for Social Security benefits'),
    response: dfc_deny_response_benefits_claim
  )

  PublicBodyQuestion.build(
    public_body: dfc,
    key: :dfc_claim_pension,
    question: _('Claim my State Pension'),
    response: dwp_deny_response_claim_pension
    # We reuse the DWP response here as it is substantively the same.
  )

  PublicBodyQuestion.build(
    public_body: dfc,
    key: :dfc_contact_benefits,
    question: _('Contact DfC about my Social Security benefits'),
    response: dfc_deny_response_benefits_contact
  )

  PublicBodyQuestion.build(
    public_body: dfc,
    key: :manage_child_maintenance,
    question: _('Manage your Child Maintenance / Support case'),
    response: dwp_deny_response_manage_csa
    # We reuse the DWP response here as it is substantively the same.
  )
  
  PublicBodyQuestion.build(
    public_body: dfc,
    key: :contact_rightofaccess,
    question: _('Get a copy of information held about me'),
    response: dfc_deny_response_rightofaccess
  )

  PublicBodyQuestion.build(
    public_body: dfc,
    key: :make_dfc_complaint,
    question: _('Make a complaint'),
    response: dfc_deny_response_make_complaint
  )

  PublicBodyQuestion.build(
    public_body: dfc,
    key: :foi,
    question: _('Ask for recorded information that <strong>anyone</strong> ' \
                'could reasonably request and expect to receive'),
    response: :allow
  )

  ## DWP

  PublicBodyQuestion.build(
    public_body: dwp,
    key: :claim_benefits,
    question: _('Claim social security benefits'),
    response: dwp_deny_response_claim_benefits
  )

  PublicBodyQuestion.build(
    public_body: dwp,
    key: :claim_pension,
    question: _('Claim my State Pension'),
    response: dwp_deny_response_claim_pension
  )

  PublicBodyQuestion.build(
    public_body: dwp,
    key: :contact_disabilitycentre,
    question: _('Contact the Disability Service Centre ('\
      '<abbr title="Attendance Allowance">AA</abbr> / '\
      '<abbr title="Carers Allowance">CA</abbr> / '\
      '<abbr title="Disability Living Allowance">DLA</abbr> / '\
      '<abbr title="Personal Independence Payment">PIP</abbr>)'),
    response: dwp_deny_response_contact_dwp_disability
  )
  
  PublicBodyQuestion.build(
    public_body: dwp,
    key: :contact_jcp,
    question: _('Contact Jobcentre Plus (including '\
      '<abbr title="Employment and Support Allowance">ESA</abbr> / '\
      '<abbr title="Jobseekers Allowance">JSA</abbr> / '\
      '<abbr title="Incapacity Benefit">IB</abbr> / '\
      '<abbr title="Income Support">IS</abbr> )'),
    response: dwp_deny_response_contact_dwp_jcp
  )
  
  PublicBodyQuestion.build(
    public_body: dwp,
    key: :contact_pensionservice,
    question: _('Contact The Pensions Service'),
    response: dwp_deny_response_contact_dwp_pensions
  )
  PublicBodyQuestion.build(
    public_body: dwp,
    key: :contact_universalcredit,
    question: _('Contact Universal Credit'),
    response: dwp_deny_response_contact_dwp_uc
  )

  PublicBodyQuestion.build(
    public_body: dwp,
    key: :contact_dwp_other,
    question: _('Contact DWP about other benefits and services'),
    response: dwp_deny_response_contact_dwp_other
  )

  PublicBodyQuestion.build(
    public_body: dwp,
    key: :manage_child_maintenance,
    question: _('Manage your Child Maintenance / Support case'),
    response: dwp_deny_response_manage_csa
  )

  PublicBodyQuestion.build(
    public_body: dwp,
    key: :challenge_a_decision,
    question: _('Challenge a decision'),
    response: dwp_deny_response_challenge_dwp
  )
    
  PublicBodyQuestion.build(
    public_body: dwp,
    key: :make_dwp_complaint,
    question: _('Make a complaint'),
    response: dwp_deny_response_make_complaint
  )

  PublicBodyQuestion.build(
    public_body: dwp,
    key: :contact_rightofaccess,
    question: _('Get a copy of information held about me'),
    response: dwp_deny_response_rightofaccess
  )
  
  PublicBodyQuestion.build(
    public_body: dwp,
    key: :foi,
    question: _('Ask for recorded information that <strong>anyone</strong> '\
                'could reasonably request and expect to receive'),
    response: :allow
  )

  ## Social Security Scotland

  PublicBodyQuestion.build(
    public_body: socsecscot,
    key: :socsecscot_claim_benefits,
    question: _('Make a claim for Social Security benefits'),
    response: socsecscot_deny_response_benefits_claim
  )

  PublicBodyQuestion.build(
    public_body: socsecscot,
    key: :socsecscot_claim_pension,
    question: _('Claim my State Pension'),
    response: dwp_deny_response_claim_pension
    # We reuse the DWP response here as it isn't a devolved benefit
  )

  PublicBodyQuestion.build(
    public_body: socsecscot,
    key: :socsecscot_contact_benefits,
    question: _('Contact Social Security Scotland about my benefits'),
    response: socsecscot_deny_response_benefits_contact
  )

  PublicBodyQuestion.build(
    public_body: socsecscot,
    key: :manage_child_maintenance,
    question: _('Manage your Child Maintenance / Support case'),
    response: dwp_deny_response_manage_csa
    # We reuse the DWP response here as it isn't a devolved service
  )

  PublicBodyQuestion.build(
    public_body: socsecscot,
    key: :socsecscot_contact_rightofaccess,
    question: _('Get a copy of information held about me'),
    response: socsecscot_deny_response_rightofaccess
  )

  PublicBodyQuestion.build(
    public_body: socsecscot,
    key: :make_socsecscot_complaint,
    question: _('Make a complaint'),
    response: socsecscot_deny_response_make_complaint
  )

  PublicBodyQuestion.build(
    public_body: socsecscot,
    key: :foi,
    question: _('Ask for recorded information that <strong>anyone</strong> ' \
                'could reasonably request and expect to receive'),
    response: :allow
  )
end
