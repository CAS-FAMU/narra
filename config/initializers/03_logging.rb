# Mongoid logging setup
Mongoid.logger.level = Logger::INFO
Mongo::Logger.logger.level = Logger::INFO

if Rails.env.development?
  # Narra logging setup
  Narra::Tools::Logger.default_logger.level = Logger::DEBUG
else
  # Narra logging setup
  Narra::Tools::Logger.default_logger.level = Logger::ERROR
end