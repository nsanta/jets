class Jets::Application
  module DefaultConfig
    def default_config
      config = ActiveSupport::OrderedOptions.new
      config.project_name = parse_project_name # must set early because other configs requires this
      config.cors = false
      config.autoload_paths = default_autoload_paths
      config.extra_autoload_paths = []
      config.logger = Jets::Logger.new($stderr)

      # function properties defaults
      config.function = ActiveSupport::OrderedOptions.new
      config.function.timeout = 30
      # default memory setting based on:
      # https://medium.com/epsagon/how-to-make-lambda-faster-memory-performance-benchmark-be6ebc41f0fc
      config.function.memory_size = 1536

      config.prewarm = ActiveSupport::OrderedOptions.new
      config.prewarm.enable = true
      config.prewarm.rate = '30 minutes'
      config.prewarm.concurrency = 2
      config.prewarm.public_ratio = 3
      config.prewarm.rack_ratio = 5

      config.gems = ActiveSupport::OrderedOptions.new
      config.gems.sources = [
        Jets.default_gems_source
      ]

      config.inflections = ActiveSupport::OrderedOptions.new
      config.inflections.irregular = {}

      config.assets = ActiveSupport::OrderedOptions.new
      config.assets.folders = %w[assets images packs]
      config.assets.base_url = nil # IE: https://cloudfront.com/my/base/path
      config.assets.max_age = 3600
      config.assets.cache_control = nil # IE: public, max-age=3600 , max_age is a shorter way to set cache_control.

      config.ruby = ActiveSupport::OrderedOptions.new

      config.middleware = Jets::Middleware::Configurator.new

      config.session = ActiveSupport::OrderedOptions.new
      config.session.store = Rack::Session::Cookie # note when accessing it use session[:store] since .store is an OrderedOptions method
      config.session.options = {}

      config.api = ActiveSupport::OrderedOptions.new
      config.api.authorization_type = "NONE"
      config.api.cors_authorization_type = nil # nil so ApiGateway::Cors#cors_authorization_type handles
      config.api.binary_media_types = ['multipart/form-data']
      config.api.endpoint_type = 'EDGE' # PRIVATE, EDGE, REGIONAL

      config.domain = ActiveSupport::OrderedOptions.new
      # config.domain.name = "#{Jets.project_namespace}.coolapp.com" # Default is nil
      # config.domain.cert_arn = "..."
      config.domain.endpoint_type = "REGIONAL" # EDGE or REGIONAL. Default to EDGE because CloudFormation update is faster
      config.domain.route53 = true # controls whether or not to create the managed route53 record.
        # Useful to disable this when user wants to manage the route themself like pointing
        # it to CloudFront for blue-green deployments instead.

      # Custom user lambda layers
      config.lambda = ActiveSupport::OrderedOptions.new
      config.lambda.layers = []

      # Only used for Jets Afterburner, Mega Mode currently. This is a fallback default
      # encoding.  Usually, the Rails response will return a content-type header and
      # the encoding in there is used when possible. Example Content-Type header:
      #   Content-Type    text/html; charset=utf-8
      config.encoding = ActiveSupport::OrderedOptions.new
      config.encoding.default = "utf-8"

      config.s3_event = ActiveSupport::OrderedOptions.new
      # These notification_configuration properties correspond to the ruby aws-sdk
      #   s3.put_bucket_notification_configuration
      # in jets/s3_bucket_config.rb, not the CloudFormation Bucket properties. The CloudFormation
      # bucket properties have a similiar structure but is slightly different so it can be confusing.
      #
      #   Ruby aws-sdk S3 Docs: https://amzn.to/2N7m5Lr
      config.s3_event.configure_bucket = true
      config.s3_event.notification_configuration = {
        topic_configurations: [
          {
            events: ["s3:ObjectCreated:*"],
            topic_arn: "!Ref SnsTopic", # must use this logical id
          },
        ],
      }

      # So tried to defined this in the jets/mailer.rb Turbine only but jets new requires it
      # config.action_mailer = ActiveSupport::OrderedOptions.new

      config
    end
  end
end
