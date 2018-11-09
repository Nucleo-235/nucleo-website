class IndexesMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  def sales(indexes, base_date)
    @indexes = indexes[:detailed]
    @overall = indexes[:overall]
    @base_date = base_date
    @goal_version = ENV["GOAL_VERSION"]
    mail_from = ENV['MAILER_FROM'] || 'kikecomp@gmail.com'
    mail(from: "Índices de Venda <#{mail_from}>", to: ENV['ADMIN_MAIL'], subject: "Nucleo Índices (#{@goal_version})")
  end

  def execution(indexes, base_date)
    @indexes = indexes
    @base_date = base_date
    mail_from = ENV['MAILER_FROM'] || 'kikecomp@gmail.com'
    mail(from: "Índices de Execução <#{mail_from}>", to: ENV['ADMIN_MAIL'], subject: "Nucleo Índices")
  end
end
