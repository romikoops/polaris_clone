# frozen_string_literal: true

client = get_client

## Load Import and Export AES (HTS - 10 digit codes)

file = "#{Rails.root}/db/dummydata/impaes.txt"
f = File.open(file, 'r')
f.each_line do |line|
  line_arr = line.split('     ')
  id = line_arr[0]
  parent = line_arr[0][0..5]
  update = { text: line_arr[1], code: line_arr[0], parentCode: parent, direction: 'import' }
  update_item_fn(client, 'hsCodes', { _id: id }, update)
end
f.close

file = "#{Rails.root}/db/dummydata/expaes.txt"
f = File.open(file, 'r')
f.each_line do |line|
  line_arr = line.split('     ')
  id = line_arr[0]
  parent = line_arr[0][0..5]
  update = { text: line_arr[1], code: line_arr[0], parentCode: parent, direction: 'export' }
  update_item_fn(client, 'hsCodes', { _id: id }, update)
end
f.close

## Load HS Codes (6 digit parent codes)

hs4 = JSON.parse(File.read("#{Rails.root}/db/dummydata/classificationH4.json"))['results']

hs4.each do |hs|
  update_item_fn(client, 'hsCodes', { parentCode: hs['id'] }, parent: hs) if hs['id'].length >= 6
end

client['hsCodes'].indexes.create_one('$**' => 'text')
# client["hsCodes"].indexes.drop_all
# client["hsCodes"].indexes.create_many([
#   {:key => {:text => "text"}},
#   {:key => {:code => "text"}},
#   {:key => {"parent.text" => "text"}}
#   ])
# client["hsCodes"].indexes.create_one({:text => "text"})
# client["hsCodes"].indexes.create_one({:code => "text"})
# client["hsCodes"].indexes.create_one({"parent.text" => "text"})
