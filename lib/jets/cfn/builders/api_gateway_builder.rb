module Jets::Cfn::Builders
  class ApiGatewayBuilder
    include Interface
    include Jets::AwsServices

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      return unless @options[:templates] || @options[:stack_type] != :minimal

      add_gateway_rest_api
      add_custom_domain
      add_gateway_routes
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.api_gateway_template_path
    end

    # do not bother writing a template if routes are empty
    def write
      super unless Jets::Router.routes.empty?
    end

    # If the are routes in config/routes.rb add Gateway API in parent stack
    def add_gateway_rest_api
      rest_api = Jets::Resource::ApiGateway::RestApi.new
      add_resource(rest_api)
      add_outputs(rest_api.outputs)

      deployment = Jets::Resource::ApiGateway::Deployment.new
      outputs = deployment.outputs(true)
      add_output("RestApiUrl", Value: outputs["RestApiUrl"])
    end

    def add_custom_domain
      return unless Jets.custom_domain?
      add_domain_name
      add_route53_dns if Jets.config.domain.route53
    end

    def add_domain_name
      domain_name = Jets::Resource::ApiGateway::DomainName.new
      add_resource(domain_name)
      add_outputs(domain_name.outputs)
    end

    def add_route53_dns
      dns = Jets::Resource::Route53::RecordSet.new
      add_resource(dns)
      add_outputs(dns.outputs)
    end

    # Adds route related Resources and Outputs
    def add_gateway_routes
      # The routes required a Gateway Resource to contain them.
      # TODO: Support more routes. Right now outputing all routes in 1 template will hit the 60 routes limit.
      # Will have to either output them as a joined string or break this up to multiple templates.
      # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cloudformation-limits.html
      # Outputs: Maximum number of outputs that you can declare in your AWS CloudFormation template. 60 outputs
      # Output name: Maximum size of an output name. 255 characters.
      #
      # Note we must use .all_paths, not .routes here because we need to
      # build the parent ApiGateway::Resource nodes also
      Jets::Router.all_paths.each do |path|
        homepage = path == ''
        next if homepage # handled by RootResourceId output already

        resource = Jets::Resource::ApiGateway::Resource.new(path, internal: true)
        add_resource(resource)
        add_outputs(resource.outputs)
      end
    end
  end
end
