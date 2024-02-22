class MainController < ApplicationController
  def common_ancestor
    render json: Node.common_ancestor(common_ancestor_params['a'], common_ancestor_params['b'])
  end

  def birds
    render json: Bird.for_all_descendants_of(birds_params['node_ids'].split(','))
  end

  private

  def common_ancestor_params
    params.permit(:a, :b)
  end

  def birds_params
    params.permit(:node_ids)
  end
end
