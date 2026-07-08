namespace :areas do
  desc 'Create dummy Isle of Wight authorities and requests to demo the ' \
       'area page at /isle-of-wight'
  task create_demo_data: :environment do
    abort 'Refusing to create dummy data in production' if Rails.env.production?

    # Saving records queues search reindexing, which crashes on dev machines
    # without the Xapian bindings installed
    Search.index_backends = [] unless ActsAsXapian.bindings_available

    DEMO_EDITOR = 'areas demo data task'

    bodies = {
      'Isle of Wight Council' =>
        %w[local_council],
      'Ryde Town Council' =>
        %w[parish_council],
      'Cowes Town Council' =>
        %w[parish_council],
      'East Cowes Town Council' =>
        %w[parish_council],
      'Newport and Carisbrooke Community Council' =>
        %w[parish_council],
      'Sandown Town Council' =>
        %w[parish_council],
      'Shanklin Town Council' =>
        %w[parish_council],
      'Ventnor Town Council' =>
        %w[parish_council],
      'Isle of Wight NHS Trust' =>
        %w[nhs nhstrust],
      'Hampshire and Isle of Wight Constabulary' =>
        %w[police police_force],
      'Hampshire and Isle of Wight Fire and Rescue Service' =>
        %w[fire_service],
      'Medina College' =>
        %w[school],
      'Carisbrooke College' =>
        %w[school],
      'Ryde Academy' =>
        %w[school],
      'The Bay Church of England School' =>
        %w[school],
      'Cowes Enterprise College' =>
        %w[school],
      'Christ the King College' =>
        %w[school]
    }

    request_titles = [
      'Spending on temporary accommodation',
      'Pothole repair budget and response times',
      'Contracts awarded for waste collection',
      'Number of FOI requests received last year',
      'Staff headcount and agency spending',
      'CCTV cameras in operation',
      'Business rates relief granted',
      'Air quality monitoring results',
      'Costs of external consultants',
      'School meal provision contracts',
      'Libraries opening hours and visitor numbers',
      'Flood defence maintenance spending',
      'Parking fines issued and appealed',
      'Cycling infrastructure investment',
      'Public toilets maintained by the authority',
      'Beach cleaning schedules and costs',
      'Ferry disruption contingency planning',
      'Coastal erosion monitoring reports',
      'Red squirrel conservation funding',
      'Tourism promotion spending'
    ]

    # Weighted mix of states so success rates differ believably per body
    states = %w[successful successful successful partially_successful
                waiting_response waiting_response not_held rejected]

    # Seeded so re-running produces the same demo dataset
    random = Random.new(416)

    user = User.find_or_create_by!(email: 'areas-demo@localhost') do |u|
      u.name = 'Areas Demo User'
      u.password = SecureRandom.hex(16)
      u.email_confirmed = true
      u.confirmed_not_spam = true
    end

    bodies.each do |name, category_tags|
      body = PublicBody.find_by(name: name)

      body ||= PublicBody.create!(
        name: name,
        request_email: "foi@#{name.parameterize}.example.com",
        last_edit_editor: DEMO_EDITOR,
        last_edit_comment: 'Created by areas:create_demo_data'
      )

      (%w[isle_of_wight] + category_tags).each do |tag|
        body.add_tag_if_not_already_present(tag)
      end

      if body.info_requests.where(user: user).any?
        puts "#{name}: demo requests already exist, skipping"
        next
      end

      request_count = random.rand(3..request_titles.size)

      request_titles.sample(request_count, random: random).each do |title|
        state = states.sample(random: random)
        created_at = random.rand(1..730).days.ago

        request = InfoRequest.new(
          title: "#{title} - #{name}",
          public_body: body,
          user: user,
          described_state: state,
          awaiting_description: false,
          created_at: created_at
        )

        request.outgoing_messages << OutgoingMessage.new(
          info_request: request,
          status: 'sent',
          message_type: 'initial_request',
          what_doing: 'normal_sort',
          last_sent_at: created_at,
          body: "Dear #{name},\n\nPlease provide the following " \
                "information: #{title.downcase}.\n\nYours faithfully,\n\n" \
                "Areas Demo User"
        )

        request.save!
        request.log_event(
          'sent',
          { email: body.request_email,
            outgoing_message_id: request.outgoing_messages.first.id },
          created_at: created_at
        )
      end

      body.update_counter_cache
      puts "#{name}: created #{request_count} demo requests"
    end

    # Expire cached area stats so the new data shows up immediately
    WdtkAreas.all.each do |area|
      %w[stats category_counts notable_request_ids].each do |key|
        Rails.cache.delete("wdtk_areas/#{area.slug}/#{key}")
      end
    end

    puts 'Done. Visit /isle-of-wight to see the area page.'
  end
end
