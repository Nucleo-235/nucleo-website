class IndexesMailer < ApplicationMailer
  def list(indexes)
    @indexes = indexes
    mail_from = ENV['MAILER_FROM'] || 'kikecomp@gmail.com'
    mail(from: "Nucleo Índices <#{mail_from}>", to: ENV['ADMIN_MAIL'], subject: "Nucleo Índices")
  end
end
