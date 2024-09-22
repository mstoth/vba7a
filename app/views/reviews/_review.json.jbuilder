json.extract! review, :id, :title, :stars, :comment, :concert_id, :venue_id, :created_at, :updated_at
json.url review_url(review, format: :json)
