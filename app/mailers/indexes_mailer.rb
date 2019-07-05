class IndexesMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  def sales(indexes, base_date)
    @indexes = indexes[:detailed]
    @overall = indexes[:overall]
    @base_date = base_date
    @goal_version = ENV["GOAL_VERSION"]
    mail_from = ENV['MAILER_FROM'] || 'kikecomp@gmail.com'
    mail(from: "Nucleo Reporter <#{mail_from}>", to: ENV['ADMIN_SALES_MAIL'], subject: "Índices de Venda (#{@goal_version})")
  end

  def execution(indexes, base_date)
    @indexes = indexes
    @base_date = base_date
    mail_from = ENV['MAILER_FROM'] || 'kikecomp@gmail.com'
    mail(from: "Nucleo Reporter <#{mail_from}>", to: ENV['ADMIN_PROJ_MAIL'], subject: "Nucleo Índices")
  end

  def followups_required(projects, base_date)
    @projects = projects
    @subject = "Follow-Ups necessários"
    @base_date = base_date
    mail_from = ENV['MAILER_FROM'] || 'kikecomp@gmail.com'
    mail(from: "Nucleo Reporter <#{mail_from}>", to: ENV['ADMIN_SALES_MAIL'], subject: @subject)
  end
end
