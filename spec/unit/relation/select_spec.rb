RSpec.describe ROM::Relation, '#select' do
  subject(:relation) { container.relations.tasks }

  include_context 'users and tasks'

  before do
    conf.relation(:tasks) { schema(infer: true) }
  end

  with_adapters do
    it 'projects a relation using a list of symbols' do
      expect(relation.select(:id, :title).to_a)
        .to eql([{ id: 1, title: "Joe's task" }, { id: 2, title: "Jane's task"}])
    end

    it 'projects a relation using a schema' do
      expect(relation.select(*relation.schema.project(:id, :title)).to_a)
        .to eql([{ id: 1, title: "Joe's task" }, { id: 2, title: "Jane's task"}])
    end

    it 'maintains schema' do
      expect(relation.select(:id, :title).schema.map(&:name)).to eql(%i[id title])
    end

    it 'supports args and blocks' do
      expect(relation.select(:id) { [title] }.schema.map(&:name)).to eql(%i[id title])
    end

    it 'supports blocks' do
      expect(relation.select { [id, title] }.schema.map(&:name)).to eql(%i[id title])
    end

    it 'supports blocks with custom expressions' do
      selected = relation
                   .select { [int::count(id).as(:id_count), title.prefixed(:task)] }
                   .group { [id, title] }

      expect(selected.first).to eql(id_count: 1, task_title: "Joe's task")
    end
  end
end
