class IndexesMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  def sales(indexes)
    @indexes = indexes
    mail_from = ENV['MAILER_FROM'] || 'kikecomp@gmail.com'
    mail(from: "Índices de Venda <#{mail_from}>", to: ENV['ADMIN_MAIL'], subject: "Nucleo Índices")
  end

  def execution(indexes)
    @indexes = indexes
    mail_from = ENV['MAILER_FROM'] || 'kikecomp@gmail.com'
    mail(from: "Índices de Execução <#{mail_from}>", to: ENV['ADMIN_MAIL'], subject: "Nucleo Índices")
  end
end
