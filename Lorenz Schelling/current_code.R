#################################################
######
######              Tiltify API
######
#################################################

rm(list = ls()) #Remove all objects in the global environment

setwd("C:/Users/loren/Documents") #Set the Working Directory
 
#################################################
######              Install/Load Packages
#################################################

#Load and install all necessary packages
libs <- c(
  "httr", "jsonlite", "utils", "DescTools", "dplyr", "rlist"
)

installed_libs <- libs %in% rownames(
  installed.packages()
)

if(any(installed_libs == F)){
  install.packages(
    libs[!installed_libs]
  )
}

invisible(
  lapply(
    libs, library, character.only = T
  )
)

rm(list = c("installed_libs", "libs")) #Removes unnecessary objects from GE

#################################################
######              Section 1
######         Fetch Access Token
#################################################


#################################################
######              Authorization Code
#################################################

#Manual inputs of your Tiltify Application Keys
client_id <- "8c2cccbca5d3473afdf8301f8e12ba5d882bd95bcdb0f5633e06f9b6ece671b8" #Manual input
client_secret <- "ebf686e8ac089ab1b2713e5b14273d9c71cb04d3639b8fb21b546ed4de0bdaec" #Manual input
redirect_uri <- "http://localhost:9000" #Manual input
redirect_uri_encoded <- URLencode(redirect_uri, reserved = TRUE)

#Create URL, paste the URL in Web browser and copy the code
paste0("https://tiltify.com/oauth/authorize?response_type=code&client_id=",client_id,
       "&redirect_uri=", redirect_uri_encoded,
       "&scope=public")

#Paste the code here!
code <- "73d076d38da7a113afc8f10e406a45c485e6ff3f156e90942096efc78d3b6c52" #Manual input

#################################################
######              Token
#################################################
url <- "https://v5api.tiltify.com/oauth/token"

# Request body data
body_data <- list(
  client_id = client_id,
  client_secret = client_secret,
  grant_type = "authorization_code",
  redirect_uri = redirect_uri,
  code = code
)

# Make the POST request
response <- POST(url, body = body_data, encode = "json", verbose())

# Print the response
content(response)

#Save Access Token
access_token <- content(response)$access_token

rm(body_data, response, client_id, client_secret, code, redirect_uri, redirect_uri_encoded, url)


#################################################
######              Section 2
######         Download Donations
#################################################

fundraising_event_id <- "e2fc5d0e-a625-424f-aca3-f8522d8d7ed1" #Change to the fundraising event you want to analyze

#Set the limits how many entries should be downloaded per loop run (Max. 100)
limit <- 10
i <- 10

#################################################
######              Get Campaigns 
#################################################

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

rm(fundraising_event_id, fundraising_event_id_url, sub_campaign_vec, ls_campaigns, new_campaigns, fundraising_event_id_response, after_cursor)


campaign_vec[1]

#################################################
######              Get Donations
#################################################

#Set parameters for loops
x <- 1
i <- 100
limit <- 100
final_df <- list()


for (x in 1:length(campaign_vec)) {
  
  campaigns_id <- campaign_vec[x]
  
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

rm(donations_response, ls_donations, new_donations, test, i, limit, x, campaigns_id, after_cursor, donations_url)

library(jsonlite)
library(tidyverse)
library(dplyr)
library(purrr)

json <- toJSON(final_df)
json_data <- fromJSON(json, flatten = TRUE)



all_donations <- bind_rows(lapply(json_data, bind_rows))


unique(all_donations$fundraising_event_id)
View(all_donations)

# Summarize all donations in the amount.value column
total_donations <- sum(all_donations$amount.value)
all_donations

all_donations$amount.value <- as.numeric(all_donations$amount.value)
total_donations <- sum(all_donations$amount.value)
# Print the total donations
print(total_donations)
campaign_vec



# Create an empty dataframe to store campaign IDs and their corresponding total fundraising amounts
campaign_fundraising <- data.frame(id = character(), fundraising_amount = numeric())

# Iterate over each campaign ID in the campaign_vec
for (campaign_id in campaign_vec) {
  
  # Filter donations dataframe for the current campaign ID
  campaign_donations <- all_donations[all_donations$campaign_id == campaign_id, ]  # Corrected the column name here
  
  # Calculate the total fundraising amount for the current campaign
  total_amount <- sum(campaign_donations$amount.value)
  
  # Create a new row for the current campaign in the campaign_fundraising dataframe
  new_row <- data.frame(id = campaign_id, fundraising_amount = total_amount)
  
  # Append the new row to the campaign_fundraising dataframe
  campaign_fundraising <- rbind(campaign_fundraising, new_row)
}

# View the resulting dataframe
View(campaign_fundraising)

#################################################
########### Doesn't function ####################
#################################################

# Ensure the required libraries are installed and loaded
required_libraries <- c("httr", "jsonlite", "dplyr")
new_libraries <- required_libraries[!required_libraries %in% installed.packages()[,"Package"]]
if(length(new_libraries)) install.packages(new_libraries)
lapply(required_libraries, library, character.only = TRUE)

# Initialize an empty dataframe to store campaign IDs and their goals
campaign_goals <- data.frame(id = character(), goal = numeric(), stringsAsFactors = FALSE)

# Use the list of campaign IDs obtained earlier
for(campaign_id in campaign_vec) {
  campaign_details_url <- paste0("https://v5api.tiltify.com/api/public/campaigns/", campaign_id)
  
  # Fetch campaign details using the access token for authorization
  response <- GET(campaign_details_url, add_headers(Authorization = paste("Bearer", access_token)))
  
  # Check if the request was successful
  if (http_status(response)$category == "success") {
    # Convert the response to a list
    campaign_details <- fromJSON(rawToChar(response$content))
    
    # Check if the goal field exists in the response and is not null
    if (!is.null(campaign_details$data$goal) && !is.null(campaign_details$data$goal$amount)) {
      # Extract the campaign ID and its goal, then append to the dataframe
      # Assuming the goal is nested within 'goal' object and has a field like 'amount'
      new_row <- data.frame(id = campaign_id, goal = campaign_details$data$goal$amount)
      campaign_goals <- rbind(campaign_goals, new_row)
    } else {
      # Append NA for the goal if it does not exist in the response or is malformed
      new_row <- data.frame(id = campaign_id, goal = NA_real_)
      campaign_goals <- rbind(campaign_goals, new_row)
    }
  } else {
    # Handle unsuccessful requests by appending NA and printing an error message
    print(paste("Failed to fetch campaign details for ID:", campaign_id))
    new_row <- data.frame(id = campaign_id, goal = NA_real_)
    campaign_goals <- rbind(campaign_goals, new_row)
  }
}

# Display the resulting dataframe
print(campaign_goals)