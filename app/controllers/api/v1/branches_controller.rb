class Api::V1::BranchesController < ApplicationController
  def show
    @branch = find_or_create_branch(params[:id])
    if @branch.present?
      render json: @branch.metadata
    else
      render json: "No bueno", response_code: 404
    end
  end

  def index
    response = HTTParty.get("http://www.ratekhoj.com/bank-branches/results.php?searchstring=#{params[:q]}")
    ifsc_results = response.scan(/IFSC\s*Code:\s*([a-zA-Z0-9]*)/).map! {|r| r[0]}
    ifsc_results.each do |ifsc|
      find_or_create_branch(ifsc)
    end

    @branches = Branch.where('ifsc IN (?)', ifsc_results)
    if @branches.present?
      render json: @branches.map {|branch| branch.metadata}
    else
      render json: "No bueno", response_code: 404
    end
  end

  private
  def find_or_create_branch(ifsc)
    @branch = Branch.where(:ifsc => ifsc).first_or_create do |branch|
      response = HTTParty.get("https://ifsc.razorpay.com/#{ifsc}")
      return false if response.response.is_a?(Net::HTTPNotFound)
      branch.metadata = response.parsed_response
    end
  end
end