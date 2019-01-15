describe Jets::Resource::ApiGateway::RestApi do
  let(:routes) do
    Jets::Resource::ApiGateway::RestApi::Routes.new
  end
  let(:deployed_routes) { Jets::Router.routes }

  context 'no changes detected' do
    it 'changed' do
      # Use new routes as the "deployed" routes that thats one way to mimic that
      # no routes have been changed
      allow(routes).to receive(:build).and_return(deployed_routes)
      expect(routes.changed?).to be(false)
    end
  end
end
