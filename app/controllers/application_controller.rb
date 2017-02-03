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

  private
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
