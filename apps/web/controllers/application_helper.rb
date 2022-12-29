module Web
  module Controllers
    module ApplicationHelper
      def ensure_json_response
        self.format = :json
      end
    end
  end
end
