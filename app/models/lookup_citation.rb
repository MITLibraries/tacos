# frozen_string_literal: true

class LookupCitation
  # The info method is the way to return information about whether a given phrase is a citation. It consults an
  # external lambda service (address in env) and returns either a true or a false. The default if anything goes wrong
  # is to return false.
  #
  # @return Boolean or nil
  def info(phrase)
    return unless expected_env?

    external_data = fetch(phrase)
    return if external_data == 'Error'

    external_data
  end

  private

  def lambda_path
    ENV.fetch('DETECTOR_LAMBDA_PATH', nil)
  end

  def lambda_secret
    ENV.fetch('DETECTOR_LAMBDA_CHALLENGE_SECRET', nil)
  end

  def lambda_url
    ENV.fetch('DETECTOR_LAMBDA_URL', nil)
  end

  # define_lambda connects to the detector lambda.
  #
  # @return Faraday connection
  def define_lambda
    Faraday.new(
      url: lambda_url,
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
      challenge_secret: lambda_secret
    }
  end

  # expected_env? confirms that all three required environment variables are defined.
  #
  # @return Boolean
  def expected_env?
    Rails.logger.error('No lambda URL defined') if lambda_url.nil?

    Rails.logger.error('No lambda path defined') if lambda_path.nil?

    Rails.logger.error('No lambda secret defined') if lambda_secret.nil?

    [lambda_url, lambda_path, lambda_secret].all?(&:present?)
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

    response = lambda.post(lambda_path, payload.to_json)

    if response.status == 200
      JSON.parse(response.body)['response'] == 'true'
    else
      Rails.logger.error(response.body)
      Rails.logger.error(response.body['error'])

      'Error'
    end
  end
end
