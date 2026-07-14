# perez.wiki
A Flask Server on gunicorn and nginx running my personal website.
Go to [my website](https://www.perez.wiki) to see it in action.

# Requirements
* A GNU/Linux based operating system (Debian 12, Ubuntu 22.04, Arch Linux, etc)
  * sudo privileges on the target machine
* Python 3.11+
* VirtualEnv
* python3-pip
* python3-dev
* build-essential
* libssl-dev
* libffi-dev
* python3-setuptools
* NGINX
* certbot
* python3-certbot-nginx

# Users 
This project uses two service accounts to separate deployment from runtime:

* **perez-wiki** — owns the app files and runs the gunicorn service
* **github-runner** — member of the `perez-wiki` group, handles deployments via GitHub Actions

```
useradd -m -s /bin/false perez-wiki
useradd -m -s /bin/bash github-runner
usermod -aG perez-wiki github-runner
usermod -aG perez-wiki www-data
```

# Firewall
This project uses nftables. The included `scripts/setup_firewall.sh` will configure
it for you. It opens ports 22, 80, and 443 and drops everything else.

# Deployment
Deployments are handled automatically via a GitHub Actions self-hosted runner.
The included `scripts/setup_runner.sh` will install and configure the runner as
a systemd service. You will need a registration token from:

   GitHub repo → Settings → Actions → Runners → New self-hosted runner

The runner requires the following sudo rules:

```
github-runner ALL=(ALL) NOPASSWD: /bin/cp
github-runner ALL=(ALL) NOPASSWD: /bin/systemctl reload nginx
github-runner ALL=(ALL) NOPASSWD: /bin/systemctl restart perez_wiki
github-runner ALL=(ALL) NOPASSWD: /bin/systemctl daemon-reload
```

Any push to `main` will automatically pull the latest code, install dependencies,
update the nginx and service configurations, and restart the app.

You can also deploy this manually, using my Jenkins pipeline. See the GitHub
Action at `.github/workflows/deploy-jenkins.yml` and [infra_perez_wiki][infra]

# Installation Instructions

1. Clone this repository, and change your working directory to it.
2. Export an environment variable named SECRET_KEY with your
   preferred hashed string. I used the [perl SHA3 module][sha3sum],
   but you're welcome to use any method. If this step is skipped,
   a default string will be used. That string is tracked by git, so
   it is not secure.
3. Create a python virtual environment named "venv"

    `python3 -m venv venv`

4. Enter the virtual environment and install everything in the
   environments file then exit.

    ```
    source venv/bin/activate
    pip install -r requirements.txt
    deactivate
    ```

5. Install the included *perez_wiki.service* file in the default
   location, changing the directories referenced in the file
   to those of the perez_wiki project.

   `cp -a files/perez_wiki.service /etc/systemd/system/`

   This will turn the website into a service that can be turned
   on and off from any directory, and will make troubleshooting
   easier. Additionally, feel free to add/remove workers from
   the gunicorn instance.

6. Start, enable, and verify the service and verify the webserver
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

7. Set up HTTP nginx. Install the included nginx configuration
   in the appropriate location. Replace the domain with one
   you have linked to your server via DNS. Disable the default
   nginx site or it will take precedence over yours.

   ```
   cp -a files/perez_wiki /etc/nginx/sites-available/perez_wiki
   sudo ln -s /etc/nginx/sites-available/perez_wiki /etc/nginx/sites-enabled
   sudo rm /etc/nginx/sites-enabled/default
   ```

   Verify the nginx configuration syntax, and restart nginx.

   ```
   sudo nginx -t
   sudo systemctl restart nginx
   ```

8. Verify the application is functioning by visiting the domain hosting
   the site. I've found NGINX to have the best logging, but gunicorn and
   Flask's logging are not awful. Logs for nginx are in `/var/log/nginx`.
   You can also use journalctl to see process logs for nginx and perez_wiki.

9. Secure the website with Let's Encrypt. Install certbot and run it —
   it will automatically update your nginx configuration and set up
   a renewal cron.

   ```
   apt-get install -y certbot python3-certbot-nginx
   certbot --nginx -d perez.wiki -d www.perez.wiki
   ```

   For more info on certbot, [click here][LE].

10. Verify that the web server is up and secure.

# Troubleshooting
Ensure relevant paths in the included configurations match. The `ExecStart`
path in the service configuration will determine where the WebProxy Socket
is, by default it is in the project's main directory. Ensure this matches
the `proxy_pass` in the nginx configuration. If they don't, you'll get a
502 Bad Gateway. nginx also needs read access to the socket — ensure
`www-data` is in the `perez-wiki` group.

The WSGI took a while to tinker, changing anything in it (or its
dependencies) may lead to problems that may not be easily parsed. If the
server appears to be running normally but you cannot view the website, this
is likely the source of your pain. This [stack overflow question][wsgi_so]
was illuminating and may help you.

If you are hosting on Linode, note that Linode has its own Cloud Firewall separate
from nftables on the server. You will need to open ports there as well,
or the traffic will never reach the server.

If you are troubleshooting the Jenkins deployment.... good luck. That's its
own can of worms. You'll need to first make sure the AWS connection is solid,
then check Jenkins logs, then start troubleshooting terraform. The Jenkins logs
will be the most illuminating.

# References
I used this [Digital Ocean article on Flask/Gunicorn/NGINX][DO_FGN] in part to build
this webserver.

[DO_FGN]: <https://www.digitalocean.com/community/tutorials/how-to-serve-flask-applications-with-gunicorn-and-nginx-on-ubuntu-18-04#step-1-%E2%80%94-installing-the-components-from-the-ubuntu-repositories>
[infra]: <https://github.com/isa-p941/infra_perez_wiki>
[LE]: <https://certbot.eff.org/instructions>
[sha3sum]: <https://manpages.debian.org/unstable/libdigest-sha3-perl/sha3sum.1p.en.html>
[wsgi_so]: <https://stackoverflow.com/questions/33379287/gunicorn-cant-find-app-when-name-changed-from-application/33379650>
