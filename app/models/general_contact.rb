class GeneralContact < MailForm::Base
  attribute :name,      :validate => true
  attribute :email,     :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :message,   :validate => true

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      :subject => "Website Nucleo - Contato",
      # :to => "comercial@gafor.com.br",
      :to => (ENV['ADMIN_MAIL'] || "hrangel@nucleo235.com.br"),
      :from => ('Website Nucleo <' + (ENV['MAILER_FROM'] || 'sender@nucleo.house') + '>'),
      :reply_to => %("#{name}" <#{email}>)
    }
  end
end