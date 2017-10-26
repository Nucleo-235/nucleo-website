ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
  :access_key_id     => Rails.application.secrets.aws_mailer_access_key_id,
  :secret_access_key => Rails.application.secrets.aws_mailer_secret_access_key,
  :server => ENV['MAILER_SERVER']
