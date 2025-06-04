# frozen_string_literal: true

class Detector
  class MlCitation
    attr_reader :detections

    # For now the initialize method just needs to consult the external lambda.
    #
    #   @param phrase String. Often a `Term.phrase`.
    #   @return Nothing intentional. Data is written to Hash `@detections` during processing.
    def initialize(phrase)
      return unless self.class.expected_env?

      external_data = fetch(phrase)
      return if external_data == 'Error'

      @detections = external_data
    end

    def detection?
      @detections == true
    end

    # expected_env? confirms that all three required environment variables are defined. It is provided for the Term
    # model to check prior to calling because this is still an optional extension to TACOS. If this method returns
    # false, the Term model will fall back to the initial citation detector.
    #
    # @return Boolean
    def self.expected_env?
      Rails.logger.error('No lambda URL defined') if lambda_url.nil?

      Rails.logger.error('No lambda path defined') if lambda_path.nil?

      Rails.logger.error('No lambda secret defined') if lambda_secret.nil?

      [lambda_url, lambda_path, lambda_secret].all?(&:present?)
    end

    # The record method runs a supplied term through the detector via its initialize method, which consults the lambda.
    # If a positive result is received, a Detection is registered.
    #
    # @param term [Term]
    # @return nil
    def self.record(term)
      result = Detector::MlCitation.new(term.phrase)
      return unless result.detection?

      # Detections are registered to the "MlCitation" detector for now, but may end up replacing the "Citation" detector
      # in a future step.
      Detection.find_or_create_by(
        term:,
        detector: Detector.where(name: 'MlCitation').first,
        detector_version: ENV.fetch('DETECTOR_VERSION', 'unset')
      )

      nil
    end

    def self.lambda_path
      ENV.fetch('DETECTOR_LAMBDA_PATH', nil)
    end

    def self.lambda_secret
      ENV.fetch('DETECTOR_LAMBDA_CHALLENGE_SECRET', nil)
    end

    def self.lambda_url
      ENV.fetch('DETECTOR_LAMBDA_URL', nil)
    end

    private

    # define_lambda connects to the detector lambda.
    #
    # @return Faraday connection
    def define_lambda
      Faraday.new(
        url: self.class.lambda_url,
        params: {}
      )
    end

    # define_payload defines the Hash that will be sent to the lambda.
    #
    # @return Hash
    def define_payload(phrase)
      {
        action: 'predict',
        features: extract_features(phrase),
        challenge_secret: self.class.lambda_secret
      }
    end

    # extract_features passes the search phrase through the citation detector, and massages the resulting features object
    # to correspond with what the lambda expects.
    #
    # @return Hash
    def extract_features(phrase)
      features = Detector::Citation.new(phrase).features
      features[:apa] = features.delete :apa_volume_issue
      features[:year] = features.delete :year_parens
      features.delete :characters
      features
    end

    # Fetch handles the communication with the detector lambda: defining the connection, building the payload, and any
    # error handling with the response.
    #
    # @return Boolean or 'Error'
    def fetch(phrase)
      lambda = define_lambda
      payload = define_payload(phrase)

      response = lambda.post(self.class.lambda_path, payload.to_json)

      if response.status == 200
        JSON.parse(response.body)['response'] == 'true'
      else
        Rails.logger.error(response.body)
        Rails.logger.error(response.body['error'])

        'Error'
      end
    end
  end
end
