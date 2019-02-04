class GeneralContactsController < ApplicationController
  skip_before_action :show_analytics
  skip_before_action :set_locale
  skip_before_action :persist_locale
  skip_before_action :authenticate_user!
  skip_before_action :set_editor_config
  skip_before_action :set_localizable_page

  def create
    @contact = GeneralContact.new(params[:general_contact])
    @contact.request = request
    if @contact.deliver
      puts 'Obrigado por enviar sua mensagem. Entraremos em contato em breve!'
      flash.now[:notice] = 'Obrigado por enviar sua mensagem. Entraremos em contato em breve!'
      redirect_to root_path, notice: 'Obrigado por enviar sua mensagem. Entraremos em contato em breve!'
    else
      puts 'Não foi possível enviar a mensagem.'
      puts @contact.errors.to_json
      flash.now[:error] = 'Não foi possível enviar a mensagem.'
      redirect_to root_path, error: 'Não foi possível enviar a mensagem.'
    end
  end
end