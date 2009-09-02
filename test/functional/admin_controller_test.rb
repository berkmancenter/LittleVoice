require File.dirname(__FILE__) + '/../test_helper'

class AdministrationsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:administrations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_administration
    assert_difference('Administration.count') do
      post :create, :administration => { }
    end

    assert_redirected_to administration_path(assigns(:administration))
  end

  def test_should_show_administration
    get :show, :id => administrations(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => administrations(:one).id
    assert_response :success
  end

  def test_should_update_administration
    put :update, :id => administrations(:one).id, :administration => { }
    assert_redirected_to administration_path(assigns(:administration))
  end

  def test_should_destroy_administration
    assert_difference('Administration.count', -1) do
      delete :destroy, :id => administrations(:one).id
    end

    assert_redirected_to administrations_path
  end
end
