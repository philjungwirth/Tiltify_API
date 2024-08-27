# Tiltify_API

This reposatory should help you to download data from the Tiltify platform using the programming language R.
The main idea is that we provide two folders. The first one (AP_access_code) helps you to retrieve your personalized code that you will need to fatch data from the API. On the other hand, the second folder (Building_blocks) provides some basic idea of how to retrieve the final data. Basically we want to show how it is done in some specific instances and you can than start to build your on reqeust based on those basic code lines.

## Folder 1 - API_access_code
Tiltify Application:
- Create Tiltify account
- Create an application (can be found under "Developers")
  - Give the application a name and a Re-direct URI (e.g. http://localhost:9000)
  - The application will give you a client ID & secret

Generate Code for token:
- Manually input the Re-direct URI, client ID and client secret into the code
- Create the URL using the paste0() command
- Copy that URL to your web browser
- Certify you account
- Afterwards you will be redirected and get a "Website could not be reached" message
- Copy the web address after "code=" and paste it into the R-code

Fetch the Access Token:
- Simply run the code and the access code will be stored in the GE

## Folder 2 - Building_blocks
Overall we provide three different building blocks. However 3 and 4 are basically snippets from the first two.

### 01_Slug_id_FundEvent_R_code
Let's say you want to know which campaigns contributed to a specific fundraising event, but you don't know the event ID.
If you have the name of the event, you can take a look at the Tiltify website to see the top contributers. 
For example, if we want to get information on the "Gamers for giving 2024" event we see that a streamer with the slug "markstrom" contributed. 
Now we can do the following:
- Use the slug name to get the streamer id
- Use the streamer id to download all the events he contributed & manually look up the right event
- Store the right event id
- Download the campaigns that contributed, by using the event id

### 02_Fundraiser_event_R_code 
The next building block is concerned with downloading every single donation that was given to a specific fundraising event. 
For this example we assume we know the specific event id (see how you could now use the first part of the upper code to find the id).

The main idea is the following:
- One uses the event id to download information on all campaigns that contribute
- Then save all campaign id's in a vector
- Use that vector to fetch every donation for each campaign


### 03_Slug_R_cod
This code basically starts with a slug name and then gets all donations for a compaign that was looked up manually from all campaigns that the slug was/is running. 

### 04_While_loop_R_code
This code block shows how get all donations if you have a campaign id. 


*Have fun with the Tiltify code and do not hesitate to reach out if you need something! *
