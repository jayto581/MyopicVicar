Setting Up New Application Using Myopicvicar Code Base:

The myopicvicar code base is multi modal. That is it can be run as different applications using the same code base.

It relies on a single field in the freeukgen_application.yml located in the config folder to determine which application is to be initiated.

It is currently able to recognize 3 different applications. Additional applications can be added.
  freebmd
  freecen
  freereg

The application.rb creates two fields 1) MyopicVicar::Application.config.template_set containing application name in lower case and 2) MyopicVicar::Application.config.freexxx_display_name which contains the name of the application in CamelCase. The models can use these. Controllers and views can access 3 methods appname, appname_downcase and appname_upcase for ease of typing.

Application.rb also adds the appropriate assets from assets_freexxx to assets paths. The 3 freexxx folders contain the images and unique styles to be used by the application. The core styles are already in the assets folder.

There is also a public_files.rb initializer that copies the appropriate public files for the application from the public_site_specific folder to the public folder.

NOTE WHEN MAKING APPLICATION SPECIFIC CHANGES TO ASSETS FOR STYLES, JS, IMAGES ETC THESE MUST BE MADE IN THE ASSETS_FREEXXX FOLDERS. CHANGES TO THE COMMON CORE ASSETS SHOULD BE MADE IN THE ASSETS FOLDER AND THESE WILL AFFECT ALL APPLICATIONS.


Setting Up An Application Using Myopicvicar Code Base:

Step 1. Create freeukgen_application.yml

The application initializer reads a field called template_set from a yml file located in the config folder called freeukgen_application.yml that contains the name of the application. An example of the format and layout is contained in freeukgen_application_example.yml


Step 2. Create database.yml

  You can base this on the database.example.yml

  Do step C of the freereg installation instructions but replace freereg2 with freecen2 wherever it appears

Step 3. Create errbit.yml
  On https://errbit.freeukgen.org.uk/ create a new app if you wish to report errors

Step 4. Create mongo_config.yml

Step 5 Create mongoid.yml

This will be the same as used for reg except a different database name

Step 6. Clone the myopicvicar code base into the folder from which you will run this application eg freecen

Open a command window on that folder and run bundle install

Step 7. Copy the files created in steps 1-5 into the config folder

Step 8. Load the mongodb collections having started mongodb as normal using the download links provided to you

Start mongo in a command window on the application folder and use the database name from step 5

create the indexes by pasting in the scripts index zip sent to you into mongo one at a time

Step 9. Set up refinery

repeat steps G9, G12 and G15 of the Freereg installation documentation

Step 10. Run rake assets:precompile to load the assets

Step 11. Start your server in the application folder created in step 6




Updating the code base from Myopicvicar Code Base

This is done in the normal manner pulling code change and running assets:precompile if assets are changed.

Switching From One application to Another:

Stop the server; start the server in the application folder created in step 6 for freecen, Myopicvicar for freereg and what ever is being used for freebmd
