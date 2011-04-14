module Linkshare
  class Base
    include HTTParty
    format :xml 
    
    @@credentials = {}
    @@default_params = {}
    
    def initialize(params)
      raise ArgumentError, "Init with a Hash; got #{params.class} instead" unless params.is_a?(Hash)

      params.each do |key, val|
        instance_variable_set("@#{key}".intern, val)
        instance_eval " class << self ; attr_reader #{key.intern.inspect} ; end "
      end
    end
    
    def user_id=(id)
      @@credentials['user_id'] = id.to_s
    end
    
    def pass=(pass)
      @@credentials['pass'] = pass.to_s
    end
    
    
    class << self
      def base_url
        "http://cli.linksynergy.com/"
      end
      
      def validate_params!(provided_params, available_params, default_params = {})
        params = default_params.merge(provided_params)
        invalid_params = params.select{|k,v| !available_params.include?(k.to_s)}.map{|k,v| k}
        raise ArgumentError.new("Invalid parameters: #{invalid_params.join(', ')}") if invalid_params.length > 0
      end
      
      def get_service(path, query)
        query.keys.each{|k| query[k.to_s] = query.delete(k)}
        query.merge!({'cuserid' => credentials['user_id'], 'cpi' => credentials['pass']})

        results = []
        total = 0

        begin
          begin
            response = get(path, :query => query, :timeout => 30)
          rescue Timeout::Error
            nil
          end
debugger
          cj_api = response['cj_api']
          validate_response(cj_api)

          #little bit of navigation here
          total = cj_api.values.first.delete('total_matched').to_i
          
          # cj_api is a hash containing a hash or return data, one element being the actual records we have
          data = cj_api.values.first.reject{|k,v| %w{records_returned page_number}.include?(k)}.values.first
          data = [data] unless data.nil? || data.is_a?(Array)
          results = results.concat(data || [])

        end while total > results.length

        results.map{|r| self.new(r)}
      end # get
      
      def credentials
        unless @@credentials && @@credentials.length > 0
          # there is no offline or test mode for CJ - so I won't include any credentials in this gem
          config_file = ["config/linkshare.yml", File.join(ENV['HOME'], '.linkshare.yaml')].select{|f| File.exist?(f)}.first

          unless File.exist?(config_file)
            warn "Warning: config/linkshare.yaml does not exist. Put your CJ developer key and website ID in ~/.linkshare.yml to enable live testing."
          else
            @@credentials = YAML.load(File.read(config_file))
          end
        end
        @@credentials
      end # credentails
      
      def validate_response(response)
        error_message = response['error_message']
        raise ArgumentError, error_message if error_message
      end
      
      def first(params)
        find(params).first
      end
    
    end # self
  end # Base
end # Linkshare