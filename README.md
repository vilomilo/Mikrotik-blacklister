# Mikrotik-blacklister
Mikrotik blacklistų generatorius
# mikrotik-blacklist-generator
Parses a few blacklists, aggregates their data and prepares a file, ready to import on Mikrotik devices. Meant to be running as a cron job on a web server, from which then Mikrotik fetches the blacklist and imports it periodically.

**Most of the blacklists this script pulls data from are updated once daily, and they are currently free for everyone to use. So please respect that, and don't hog their servers with requests every few seconds. Once or twice a day is more than enough. If you want your blacklists updated in realtime, I suggest setting up a honeypot, or consider subscribing to some lists distributed via BGP.**

# How to install

### On your Linux based web server
1. Copy **update-blacklists.sh** to **/usr/local/bin** and make it executable with `chmod +x /usr/local/bin/update-blacklists.sh`.
2. If you're running **x86_64** compatible kernel (see with `uname -m`), you can use the included precompiled **cidr-convert.bin**, otherwise compile it first by running `gcc -o cidr-convert.bin cidr-convert.c`.
3. Copy **cidr-convert.bin** to **/usr/local/bin** and make it executable with `chmod +x /usr/local/bin/cidr-convert.bin`.
4. Create a directory for temporary files. You can use **/tmp**, but I prefer having them in **/etc/mikrotik-blacklist**.
5. Modify variables **saveTo** and **exportTo** in **/usr/local/bin/update-blacklists.sh** to your liking.
6. Test by running **/usr/local/bin/update-blacklists.sh** and if everything works correctly, add it to your crontab. You can use `crontab -e` to edit your crontab file and `crontab -l` to see its contents. Mine looks like `0 */12 * * * /usr/local/bin/update-blacklists.sh`.

### On your Mikrotik
1. Create a new script called **blacklist_update**.
2. Copy the contents of **blacklist_update.rsc** into it.
3. Modify the **blacklistURL** variable to point to your web server, where generated blacklist is accessible.
3. Create a new scheduler that will call **blacklist_update** script at your preferred interval. I suggest once or twice per day.
4. Create firewall rules in **input**, **forward**, and if you're really paranoid, even in **output** chains that will tarpit/drop/reject if source or destination is on **z_blacklist** address list.

# What it actually does

### The Bash script
1. Deletes old fetched blacklists.
2. Fetches various blacklists, parses them in a way that only **IP/MaskBit** remain and saves each to it's own **.txt** file.
3. Concatenates all fetched blacklists and runs them through **cidr-convert.bin**.
4. It's quite possible that certain IPs or ranges from different blacklists overlap with each other. Some blacklists use **IP/MaskBit** format, others list each IP address separately. **cidr-convert.bin** in a way "minifies" all the IP addresses by writing them in a CIDR notation. This way we don't have to worry about having 64 different entries in our blacklist, when we can only have one for a certain IP range.
5. Finally, IP ranges are appended and prepended with RouterOS's "try catch" block. More about this later.

### The Mikrotik script
It simply fetches our generated blacklist and imports it. Could be a lot shorter, but apparently "try catch" on RouterOS doesn't work as it should.

### The generated blacklist
Is actually a RouterOS script. It tries to add blacklisted IPs to address list **z_blacklist** with a timeout of 3 days. If an IP address already exists there, it just updates the 3 days timeout again to 3 days. This way you don't ever have to remove old IP addresses from your blacklist before importing new ones and if by any chance your web server isn't accessible for 3 days, or fetching of original blacklists fails once or twice, you still remain protected until the 3 days timeout runs out.

# Additional considerations
Blacklists are only a small part of a good defense strategy, which you need to think thoroughly about. You can also very easily implement a simple honeypot and portscan detection on your Mikrotik device, just through some basic firewall rules. But keep in mind that nothing in this world is really black and white. For example, you might blacklist an IP that's attacking you, but behind that IP could very well be one of your friendly customers, whose computer could be compromised with some malware he or she doesn't even know about.

Bottom line is: Don't Test In Production™

# Licensing
Original Bash script found on Joshaven Potter's website: http://joshaven.com/resources/tricks/mikrotik-automatically-updated-address-list/

CIDR calculator by Kai Schlichting: http://www.spamshield.org/

Based on that, figure out which license applies here. My modifications are free to use by anyone. Credit would be nice, but it's not necessary.
