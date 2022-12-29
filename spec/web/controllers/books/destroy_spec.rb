RSpec.describe Web::Controllers::Books::Destroy, type: :action do
  let(:action) { described_class.new }

  let(:repository) do
    Bookshelf::Repositories[:Book]
  end

  let!(:book) do
    repository.create(title: 'Confident Ruby', author: 'Avdi Grimm')
  end

  after do
    repository.clear
  end

  context 'with valid id' do
    context 'when requesting json' do
      it 'deletes the book and returns 204' do
        status, headers, body = action.call(id: book.id, 'Accept' => 'application/json')

        expect(status).to eq(204)
        expect(headers).to eq({})
        expect(body).to eq([])
      end
    end

    context 'when requesting html' do
      it 'deletes the book and redirects to books index' do
        status, headers, _ = action.call(id: book.id, 'Accept' => 'application/html')

        expect(status).to eq(302)
        expect(headers['Location']).to eq('/books')
      end
    end
  end

  context 'with invalid id' do
    it 'returns 422' do
      response = action.call(id: 'oops')

      expect(response[0]).to eq(422)
    end
  end
end
