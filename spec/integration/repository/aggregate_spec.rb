RSpec.describe ROM::Repository::Root, '#aggregate' do
  subject(:repo) do
    Class.new(ROM::Repository[:users]) do
      relations :tasks, :posts, :labels
    end.new(rom)
  end

  include_context 'database'
  include_context 'relations'
  include_context 'seeds'

  it 'exposes nodes via `node` method' do
    jane = repo.
             aggregate(:posts).
             node(:posts) { |posts| posts.where(title: 'Another one') }.
             where(name: 'Jane').one

    expect(jane.name).to eql('Jane')
    expect(jane.posts).to be_empty

    repo.posts.insert author_id: 1, title: 'Another one'

    jane = repo.
             aggregate(:posts).
             node(:posts) { |posts| posts.where(title: 'Another one') }.
             where(name: 'Jane').one

    expect(jane.name).to eql('Jane')
    expect(jane.posts.size).to be(1)
    expect(jane.posts[0].title).to eql('Another one')
  end

  it 'exposes nested nodes via `node` method' do
    jane = repo.
             aggregate(posts: :labels).
             node(posts: :labels) { |labels| labels.where(name: 'red') }.
             where(name: 'Jane').one

    expect(jane.name).to eql('Jane')
    expect(jane.posts.size).to be(1)
    expect(jane.posts[0].labels.size).to be(1)
    expect(jane.posts[0].labels[0].name).to eql('red')
  end
end
