campaigns_id <- "XXXXXXXXXXXXXXXXXXX" #change manually 

limit <- 10
i <- 10
# Fetch the first batch of donations
donations_url <- paste0("https://v5api.tiltify.com/api/public/campaigns/", campaigns_id, "/donations?&limit=",limit)
donations_response <- GET(donations_url, add_headers("Authorization" = paste("Bearer", access_token)))
ls1 <- list(content(donations_response))
after_cursor <- tail(ls1[[1]],1)$metadata$after


# Check if there are more donations
while (i == limit) {
  donations_url <- paste0("https://v5api.tiltify.com/api/public/campaigns/", campaigns_id, "/donations?&limit=",limit, "&after=", after_cursor)
  donations_response <- GET(donations_url, add_headers("Authorization" = paste("Bearer", access_token)))
  
  new_donations <- list(content(donations_response))
  ls1 <- c(ls1, new_donations)
  after_cursor <- tail(ls1[[length(ls1)]])$metadata$after
  i = length(ls1[[length(ls1)]]$data)
}



