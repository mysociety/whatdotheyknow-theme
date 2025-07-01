##
# Configure insights to attempt to detect immigration related correspondence in
# new information requests.
#
module ImmigrationDetection
  extend ActiveSupport::Concern

  included do
    after_create :detect_immigration_correspondence
  end

  private

  def detect_immigration_correspondence
    # scope to Home Office & Passport Office
    return unless [7, 590].include?(public_body_id)

    insights.create(template: :immigration_detection)
  end
end

Rails.configuration.to_prepare do
  InfoRequest.include ImmigrationDetection

  Insight.register_template :immigration_detection,
    title: 'Dected immigration-related correspondence',
    attributes: {
      model: 'Toast_Llama:latest', temperature: 0.3, prompt_template: <<~TXT
        <|start_header_id|>system<|end_header_id|>
        Cutting Knowledge Date: December 2023
        You are an AI assistant tasked with analyzing text to determine if it is an Immigration-related request or a general Freedom of Information (FOI) request.
        An Immigration-related request is any inquiry or correspondence related to immigration processes, visas, residency, citizenship, or any other matter concerning a person's immigration status or application.
        A Freedom of Information (FOI) request is a request for any other type of information held by public authorities, including general government operations, policies, or decisions not related to immigration.
        Instructions:
        - Carefully read the entire text of the request.
        - Identify the main subject or focus of the inquiry.
        - If the request is related to immigration matters, classify it as "IMM".
        - For all other types of requests, classify it as "FOI".
        - Do not include any text or explanation in your response.
        - Your response should be either "IMM" or "FOI" and nothing else.
        <|eot_id|>

        <|start_header_id|>user<|end_header_id|>
        Analyze the following text and determine if it is an Immigration-related request or an FOI request:
        [initial_request]

        Return "IMM" if the request is related to immigration matters, otherwise return "FOI".
        <|eot_id|>

        <|start_header_id|>assistant<|end_header_id|>
      TXT
    }
end
