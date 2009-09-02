require 'test_helper'

class ScoretypesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:scoretypes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_scoretype
    assert_difference('Scoretype.count') do
      post :create, :scoretype => { }
    end

    assert_redirected_to scoretype_path(assigns(:scoretype))
  end

  def test_should_show_scoretype
    get :show, :id => scoretypes(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => scoretypes(:one).id
    assert_response :success
  end

  def test_should_update_scoretype
    put :update, :id => scoretypes(:one).id, :scoretype => { }
    assert_redirected_to scoretype_path(assigns(:scoretype))
  end

  def test_should_destroy_scoretype
    assert_difference('Scoretype.count', -1) do
      delete :destroy, :id => scoretypes(:one).id
    end

    assert_redirected_to scoretypes_path
  end
end
