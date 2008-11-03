class CommentsController < ApplicationController
  def create
    redirect_to home_url and return false if !facebook_user.self_or_in_friends?(Picture.find(params[:comment][:picture_id]).fb_user_id)
    @comment = Comment.new params[:comment]
    @comment.fb_user_id = facebook_user.id
    if @comment.save
      begin
        PicadayPublisher.deliver_publish_comment(facebook_user, @comment)
      rescue Exception => exception
        ExceptionNotifier.deliver_exception_notification(exception, self, request)
      end
      redirect_to picture_path(@comment.picture)
    else
      redirect_to picture_path(@comment.picture)
    end
  end
  
end