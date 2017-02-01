# firefly-iii-docker-arm
An ARM Docker Container for [firefly-iii](https://github.com/firefly-iii/firefly-iii). Tested on a Raspberry Pi 2. But probably compatible on anything that runs Docker on ARM. (Not ARM64!)

## Usage
1. Get the hardware and software. (For example: Raspbian on a RPi2.)
2. Install docker by running the script from [get.docker.com](https://get.docker.com). *Note: The docker.io package in Raspbian is broken for some reason.*
3. Pull the container. TODO: Put the actual link here.
4. Run the container. You'll have to enter some details before running the container! At least specify the following settings:
  * FIREFLY_CONFIG_MAIL_HOST
  * FIREFLY_CONFIG_MAIL_PORT
  * FIREFLY_CONFIG_MAIL_FROM
  * FIREFLY_CONFIG_MAIL_USERNAME
  * FIREFLY_CONFIG_MAIL_PASSWORD
  * FIREFLY_CONFIG_MAIL_ENCRYPTION
`docker run -e FIREFLY_CONFIG_MAIL_DRIVER=smtp -e FIREFLY_CONFIG_MAIL_HOST=smtp.gmail.com -e FIREFLY_CONFIG_MAIL_PORT=587 -e FIREFLY_CONFIG_MAIL_FROM=your.username.here@gmail.com -e FIREFLY_CONFIG_MAIL_USERNAME=your.username.here@gmail.com -e FIREFLY_CONFIG_MAIL_PASSWORD=yourpasswordhere -e FIREFLY_CONFIG_MAIL_ENCRYPTION=TLS -p 80:80 tomwis97/firefly-iii-arm`
5. ???
6. Profit!

## Known issues
* Due to the use of volumes, the database is slow as fuck. Starting the first time takes about 20 years. 
* This container appears to have Apache included. The webapp is running on Nginx, making the Apache2 install redundant.
* This container is running both the webserver and the database. You might want to split this up sometime. Or not. idk
* Hardcoded Firefly-III version
* Hardcoded password for root database user.
* Application accesses the database as root, instead of a dedicated user.
* No seperate volume for database yet.
* Possibly a feature: User has to enter SMTP settings when starting container.

