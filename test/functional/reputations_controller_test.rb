require 'test_helper'

class ReputationsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:reputations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_reputation
    assert_difference('Reputation.count') do
      post :create, :reputation => { }
    end

    assert_redirected_to reputation_path(assigns(:reputation))
  end

  def test_should_show_reputation
    get :show, :id => reputations(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => reputations(:one).id
    assert_response :success
  end

  def test_should_update_reputation
    put :update, :id => reputations(:one).id, :reputation => { }
    assert_redirected_to reputation_path(assigns(:reputation))
  end

  def test_should_destroy_reputation
    assert_difference('Reputation.count', -1) do
      delete :destroy, :id => reputations(:one).id
    end

    assert_redirected_to reputations_path
  end
end
