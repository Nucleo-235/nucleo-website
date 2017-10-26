class SocialMailer < ApplicationMailer
  def useful_links(spreadsheet_link, links)
    @spreadsheet_link = spreadsheet_link
    @links = links
    mail_from = ENV['MAILER_FROM'] || 'kikecomp@gmail.com'
    mail(from: "Nucleo Social <#{mail_from}>", to: ENV['ADMIN_MAIL'], subject: "Para postar: Links Úteis")
  end

  def inspirational_links(spreadsheet_link, links)
    @spreadsheet_link = spreadsheet_link
    @links = links
    mail_from = ENV['MAILER_FROM'] || 'kikecomp@gmail.com'
    mail(from: "Nucleo Social <#{mail_from}>", to: ENV['ADMIN_MAIL'], subject: "Para postar: Links que inspiram")
  end

  def comment_links(spreadsheet_link, links)
    @spreadsheet_link = spreadsheet_link
    @links = links
    mail_from = ENV['MAILER_FROM'] || 'kikecomp@gmail.com'
    mail(from: "Nucleo Social <#{mail_from}>", to: ENV['ADMIN_MAIL'], subject: "Para postar: Links bons para comentar")
  end
end
