class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :persist_locale
  before_action :authenticate_user!
  before_action :set_editor_config
  before_action :set_localizable_page

  def after_sign_up_path_for(resource)
    root_path
  end

  def after_sign_in_path_for(resource)
    root_path
  end

  def after_sign_out_path_for(resource)
    root_path
  end

  def set_location
    @location = { id: 'pt_BR', name: 'SP', lat: -23.5733838, lng: -46.651777700000025 }
    @location_id = @location[:id]

    temperature_date_s = Rails.cache.fetch('forecast_time_' + @location_id) do
      set_temperature_from_api
      Time.new
    end
    temperature_date = temperature_date_s.to_time

    if (Time.new - temperature_date) > 1.hour
      set_temperature_from_api
    else
      set_temperature_from_cache
    end

    # .icon pode ser:
    # clear-day, clear-night, rain, snow, sleet, wind, fog, cloudy, partly-cloudy-day, or partly-cloudy-night (maybe in the future: hail, thunderstorm, or tornado)
    # logger.debug @current_temperature
  end

  private
    def set_temperature_from_api
      logger.debug "--------SET_TEMPERATURE_FROM_API----------"
      begin
        temperature = ForecastIO.forecast(@location[:lat], @location[:lng], language: I18n.locale.to_s, exclude: "minutely,hourly,alerts,flags")
        current_temperature = temperature.currently

        @temperature = current_temperature.temperature
        @celsius_temperature = (5*(@temperature.to_f - 32))/9
        @forecast_type = current_temperature.icon
        @forecast_cloud = current_temperature.cloudCover
        @forecast_sunrise = Time.at(temperature.daily.data[0].sunriseTime)
        @forecast_sunset = Time.at(temperature.daily.data[0].sunsetTime)
        @forecast_is_night = Time.new < @forecast_sunrise || Time.new > @forecast_sunset

        current_time = Time.new
        Rails.cache.write('forecast_far_' + @location_id, @temperature.to_s)
        Rails.cache.write('forecast_cel_' + @location_id, @celsius_temperature.to_s)
        Rails.cache.write('forecast_type_' + @location_id, @forecast_type)
        Rails.cache.write('forecast_cloud_' + @location_id, @forecast_cloud.to_s)
        Rails.cache.write('forecast_sunrise' + @location_id, @forecast_sunrise.to_s)
        Rails.cache.write('forecast_sunset' + @location_id, @forecast_sunset.to_s)
        Rails.cache.write('forecast_time_' + @location_id, current_time.to_s)

        # logger.debug @temperature.to_s
        # logger.debug @celsius_temperature.to_s
        # logger.debug @forecast_type.to_s
        # logger.debug @forecast_sunrise.to_s
        # logger.debug @forecast_sunset.to_s
      rescue => e
        # se mesmo assim der erro ai fazemos o log
        Rollbar.error(e, params: params.to_json)
        raise e
      end
    end

    def set_temperature_from_cache
      begin
        logger.debug "--------SET_TEMPERATURE_FROM_CACHE----------"
        @temperature = Rails.cache.fetch('forecast_far_' + @location_id).to_f
        @celsius_temperature = Rails.cache.fetch('forecast_cel_' + @location_id).to_f
        @forecast_type = Rails.cache.fetch('forecast_type_' + @location_id)
        @forecast_cloud = Rails.cache.fetch('forecast_cloud_' + @location_id).to_f
        @forecast_sunrise = Rails.cache.fetch('forecast_sunrise' + @location_id).to_time
        @forecast_sunset = Rails.cache.fetch('forecast_sunset' + @location_id).to_time
        @forecast_is_night = Time.new < @forecast_sunrise || Time.new > @forecast_sunset

        # logger.debug @temperature.to_s
        # logger.debug @celsius_temperature.to_s
        # logger.debug @forecast_type.to_s
        # logger.debug @forecast_sunrise.to_s
        # logger.debug @forecast_sunset.to_s
      rescue => e
        # se mesmo assim der erro ai fazemos o log
        Rollbar.error(e, params: params.to_json)
        raise e
      end
    end

    def redirect_to_locale_if_not_set
        if params[:locale]
          I18n.locale = params[:locale]
          # current_user_or_visitor.update(locale: I18n.locale.to_s)
        else
          locale = request_locale || I18n.default_locale
          redirect_to url_for(request.params.merge({ locale: locale }))
        end
      end

    def get_locale
      # params[:locale] || visitor_locale || request_locale || I18n.default_locale
      params[:locale] || request_locale || I18n.default_locale
    end

    def set_locale
      I18n.locale = get_locale
    end

    def persist_locale
      # current_user_or_visitor.update(locale: I18n.locale.to_s) if params[:locale]
    end

    def request_locale
      extra_locales = [:pt]
      locale = http_accept_language.preferred_language_from(I18n.available_locales + extra_locales)
      locale = 'pt-BR' if locale == :pt || locale.to_s.downcase == 'pt-pt' || locale.to_s.downcase == 'pt-br'
      locale
    end

    def set_editor_config
      @can_edit = current_user && current_user.type == Admin.name # or true
      @inplace_editing_mode = (@can_edit ? 'edit' : 'read')
    end

    def set_localizable_page
      @global_page = LocalizableValue::LocalizedPage.global_page

      route_control = controller_name ? controller_name : 'root'
      route_action = action_name ? action_name : 'home'
      @current_page = LocalizableValue::LocalizedPage.current_page(route_control, route_action)
    end
end
