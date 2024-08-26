# As another building block we built a code that uses an available fundraising event id to download all donations
# Here we start with the event ID -> extract all campaigns that contributed 
# Run through all those campaigns and download each individual donation 


fundraising_event_id <- "e2fc5d0e-a625-424f-aca3-f8522d8d7ed1" #This is an example ID, please manually insert one

limit <- 10
i <- 10

fundraising_event_id_url <- paste0("https://v5api.tiltify.com/api/public/fundraising_events/",fundraising_event_id,"/supporting_events?&limit=", limit)

fundraising_event_id_response <- GET(fundraising_event_id_url, add_headers("Authorization" = paste("Bearer", access_token)))

ls_campaigns <- list(content(fundraising_event_id_response))

after_cursor <- tail(ls_campaigns [[1]],1)$metadata$after


while (i == limit) {
  fundraising_event_id_url <- paste0("https://v5api.tiltify.com/api/public/fundraising_events/",fundraising_event_id,"/supporting_events?&limit=",limit, "&after=", after_cursor)
  fundraising_event_id_response <- GET(fundraising_event_id_url, add_headers("Authorization" = paste("Bearer", access_token)))
  
  new_campaigns <- list(content(fundraising_event_id_response))
  ls_campaigns <- c(ls_campaigns, new_campaigns)
  
  after_cursor <- tail(ls_campaigns[[length(ls_campaigns)]])$metadata$after
  
  i = length(ls_campaigns[[length(ls_campaigns)]]$data)
}


sub_campaign_vec <- vector()
campaign_vec <- vector()
#get vector for all the campaign id's
for (x in 1:length(ls_campaigns)) {
  for (i in 1:length(ls_campaigns[[x]]$data)) {
  sub_campaign_vec[i] <- ls_campaigns[[x]]$data[[i]]$id
  i = i + 1
  }
  campaign_vec <- c(campaign_vec, sub_campaign_vec)
  x = x + 1 
}

campaign_vec <- unique(campaign_vec)



#Make a loop to fetch all donors for for each campaign id 
x <- 1
i <- 10
limit <- 100
final_df <- list()
#nothing done here 
for (x in 1:length(campaign_vec)) {
  
  campaigns_id <- campaign_vec[i]
  
  donations_url <- paste0("https://v5api.tiltify.com/api/public/campaigns/", campaigns_id, "/donations?&limit=",limit)
  donations_response <- GET(donations_url, add_headers("Authorization" = paste("Bearer", access_token)))
  
  
  test <- list(content(donations_response)$data)
  
  if (length(test[[1]]) != 0) {
    ls_donations <- list(content(donations_response)$data)  
  
  
  after_cursor <- tail(list(content(donations_response))[[1]],1)$metadata$after
  
  i = length(ls_donations[[length(ls_donations)]])
    
    while (i == limit) {
    donations_url <- paste0("https://v5api.tiltify.com/api/public/campaigns/", campaigns_id, "/donations?&limit=", limit, "&after=", after_cursor)
    donations_response <- GET(donations_url, add_headers("Authorization" = paste("Bearer", access_token)))
    
    new_donations <- list(content(donations_response)$data)
    ls_donations <- c(ls_donations, new_donations) 
    after_cursor <- tail(list(content(donations_response))[[1]],1)$metadata$after
    
    i = length(new_donations[[length(new_donations)]])
    }
    
  final_df <- c(final_df, ls_donations)
  }
  x = x + 1
}
