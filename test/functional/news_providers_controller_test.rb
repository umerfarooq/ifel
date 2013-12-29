require 'test_helper'

class NewsProvidersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:news_providers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create news_provider" do
    assert_difference('NewsProvider.count') do
      post :create, :news_provider => { }
    end

    assert_redirected_to news_provider_path(assigns(:news_provider))
  end

  test "should show news_provider" do
    get :show, :id => news_providers(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => news_providers(:one).to_param
    assert_response :success
  end

  test "should update news_provider" do
    put :update, :id => news_providers(:one).to_param, :news_provider => { }
    assert_redirected_to news_provider_path(assigns(:news_provider))
  end

  test "should destroy news_provider" do
    assert_difference('NewsProvider.count', -1) do
      delete :destroy, :id => news_providers(:one).to_param
    end

    assert_redirected_to news_providers_path
  end
end
