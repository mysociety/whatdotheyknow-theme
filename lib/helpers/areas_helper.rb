# Helpers for area landing pages (/isle-of-wight etc).
module AreasHelper
  # Link to an area page with the given filter changes, preserving the other
  # active filters. Changing a filter deliberately resets pagination.
  def area_filter_path(area, changes = {})
    filters = {
      category: @category,
      sort: (@sort unless @sort == 'name'),
      public_body_query: params[:public_body_query].presence
    }

    area_path(area, filters.merge(changes).compact)
  end

  def area_category_title(category_tag)
    area_category_titles[category_tag] || category_tag.humanize
  end

  # Percentage of an authority's classified requests that were at least
  # partially successful, from the counter cache columns. nil when there
  # isn't enough data to be meaningful.
  def area_success_rate(public_body, minimum_requests = 5)
    classified = public_body.info_requests_visible_classified_count.to_i
    return if classified < minimum_requests

    (public_body.info_requests_successful_count.to_i * 100.0 /
      classified).round
  end

  private

  def area_category_titles
    # Instantiated rather than plucked as Category#title is translated
    @area_category_titles ||=
      PublicBody.category_list.
        where(category_tag: @area.category_tags).
        map { |category| [category.category_tag, category.title] }.
        to_h
  end
end
