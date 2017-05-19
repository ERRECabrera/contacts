module ExceptionHandler
  # provides the more graceful `included` method
  extend ActiveSupport::Concern

  included do

    # generic bugs must be in top
    rescue_from Exception do |e|
      logger.fatal '---BUG!!!!! - ' + e.message
      json_response({message: 'congratulations, you find a bug ;)'}, status: :internal_server_error)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      logger.info '*RecordNotFound - ' + e.message
      json_response({message: e.message}, status: :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      logger.info '*RecordInvalid - ' + e.message
      json_response({message: e.message}, status: :unprocessable_entity)
    end

  end
end