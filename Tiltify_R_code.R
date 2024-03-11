#################################################
######
######              Tiltify API
######
#################################################

rm(list = ls()) #Remove all objects in the global environment

setwd("C:/Users/philj/OneDrive/Dokumente/GitHub/Tiltify_API") #Set the Working Directory

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
client_id <- "c2c9189d620072c5bed0b7ca21ec085ac4debafceb6f112d8c674723dc71491a" #Manual input
client_secret <- "8cc9f3763f97f81e39409f0dccc5063078388f0c9f7e21dd6c42198a2b42b1a4" #Manual input
redirect_uri <- "http://localhost:9000" #Manual input
redirect_uri_encoded <- URLencode(redirect_uri, reserved = TRUE)

#Create URL, paste the URL in Web browser and copy the code
paste0("https://tiltify.com/oauth/authorize?response_type=code&client_id=",client_id,
    "&redirect_uri=", redirect_uri_encoded,
    "&scope=public")

#Paste the code here!
code <- "51c434fe0839dda964be710a2c5c5d69d9078e31b565dc2bf358a1f461dd7b45" #Manual input

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

after_cursor <- tail(ls_campaigns[[1]],1)$metadata$after


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

#################################################
######              Get Donations Targets
#################################################
x <- 1

df_target <- data.frame()


for(x in 1:length(campaign_vec)) {
  
  campaigns_id <- campaign_vec[x]
  
  target_url <- paste0("https://v5api.tiltify.com/api/public/campaigns/", campaigns_id, "/targets?&limit=",limit)
  target_response <- GET(target_url, add_headers("Authorization" = paste("Bearer", access_token)))
  
  test <- list(content(target_response)$data)
  
  if(length(test[[1]]) != 0 && is.null(test[[1]]) == FALSE) {
    
    df_target[x,1] <- campaign_vec[x]
    df_target[x,2] <- test[[1]][[length(test[[1]])]]$amount$value
    df_target[x,3] <- test[[1]][[length(test[[1]])]]$amount$currency
    df_target[x,4] <- test[[1]][[length(test[[1]])]]$id
    
    x <- x + 1
    
  } else {
  
  x <- x + 1
  
  }
  
}

colnames(df_target) <- c("campaign_id", "target", "currency", "target_id")
df_target <- na.omit(df_target)



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

View(final_df)

json <- toJSON(final_df)



