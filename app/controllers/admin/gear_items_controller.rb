class Admin::GearItemsController < Admin::BaseController
  before_action :set_item, only: [ :edit, :update, :destroy ]

  def index
    @status = params[:status].presence_in(GearItem::STATUSES.keys)
    items = GearItem.ordered
    items = items.where(status: @status) if @status
    @groups = GearItem.by_category(items)
  end

  def new
    @item = GearItem.new(category: params[:category].presence_in(GearItem::CATEGORIES) || "Snowboards")
  end

  def create
    @item = GearItem.new(item_params)
    if @item.save
      redirect_to params[:another] ? new_admin_gear_item_path(category: @item.category) : admin_gear_items_path, notice: "Added #{@item.name}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to admin_gear_items_path, notice: "Saved #{@item.name}."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    redirect_to admin_gear_items_path, notice: "Removed #{@item.name}."
  end

  private

  def set_item
    @item = GearItem.find(params[:id])
  end

  def item_params
    params.expect(gear_item: [ :category, :brand, :model, :season, :size, :status, :notes, :public_note, :public ])
  end
end
