ActionMailer::Base.smtp_settings = {
  :address              => ENV['MAILER_SERVER'],
  :port                 => 587,
  :user_name            => ENV['MAILER_USER'],
  :password             => ENV['MAILER_PASS'],
  :authentication       => :login,
  :enable_starttls_auto => true
}
