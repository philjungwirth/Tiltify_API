#################################################
######
######              Tiltify API
######
#################################################

## This is a short introduction into how to download the Tiltify API access code
## This code will be needed to download any information from Tiltify
## If you have not set up a developer account on the Tiltify website, you need to do so first.
## This will give you information on your client_id, client_secret and redirect_uri 

rm(list = ls()) #Remove all objects in the global environment

setwd("C:/Users/XXXXXXXXX/01_Tiltify") #Set the Working Directory

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
######              Authorization Code
#################################################

#hide the manuel inputs
client_id <- "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" #Manuel input
client_secret <- "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" #Manuel input
redirect_uri <- "http://localhost:1000" #Manuel input
redirect_uri_encoded <- URLencode(redirect_uri, reserved = TRUE)

#include the two objects in this line
paste0("https://v5api.tiltify.com/oauth/authorize?&client_id=",client_id,
    "&response_type=code&redirect_uri=", redirect_uri_encoded,
    "&scope=public")

#Copy this output (without the parenthesis) into your web browser. 
#Log in in and click on authenticate -> "error" message 
#The website is now something like: http://redirect_uri/?code=b02f2175b8787f5d64fdc927e3f3638cdc41fbcf53e7f4870b35654e7360b148
#Copy everything after "code=" and paste the code down below 

#Copy the code here!
code <- "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

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

# Save the access token 
access_token <- content(response)$access_token

rm(body_data, response, client_id, client_secret, code, redirect_uri, redirect_uri_encoded, url)

