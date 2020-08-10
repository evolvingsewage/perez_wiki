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
   
  [sha3sum]: <https://manpages.debian.org/unstable/libdigest-sha3-perl/sha3sum.1p.en.html>
