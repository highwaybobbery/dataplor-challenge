require 'rails_helper'

describe MainController, type: :controller do
  describe 'GET common_ancestor' do
    context 'with a non-existent id' do
      it 'responds with a null ancestor' do
        get :common_ancestor,  params: { a: '123', b: '345' }

        expect(response.body).to eq({ root_id: nil, lowest_common_ancestor: nil, depth: nil }.to_json)
      end
    end

    context 'with nodes that have common ancestry' do
      let!(:node_a) { create(:node, id: 123, parent_id: nil) }
      let!(:node_b) { create(:node, id: 345, parent_id: 123) }

      it 'responds with the common ancestry' do
        get :common_ancestor, params: { a: '123', b: '345' }

        expect(response.body).to eq({ root_id: 123, lowest_common_ancestor: 123, depth: 1 }.to_json)
      end
    end
  end

  describe 'GET birds' do
    context 'with a non-existent node_id' do
      it 'returns an empty array' do
        get :birds,  params: { node_ids: '123,345' }

        expect(response.body).to eq([].to_json)
      end
    end

    context 'with nodes that have birds' do
      let!(:node_a) { create(:node, id: 123, parent_id: nil) }
      let!(:node_b) { create(:node, id: 456, parent_id: 123) }
      let!(:node_c) { create(:node, id: 789, parent_id: nil) }
      let!(:node_d) { create(:node, id: 555, parent_id: nil) }

      let!(:bird_a) { create(:bird, id: 1, name: 'joe', node_id: 456) }
      let!(:bird_b) { create(:bird, id: 2, name: 'jane', node_id: 456) }
      let!(:bird_c) { create(:bird, id: 3, name: 'jimmy', node_id: 789) }
      let!(:bird_d) { create(:bird, id: 4, name: 'noop', node_id: 555) }

      it 'returns the birds of all descendants' do
        get :birds, params: { node_ids: '123,789' }

        expect(response.body).to eq([
          { id: 1, node_id: 456, name: 'joe' },
          { id: 2, node_id: 456, name: 'jane' },
          { id: 3, node_id: 789, name: 'jimmy' }
        ].to_json)
      end
    end
  end
end
