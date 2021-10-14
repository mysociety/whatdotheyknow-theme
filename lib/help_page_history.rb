class HelpPageHistory
  GITHUB_BASE =
    'https://github.com/mysociety/whatdotheyknow-theme/commits/master'.freeze

  def initialize(template)
    @template = template
  end

  def commits_url
    template.short_identifier.gsub(/lib\/themes\/whatdotheyknow-theme/, GITHUB_BASE)
  end

  protected

  attr_reader :template
end
