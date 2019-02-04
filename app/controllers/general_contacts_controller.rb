class GeneralContactsController < ApplicationController
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