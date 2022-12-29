module Web
  module Controllers
    module Books
      class Destroy
        include Web::Action

        before :ensure_json_response

        params do
          required(:id).filled(:int?)
        end

        def initialize(interactor: ::Books::Delete.new)
          @interactor = interactor
        end

        def call(params)
          halt 422 unless params.valid?

          result = interactor.call(params[:id])
          halt 404 unless result.success?

          if params.env['Accept'] == 'application/json'
            status 204, nil
          else
            redirect_to(routes.books_path)
          end
        end

        private

          attr_reader :interactor

      end
    end
  end
end
