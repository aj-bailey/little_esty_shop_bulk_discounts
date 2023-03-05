def stub_holidays_request
  holidays_json_response = File.open("./fixtures/holidays.json")

  stub_request(:get, "https://date.nager.at/api/v3/NextPublicHolidays/US").
    to_return(status: 200, body: holidays_json_response)
end