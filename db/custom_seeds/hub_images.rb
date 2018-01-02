hubs = File.open("./db/dummydata/hub_images.xlsx")
req = {"xlsx" => hubs}
load_hub_images(req)