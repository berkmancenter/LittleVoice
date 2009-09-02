require 'test_helper'

class ScoresControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:scores)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_score
    assert_difference('Score.count') do
      post :create, :score => { }
    end

    assert_redirected_to score_path(assigns(:score))
  end

  def test_should_show_score
    get :show, :id => scores(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => scores(:one).id
    assert_response :success
  end

  def test_should_update_score
    put :update, :id => scores(:one).id, :score => { }
    assert_redirected_to score_path(assigns(:score))
  end

  def test_should_destroy_score
    assert_difference('Score.count', -1) do
      delete :destroy, :id => scores(:one).id
    end

    assert_redirected_to scores_path
  end
end
