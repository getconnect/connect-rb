module ConnectClient
  class Configuration
  attr_accessor :base_url, :api_key, :project_id, :async

  def initialize(api_key = '', project_id = '', async = false, base_url = 'https://api.getconnect.io')
    @base_url = base_url
    @api_key = api_key
    @project_id = project_id
    @async = async
  end
  end
end