# Registry of area landing pages (e.g. /isle-of-wight), giving a summary of
# and access to the public authorities serving a geographic area.
#
# See https://github.com/mysociety/whatdotheyknow-theme/issues/416
#
# Areas are driven entirely by authority tags, and all statistics come from
# the PublicBody counter cache columns or single indexed queries wrapped in
# Rails.cache, so rendering an area page adds no expensive load.
module WdtkAreas
  CACHE_EXPIRY = 12.hours

  ##
  # A geographic area with a landing page summarising the public authorities
  # that serve it, driven by an authority tag.
  class Area
    attr_reader :slug, :name, :tag, :tagline, :banner_image, :category_tags

    def initialize(slug:, name:, tag:, tagline:, banner_image: nil,
                   category_tags: [])
      @slug = slug
      @name = name
      @tag = tag
      @tagline = tagline
      @banner_image = banner_image
      @category_tags = category_tags
    end

    def to_param
      slug
    end

    def public_bodies
      PublicBody.visible.with_tag(tag)
    end

    # Topline stats for the area, aggregated from the counter cache columns
    # in a single query.
    def stats
      Rails.cache.fetch("wdtk_areas/#{slug}/stats", expires_in: CACHE_EXPIRY) do
        bodies, requests, successful, classified =
          public_bodies.pick(
            Arel.sql('COUNT(*)'),
            Arel.sql('COALESCE(SUM(info_requests_visible_count), 0)'),
            Arel.sql('COALESCE(SUM(info_requests_successful_count), 0)'),
            Arel.sql('COALESCE(SUM(info_requests_visible_classified_count), 0)')
          )

        { bodies: bodies, requests: requests, successful: successful,
          classified: classified }
      end
    end

    # Number of authorities in the area holding each of the curated category
    # tags, in a single grouped query. Returns { 'school' => 12, ... },
    # omitting empty categories.
    def category_counts
      Rails.cache.fetch("wdtk_areas/#{slug}/category_counts",
                        expires_in: CACHE_EXPIRY) do
        HasTagString::HasTagStringTag.
          where(model_type: 'PublicBody', name: category_tags).
          where(model_id: public_bodies.select(:id)).
          group(:name).
          count.
          sort_by { |tag_name, _| category_tags.index(tag_name) }.
          to_h
      end
    end

    # Recently successful requests to authorities in the area, to show that
    # FOI gets results locally. IDs are cached; records are re-fetched so we
    # never serve stale titles or requests that have since been hidden.
    def notable_requests(limit = 5)
      ids = Rails.cache.fetch("wdtk_areas/#{slug}/notable_request_ids",
                              expires_in: CACHE_EXPIRY) do
        InfoRequest.is_searchable.
          where(public_body_id: public_bodies.select(:id)).
          where(described_state: %w[successful partially_successful]).
          order(last_event_time: :desc).
          limit(limit).
          ids
      end

      InfoRequest.includes(:public_body, :user).
        is_searchable.
        where(id: ids).
        sort_by { |request| ids.index(request.id) }
    end
  end

  AREAS = [
    Area.new(
      slug: 'isle-of-wight',
      name: 'Isle of Wight',
      tag: 'isle_of_wight',
      tagline: 'Find the public authorities serving the Isle of Wight, ' \
               'see how they respond to Freedom of Information requests, ' \
               'and ask for the information you want.',
      banner_image: 'areas/isle_of_wight.svg',
      category_tags: %w[local_council parish_council school nhs police
                        fire_service]
    )
  ].freeze

  def self.all
    AREAS
  end

  def self.slugs
    AREAS.map(&:slug)
  end

  def self.find(slug)
    AREAS.find { |area| area.slug == slug }
  end

  def self.find!(slug)
    find(slug) ||
      raise(ActiveRecord::RecordNotFound, "Unknown area: #{slug}")
  end
end
