require 'test_helper'

class ItememailsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:itememails)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_itememail
    assert_difference('Itememail.count') do
      post :create, :itememail => { }
    end

    assert_redirected_to itememail_path(assigns(:itememail))
  end

  def test_should_show_itememail
    get :show, :id => itememails(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => itememails(:one).id
    assert_response :success
  end

  def test_should_update_itememail
    put :update, :id => itememails(:one).id, :itememail => { }
    assert_redirected_to itememail_path(assigns(:itememail))
  end

  def test_should_destroy_itememail
    assert_difference('Itememail.count', -1) do
      delete :destroy, :id => itememails(:one).id
    end

    assert_redirected_to itememails_path
  end
end
