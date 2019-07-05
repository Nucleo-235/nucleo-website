class ProjectsMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  def all_projects(projects_data, base_date)
    @projects_data = projects_data
    @subject = "Projetos"
    @base_date = base_date
    mail_from = ENV['MAILER_FROM'] || 'kikecomp@gmail.com'
    mail(from: "Nucleo Reporter <#{mail_from}>", to: ENV['ADMIN_PROJ_MAIL'], subject: @subject)
  end
end
