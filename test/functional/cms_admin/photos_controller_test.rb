require 'test_helper'

class CmsAdmin::PhotosControllerTest < ActionController::TestCase
  
  def test_index
    get :index, :gallery_id => galleries(:default)
    assert_response :success
    assert_template 'index'
  end

  def test_new
    get :new, :gallery_id => galleries(:default)
    assert_response :success
    assert_template 'new'
  end

  def test_create
    photo = photos(:default)
    assert_difference 'Photo.count', 1 do
      xhr :post, :create, :gallery_id => photo.gallery, :id => photo, :photo => {
          :image        => fixture_file_upload('images/test_image.jpg', 'image/jpeg')
      }
      assert_response :success
            # 
            # post :create, :gallery_id => photo.gallery, :id => photo, :photo => {
            #     :image        => fixture_file_upload('images/test_image.jpg', 'image/jpeg')
            # }
            # assert_response :success
      photo = Photo.order('id DESC').first
      assert photo.image?
      
      assert assigns(:photo)
      # assert_equal 'New Description', photo.description
    end

    # assert_difference 'Photo.count' do
    #   post :create, :gallery_id => galleries(:default), :photo => {
    #     :image        => fixture_file_upload('images/test_image.jpg', 'image/jpeg'),
    #     :description  => 'New Description'
    #   }
    # end
  end

  def test_create_fail
    assert_no_difference 'Photo.count' do
      xhr :post, :create, :gallery_id => galleries(:default), :photo => { }
      assert_response :bad_request
    end
  end
  
  def test_get_edit
    photo = photos(:default)
    get :edit, :gallery_id => photo.gallery, :id => photo
    assert_response :success
    assert_template 'edit'
    assert_select "form[action='/cms-admin/galleries/#{photo.gallery.id}/photos/#{photo.id}']"
  end
  
  def test_get_edit_not_found
    get :edit, :gallery_id => galleries(:default), :id => 'not_found'
    assert_response 404
  end
  
  def test_update
    photo = photos(:default)
    put :update, :gallery_id => photo.gallery, :id => photo, :photo => {
      :image        => fixture_file_upload('images/test_image.jpg', 'image/jpeg'),
      :description  => 'Updated Description'
    }
    assert_response :redirect
    assert_redirected_to cms_admin_gallery_photos_path(galleries(:default))
    assert_equal 'Photo was successfully updated.', flash[:notice]
    
    photo.reload
    assert_equal 'Updated Description', photo.description
  end
  
  def test_update_failure
    photo = photos(:default)
    put :update, :gallery_id => photo.gallery, :id => photo, :photo => {
      :image        => '',
      :description  => 'Updated Description'
    }
    assert_response :success
    assert_template :edit
    
    photo.reload
    assert_not_equal 'Updated Description', photo.description
  end
  
  def test_destroy
    photo = photos(:default)
    assert_difference 'Photo.count', -1 do
      xhr :delete, :destroy, :gallery_id => photo.gallery, :id => photo
      assert_response :success
    end
  end

end