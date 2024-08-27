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
Manually input the fundraising event ID.

The first step is to get a list of all the campaigns that contributed to the fundraising event.

In the second step the code loops through the list of the campaigns and downloads all donations.  
