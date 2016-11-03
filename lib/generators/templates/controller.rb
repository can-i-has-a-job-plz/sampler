class SamplesController < ApplicationController
  def index
    @samples = klass
    if params.key?(:endpoint)
      @endpoint = params[:endpoint]
      @samples = @samples.where(endpoint: params[:endpoint]).order(:id)
      if params.key?(:tags)
        @tags = params[:tags].split(',').map(&:strip)
        @samples = @samples.where('tags && ARRAY[?]::varchar[]', @tags)
        @tags = @tags.join(', ')
      end
    else
      @samples = @samples.group(:endpoint).count
      render :grouped_index
    end
  end

  def show
    @sample = klass.find(params[:id])
  end

  def destroy
    klass.find_by(id: params[:id])&.destroy
    flash[:success] = "Sample #{params[:id]} most likely deleted"
    redirect_to action: :index
  end

  def update
    for_delete = params[:samples].select { |_k, v| v[:id] == '1' }.keys
    klass.where(id: for_delete).delete_all
    flash[:success] = "Sample #{params[:id]} most likely mass deleted"
    redirect_to action: :index
  end

  private

  def klass
    Sampler.configuration.probe_class
  end
end
