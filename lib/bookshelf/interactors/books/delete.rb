require 'hanami/interactor'

module Books
  class Delete
    include Hanami::Interactor

    def initialize(book_repo: Bookshelf::Repositories::BookRepository.new)
      @book_repo = book_repo
    end

    def call(book_id)
      error('Book not found') unless book_repo.delete(book_id) > 0
    end

    private

      attr_reader :book_repo

  end
end
