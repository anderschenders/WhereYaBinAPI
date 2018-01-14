class UserBinsController < ApplicationController

  def community_data
    user_bins = UserBin.all

    # all user_bins with action == "use"
    use_user_bins = user_bins.select { |user_bin| user_bin.action == "use" }
    use_user_bins_count = use_user_bins.length

    # count for all Users registered
    all_users = User.all.count

    # distance travelled by each user
    dist_travelled_all_users_array = []

    user_bins.each do |user_bin|
      dist_trav_user_hash = []
      user = User.find_by(id: user_bin.user_id)
      dist = user.total_distance_travelled
      dist_travelled_all_users_array << [user.id, dist]
    end

    # user who travelled the most
    most_travelled = dist_travelled_all_users_array[0]

    dist_travelled_all_users_array.each do |arr|
      if arr[1] > most_travelled[1]
        most_travelled = arr
      end
    end

    top_dist = most_travelled[1].round(2)
    top_dist_user_id = most_travelled[0]

    top_dist_user = User.find_by(id: top_dist_user_id)
    top_dist_username = top_dist_user.username

    # distance travelled by all users
    total_dist_travelled = 0
    dist_travelled_all_users_array.each do |arr|
      total_dist_travelled += arr[1]
    end

    # user with most activity
    user_activity_hash = {}

    user_bins.each do |user_bin|
      if user_activity_hash[user_bin.user_id]
        user_activity_hash[user_bin.user_id] += 1
      else
        user_activity_hash[user_bin.user_id] = 1
      end
    end

    top_user_activity_arr = user_activity_hash.max_by {|k, v| v}
    top_user_activity = top_user_activity_arr[1]
    top_user_activity_user_id = top_user_activity_arr[0]
    top_user_activity_user = User.find_by(id: top_user_activity_user_id)
    top_user_activity_username = top_user_activity_user.username

    json_response = {
      user_count: all_users,
      action_use_count: use_user_bins_count,
      total_dist_travelled: total_dist_travelled.round(2),
      top_dist: top_dist,
      top_dist_username: top_dist_username,
      top_user_activity: top_user_activity,
      top_user_activity_username: top_user_activity_username
    }

    render status: :ok, json: json_response
  end

  # def index

    # user_bins_array = get_user_bins(@user)
  #
  #   user_bins = UserBin.where(user_id: params[:user_id])
  #   user_bins_sorted = user_bins.order(:created_at).reverse
  #
  #   user_bins_array = user_bins_sorted.each_slice(1).to_a
  #
  #   user_bins_array.each do |user_bin|
  #     bin = Bin.find_by(id: user_bin[0].bin_id)
  #     if bin.bin_type === "RYPUBL"
  #       user_bin << { "bin_type" => "RECYCLING" }
  #     else
  #       user_bin << { "bin_type" => "GARBAGE" }
  #     end
  #   end
  #
  #   render status: :ok, json: user_bins_array
  # end

  def create

    @user = User.find_by(id: params[:user_id])
    @user.bin_count += 1
    @user.save

    bin = Bin.find_by(id: params[:bin_id])
    bin_latitude = bin.latitude
    bin_longitude = bin.longitude
    # add count to bin? First gotta make a column

    # error handling if can't find user or bin

    new_user_bin = UserBin.new(
      user_id: params[:user_id],
      bin_id: params[:bin_id],
      action: params[:user_action],
      user_lat: params[:user_lat],
      user_lng: params[:user_lng]
    )

    if new_user_bin.save
      # get total distance user has travelled
      @user.reload
      total_distance_travelled = @user.total_distance_travelled

      #get all user_bins
      user_bins_array = get_user_bins(@user)

      json_response = {
        new_user_bin: new_user_bin,
        updated_user: @user,
        total_dist: total_distance_travelled,
        bin_location: "#{bin_latitude},#{bin_longitude}",
        user_bins: user_bins_array
      }

      render status: :ok, json: json_response
    else
      render status: :bad_request, json: { errors: user_bin.errors }
    end

  end

  private

  def get_user_bins(user)
    user_bins = UserBin.where(user_id: @user.id)
    user_bins_sorted = user_bins.order(:created_at).reverse

    user_bins_array = user_bins_sorted.each_slice(1).to_a

    user_bins_array.each do |user_bin|
      bin = Bin.find_by(id: user_bin[0].bin_id)
      if bin.bin_type === "RYPUBL"
        user_bin << { "bin_type" => "RECYCLING" }
      else
        user_bin << { "bin_type" => "GARBAGE" }
      end
    end

    return user_bins_array
  end

end
