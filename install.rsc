/system script 
add name="dev4you-blacklist-dl" source={/tool fetch url="https://raw.githubusercontent.com/dev4you/Mikrotik-Blacklist/master/blacklist.rsc" mode=https}
add name="dev4you-blacklist-replace" source {/ip firewall address-list remove [find where list="dev4you-blacklist"]; /import file-name=blacklist.rsc}
/system scheduler 
add interval=7d name="dl-mt-blacklist" start-date=Jan/01/2000 start-time=00:05:00 on-event=dev4you-blacklist-dl
add interval=7d name="ins-mt-blacklist" start-date=Jan/01/2000 start-time=00:10:00 on-event=dev4you-blacklist-replace
