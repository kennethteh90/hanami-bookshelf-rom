module Web
  module Views
    module Books
      class Index
        include Web::View
      end

      class JsonIndex < Index
        format :json

        def render
          raw(books.map(&:to_h).to_json)
        end
      end
    end
  end
end
