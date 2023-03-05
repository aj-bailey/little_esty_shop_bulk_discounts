require './app/services/nager_service'

class NagerFacade
  def holidays
    service.holidays[0..2].map do |holiday| 
      Holiday.new(holiday)
    end
  end

  def service
    NagerService.new
  end
end