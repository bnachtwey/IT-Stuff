# Disable the eMail Alert By Crontab Command
Copied from [here](https://www.cyberciti.biz/faq/disable-the-mail-alert-by-crontab-command/)

> [!TIP]
> **Basic idea**<br>
> **If the cron execution has no output, no mails are sent**

So the solution is to add `>/dev/null` or `>/dev/null 2>&1` to each line executed by cron.

## Examples
### direct output to a file instead of `stdout` -- add
```
> /var/log/my.app.log 2>&1
```
### Cron job example to disable the email alert
Edit/Open your cron jobs, enter:
```
crontab -e
```
Append string `>/dev/null 2>&1` to stop mail alert:
```
0 1 5 10 * /path/to/script.sh >/dev/null 2>&1
```
OR
```
0 1 5 10 * /path/to/script.sh > /dev/null
```
OR
```
0 * * * * /path/to/command arg1 > /dev/null 2>&1 || true
```
In this example, just redirect output to `/dev/null` only:
```
0 30 * * * /root/bin/check-system-health.py > /dev/null
```
We can use the following syntax when using bash to redirect both stdout and stderr:
command
```
1 30 * * * /root/bin/xyz-job &> /path/to/xyz.app.log.file
## Append instead of overwriting the log file ##
1 30 * * * /root/bin/xyz-job &>> /path/to/xyz.app.log.file
2 45 * * * /root/bin/foo-job &> /dev/null
```
Save and close the file. See redirect STDOUT and STDERR to null and “BASH Shell Redirect stderr To stdout ( redirect stderr to a File )” to suppress output for more information

### Set MAILTO variable to stop cron daemon from sending email
Another option is to set `MAILTO=""` variable at the start of your crontab file or shell script. This will also disable email alert. Edit/Open your cron jobs:
```
crontab -e
```
At the top of the file, enter:
```
MAILTO=""
```
Of course we can redirect email too provided that email server such as Postfix configured:
```
MAILTO="admin@server1.cyberciti.biz"
```
Save and close the file. We can mix them as per our needs. For example:
```
## send email to backup team #
MAILTO="backup.admin@domain-here"
@daily /scripts/backup.sh 

## send email to RAID/storage/san/nas admin ##
MAILTO="storage.admin@domain-here"
* 45 * * * /scripts/test-raid-array.sh 
Another example:

## NO EMAIL ##
@weekly /scripts/containers-backup  >/dev/null 2>&1

## Send email for the /scripts/test-raid-array.sh only ##
MAILTO="sysadmin@corp2.domain-name-here"
@daily /scripts/test-raid-array.sh 

## Disable email alert for rest of cron job##
MAILTO=""
@monthly /path/to/script/logs.sh > /var/log/monthly.log
```
```
