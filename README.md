# perez.wiki
A Flask Server on gunicorn and nginx running my personal website.

Go to [my website](perez.wiki) to see it in action.

# Requirements
A GNU/Linux based operating system (Debian 10, Ubuntu 20, Arch Linux 2020, etc)
  * sudo privileges on the target machine
Python3.7 
VirtualEnv
python3-pip 
python3-dev 
build-essential 
libssl-dev 
libffi-dev 
python3-setuptools
Nginx

# Installation Instructions

*This website is set up to run with gunicorn and nginx in mind, these 
 instructions can be modified for any WSGI/Proxy compatible with Flask,
 but it is not guaranteed to work.*
 
1. Clone this repository, and change your working directory to it.
2. Export an environment variable named SECRET_KEY with your 
   preferred hashed string. I used the [perl SHA3 module][sha3sum], 
   but you're welcome to use any method. If this step is skipped, 
   a default string will be used. That string is tracked by git, so 
   it is not secure.
2. Create a python virtual environment named "venv"

    `python3 -m venv venv` 
  
3. Enter the virtual environment and install everything in the 
   environments file then exit.
   
    ```
    source venv/bin/activate
    pip3 install -r requirements.txt
    deactivate
    ```
    
4. Install the included *perez_wiki.service* file in the default
   location, changing the directories referenced in the file 
   to those of the perez_wiki project. 
   
   `cp -a files/perez_wiki.service /etc/systemd/system/`
   
   This will turn the website into a service that can be turned
   on and off from any directory, and will make troubleshooting 
   easier. Additionally, feel free to add/remove workers from
   the gunicorn instance.
 
5. Start, enable, and verify the service and verify the webserver
   is running.
   
   ```
   sudo systemctl start perez_wiki
   sudo systemctl enable perez_wiki
   sudo systemctl status perez_wiki
   ```
   
   If there are no errors and you are able to visit the webserver,
   you are good to go. If there are errors, stack overflow is your
   friend. There is also a troubleshooting section at the end of 
   this doc to rule out some more obvious problems and save you
   time.

6. Set up HTTP nginx. Install the included nginx configuration
   in the appropriate location. Replace the domain with one 
   you have linked to your server via DNS. (Don't know what I'm talking
   about? DigitalOcean has [handy guide][DO_DNS] on DNS)
   
   `cp -a perez_wiki /etc/nginx/sites-available/perez_wiki`
   
   Enable the site.
   
   `sudo ln -s /etc/nginx/sites-available/myproject /etc/nginx/sites-enabled`
   
   Verify the nginx configuration syntax, and restart nginx.
   
   ```
   sudo nginx -t
   sudo systemctl restart nginx
   ```
   
7. Verify the application is functioning by visiting the domain hosting
   the site. I've found NGINX to have the best logging, but gunicorn and
   Flask's logging are not awful. Logs for nginx are in `/var/log/nginx'.
   You can also use journalctl to see process logs for nginx and perez_wiki
   
8. Secure the website with your preferred certificate authority. There are
   many paid and free services, but the best and easiest is Let's Encrypt.
   EFF can provide instructions for just about any OS via [this link][LE].
   It will automatically change any NGINX configurations to suit its 
   needs. 
   
9. Verify that the web server is up and secure.

# Troubleshooting
The most common errors I've found are bad gateways and malconfigured WSGI.

Ensure relavant paths in the included configurations match. The `ExecStart`
path in the service configuration will determine where the WebProxy Socket
is, by default it is in the project's main directory. Ensure this matches 
the `proxy_pass` in the nginx configuration. If they don't, you'll get a
502 Bad Gateway. 

The WSGI took a while to tinker, changing anything in it (or it's 
dependencies) may lead to  problems that may not be easily parsed. If the 
server appears to be running normally but you cannot view the website, this 
is likely the source of your pain. This [stack overflow question][wsgi_so] 
was illuminating and may help you. 
   
# References
I used this [Digital Ocean article on Flask/Gunicorn/NGINX[DO_FGN] to build 
this webserver.
  
[DO_DNS]: <https://www.digitalocean.com/docs/networking/dns/>
[DO_FGN]: <https://www.digitalocean.com/community/tutorials/how-to-serve-flask-applications-with-gunicorn-and-nginx-on-ubuntu-18-04#step-1-%E2%80%94-installing-the-components-from-the-ubuntu-repositories>
[LE]: <https://certbot.eff.org/instructions>
[sha3sum]: <https://manpages.debian.org/unstable/libdigest-sha3-perl/sha3sum.1p.en.html>
[wsgi_so]: <https://stackoverflow.com/questions/33379287/gunicorn-cant-find-app-when-name-changed-from-application/33379650>
