# Tiltify_API

This code is structured in two sections. First the code will fetch an access token and secondly it will download all available donations for a pre-defined fundraising event.

## Section 1 - Fetch Access Token
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

## Second Section
Manually input the fundraising event ID.

The first step is to get a list of all the campaigns that contributed to the fundraising event.

In the second step the code loops through the list of the campaigns and downloads all donations.  
