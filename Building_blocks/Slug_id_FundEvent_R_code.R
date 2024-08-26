################################################################
################################################################
###############
############### Instruction 
###############
################################################################
################################################################

# If we want to get information on an fundraising event but do not find the information online we can use the slug of a streamer.
# Streamer slugs are often mentioned on the Tiltify website. 
# The idea is the following: Find a streamer -> get the streamer/user id
# -> use this id to find all fundraising id's the streamer was a part of 
# -> for now look manually to find the right event 
# -> save the fundraising event id 
# -> Use the event id to download the fundraising event id

## Task 1: find slugs for a fundraising event
## In our example it is the "Gamers for giving 20204" event
slug_f_event1 <- "markstrom" #manual input after looking it up on Tiltify 


## Task 2: Use slug to find the user id 
slug_url <- paste0("https://v5api.tiltify.com/api/public/users/by/slug/", slug_f_event1)
slug_response <- GET(slug_url, add_headers("Authorization" = paste("Bearer", access_token)))
slug_id_f_event1 <- content(slug_response)$data$id


## Task 3: Use the user id to find the fundraising event id 
slug_id_url <- paste0("https://v5api.tiltify.com/api/public/users/",slug_id_f_event1,"/integration_events")
slug_id_response <- GET(slug_id_url, add_headers("Authorization" = paste("Bearer", access_token)))
# You now look at the item below and than assess which event you need change.
# Then change the "XYC" below accordingly 
View(content(slug_id_response))
f_event1_id <- content(slug_id_response)$data[["XYC"]]$fundraising_event_id


## Task4: Use the event id to download event data

limit <- 10
i <- 10

fundraising_event_id_url <- paste0("https://v5api.tiltify.com/api/public/fundraising_events/",f_event1_id,"/supporting_events?&limit=", limit)

fundraising_event_id_response <- GET(fundraising_event_id_url, add_headers("Authorization" = paste("Bearer", access_token)))

ls_campaigns <- list(content(fundraising_event_id_response))

after_cursor <- tail(ls_campaigns [[1]],1)$metadata$after


while (i == limit) {
  fundraising_event_id_url <- paste0("https://v5api.tiltify.com/api/public/fundraising_events/",f_event1_id,"/supporting_events?&limit=",limit, "&after=", after_cursor)
  fundraising_event_id_response <- GET(fundraising_event_id_url, add_headers("Authorization" = paste("Bearer", access_token)))
  
  new_campaigns <- list(content(fundraising_event_id_response))
  ls_campaigns <- c(ls_campaigns, new_campaigns)
  
  after_cursor <- tail(ls_campaigns[[length(ls_campaigns)]])$metadata$after
  
  i = length(ls_campaigns[[length(ls_campaigns)]]$data)
}


json_df <- toJSON(ls_campaigns) # Can be saved in different formats
write_json(json_df, "f_event1.json") # Can be saved in different formats




