class UsersController < ApplicationController

  def index
    @user = User.find_by(email: params[:email], password: params[:password])
    if @user
      # get total distance user has travelled
      total_distance_travelled = @user.total_distance_travelled

      #get all user_bins
      user_bins_formatted = get_user_bins(@user)

      # user total
      user_bins_use = user_bins_formatted.select { |user_bin| user_bin["action"] == "use" }

      user_bins_use_total = user_bins_use.count

      # recycling total
      user_bins_rec = user_bins_use.select { |user_bin|
        user_bin["bin_type"] == "RYPUBL" }

      user_bins_total_rec = user_bins_rec.count

      # garbage total
      user_bins_gar = user_bins_use.select { |user_bin|
        user_bin["bin_type"] == "GPUBL" }

      user_bins_total_gar = user_bins_gar.count

      # report total
      user_bins_reports = user_bins_formatted.select { |user_bin| user_bin["action"] == "full" || user_bin["action"] == "missing" || user_bin["action"] == "add" }

      user_bins_total_reports = user_bins_reports.count

      # full total
      user_bins_full = user_bins_reports.select { |user_bin| user_bin["action"] == "full"}

      user_bins_full_reports = user_bins_full.count

      # missing total
      user_bins_missing = user_bins_reports.select { |user_bin| user_bin["action"] == "missing" }

      user_bins_missing_reports = user_bins_missing.count

      # add total
      user_bins_add = user_bins_reports.select { |user_bin| user_bin["action"] == "add" }

      user_bins_add_reports = user_bins_add.count

      json_response = {
        user: @user,
        total_dist: total_distance_travelled,
        user_bins: user_bins_formatted,
        use_total: user_bins_use_total,
        total_rec: user_bins_total_rec,
        total_gar: user_bins_total_gar,
        total_reports: user_bins_total_reports,
        full_reports: user_bins_full_reports,
        missing_reports: user_bins_missing_reports,
        add_reports: user_bins_add_reports
      }

      render status: :ok, json: json_response
    else
      user = User.find_by(email: params[:email])
      if user.nil?
        render status: :bad_request, json: { error: 'Invalid email. Please try again.' }
      else
        render status: :bad_request, json: { error: 'Invalid password. Please try again.' }
      end
    end

  end

  def create
    # new user sign up
    @user = User.new({
      email: params[:email],
      username: params[:username],
      password: params[:password]
    })

    if @user.save
      # get total distance user has travelled
      total_distance_travelled = @user.total_distance_travelled

      #get all user_bins
      user_bins_array = get_user_bins(@user)

      json_response = {
        user: @user,
        total_dist: total_distance_travelled,
        user_bins: user_bins_array
      }

      render status: :ok, json: json_response
    else
      render status: :bad_request, json: { errors: @user.errors }
    end

  end
end

private

def get_user_bins(user)
  user_bins = UserBin.where(user_id: user.id)
  user_bins_sorted = user_bins.order(:created_at).reverse


  user_bins_formatted = []
  user_bins_sorted.each do |user_bin|
    bin = Bin.find_by(id: user_bin.bin_id)
    user_bin_attributes = user_bin.attributes
    user_bin_attributes["bin_type"] = bin.bin_type
    user_bins_formatted << user_bin_attributes
  end

  return user_bins_formatted
end

# def get_user_bins(user)
#
#   user_bins = UserBin.where(user_id: @user.id)
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
#   return user_bins_array
# end
