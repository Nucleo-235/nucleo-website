class GeneralContactsController < ApplicationController
  # skip_before_action :show_analytics
  # skip_before_action :set_locale
  # skip_before_action :persist_locale
  # skip_before_action :authenticate_user!
  # skip_before_action :set_editor_config
  # skip_before_action :set_localizable_page

  skip_before_action :authenticate_user!
  skip_before_action :set_locale, only: [:create]
  skip_before_action :persist_locale, only: [:create]
  before_action :redirect_to_locale_if_not_set, only: [:create]

  def create
    # Set home info
    @partners = Partner.all

    @people = Person.where.not(type: Partner.name)

    @projects = Project.all.order(:sort_order)
    if @can_edit
      @categories = Category.all
      @new_project = Project.new
    end

    @general_contact = GeneralContact.new(params[:general_contact])
    @general_contact.request = request

    if !verify_recaptcha(model: @general_contact)
      redirect_to root_path, error: 'Não foi possível enviar a mensagem.'
    elsif @general_contact.deliver
      @general_contact = GeneralContact.new
      
      puts 'Obrigado por enviar sua mensagem. Entraremos em contato em breve!'
      flash.now[:notice] = 'Obrigado por enviar sua mensagem. Entraremos em contato em breve!'
      render :template => "pages/home"
    else
      puts 'Não foi possível enviar a mensagem.'
      flash.now[:error] = 'Não foi possível enviar a mensagem.'
      redirect_to root_path, error: 'Não foi possível enviar a mensagem.'
    end
  end
end