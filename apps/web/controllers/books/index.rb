module Web
  module Controllers
    module Books
      class Index
        include Web::Action

        expose :books

        def call(_params)
          @books = Bookshelf::Repositories[:Book].all
        end
      end
    end
  end
end
