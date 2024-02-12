#################################################
######
######              Tiltify API
######
#################################################
rm(list = ls()) #Remove all objects in the global environment

setwd("C:/Users/philj/OneDrive/Desktop/Arbeit/06_WU_IMSM/01_Tiltify") #Set the Working Directory

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
client_id <- "c2c9189d620072c5bed0b7ca21ec085ac4debafceb6f112d8c674723dc71491a" #Manuel input
client_secret <- "8cc9f3763f97f81e39409f0dccc5063078388f0c9f7e21dd6c42198a2b42b1a4" #Manuel input
redirect_uri <- "http://localhost:9000" #Manuel input
redirect_uri_encoded <- URLencode(redirect_uri, reserved = TRUE)

#include the two objects in this line
paste0("https://tiltify.com/oauth/authorize?response_type=code&client_id=",client_id,
    "&redirect_uri=", redirect_uri_encoded,
    "&scope=public")
#Copy this output (without the parenthesis) into your web browser. 
#Log in in and click on authenticate -> "error" message 
#The webadress is now something like: http://redirect_uri/?code=b02f2175b8787f5d64fdc927e3f3638cdc41fbcf53e7f4870b35654e7360b148
#Copy everything after code= and paste down below

#Copy the code here!
code <- "009c64f2899cd72253b21841f7a5c9bac571f5c21a0169dcb7c588a83c0c6d08"

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

access_token <- content(response)$access_token

rm(body_data, response, client_id, client_secret, code, redirect_uri, redirect_uri_encoded, url)

