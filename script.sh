#!/bin/bash
#
#
#Made By Arthur Schieszer For Cyberpatriot Team Neofetch
#
#Installs necesecary programs and updates the system
apt -qq --yes install ufw net-tools gufw clamav neofetch htop auditd fail2ban ranger micro tldr nala zoxide
apt -qq --yes update
apt -qq --yes purge ophcrack nginx wireshark npcap nc ettercap ettercap-graphical
echo "Would you like to install system updates now? [y/N]"
read update
if [ update == "y" ];
then
  apt -qq --yes upgrade
  apt -qq --yes dist-upgrade
fi
#
clear
#
#
#Finds the user's name
echo "Before continuing, please make a file on the Desktop called readmeusers.txt and copy all users listed in the readme to it."
echo "Please Enter the Current User's Name"
read varname
#Could be replaced with $USER, but left this way to prevent people accidentally running as the wrong person
echo "type your readmeusers in this file, then press enter"
nano /home/$varname/Desktop/readmeusers.txt
read bsvariable
#
#
#
echo "type your readmeadmins in this file, then press enter"
nano /home/$varname/Desktop/readmeadmins.txt
read bsvariable
#
#
#
#Enables auditing
auditctl -e 1
#
#Enable fail2ban
systemctl enable fail2ban
#
#Enables and configures the firewall
ufw enable
ufw default allow outgoing
ufw default deny incoming
#ufw allow 22
#for ssh^
#
#
#
#Makes the userlist
awk -F: '($3>=1000) {print $1}' /etc/passwd | sort > /home/$varname/Desktop/userlist.txt
echo root >> /home/$varname/Desktop/userlist.txt
sed -i '/nobody/d' /home/$varname/Desktop/userlist.txt
sed -i "/$varname/d" /home/$varname/Desktop/userlist.txt
sort /home/$varname/Desktop/userlist.txt
#
#
#
#Change user passwords
for i in `less /home/$varname/Desktop/userlist.txt`
do
  echo $i
  passwd -e "$i"
  echo -e "CyberpatriotS@16\nCyberpatriotS@16" | passwd "$i"
  chage -m 3 -M 90 -I 30 -W 7 -d 0 "$i"
  echo "$i's password and password age settings have been changed"
done
##############################################################Edit login.defs
#sed -i "s//" /etc/login.defs
#
#
#
#Deletes unwanted users
########################################################################Should Consider locking accounts with the shadow file instead of deleting them.

sort /home/$varname/Desktop/readmeusers.txt
touch /home/$varname/Desktop/usersdel.txt
touch /home/$varname/Desktop/usersdiff.txt
#Uses diff to compare users on the readme to users in the system
diff /home/$varname/Desktop/userlist.txt /home/$varname/Desktop/readmeusers.txt > /home/$varname/Desktop/usersdiff.txt
#Uses awk to read diff output
#Reads all names with a < before them
awk '/^\</ {print $2}' /home/$varname/Desktop/usersdiff.txt > /home/$varname/Desktop/usersdel.txt
#Reads all names with a > before them. They do not belong in the usersdel list, so they will be put into antidiff to be removed later.
awk '/^\>/ {print $2}' /home/$varname/Desktop/usersdiff.txt > /home/$varname/Desktop/antidiff.txt
#Remove users in antidiff from usersdel
for i in `less /home/$varname/Desktop/antidiff.txt`
do
  sed -i "/$i/d" /home/$varname/Desktop/usersdel.txt
done
#Comments out unwanted users
for i in `less /home/$varname/Desktop/usersdel.txt`
do
  sed -i "s/$i/#$i/" /etc/passwd
  passwd -l $i
done
<<Block
#
#
#
#Disables login as root
sed -i 's|root:x:0:0:root:/root:/bin/bash|root:x:0:0:root:/root:/sbin/nologin|' /etc/passwd
passwd -l root
#
#
#
#Disable unwanted admins
###### Currently only uses the sudo group, find a way to incorperate adm and wheel groups
###### revise the top line??? sed -i "s/root:x:0:/root:x:0:/" /etc/group
sort /home/$varname/Desktop/readmeadmins.txt
awk -F: '/sudo/ {print $4}' /etc/group > /home/$varname/Desktop/admins.txt
##awk -F: '/adm/ {print $4}' /etc/group > /home/$varname/Desktop/admins2.txt
sort /home/$varname/Desktop/admins.txt
##sort /home/$varname/Desktop/admins2.txt

diff /home/$varname/Desktop/admins.txt /home/$varname/Desktop/readmeadmins.txt > /home/$varname/Desktop/adminsdiff.txt
awk '/^\</ {print $2}' /home/$varname/Desktop/adminsdiff.txt > /home/$varname/Desktop/adminsdel.txt
awk '/^\>/ {print $2}' /home/$varname/Desktop/adminsdiff.txt > /home/$varname/Desktop/antiadmindiff.txt
for i in `less /home/$varname/Desktop/antiadmindiff.txt`
do
  sed -i "/$i/d" /home/$varname/Desktop/adminsdel.txt
done

for i in 'less /home/$varname/Desktop/adminsdel.txt'
do
  gpasswd -d $i sudo
  gpasswd -d $i adm
  gpasswd -d $i wheel
done
Block
#
#
#
alias ls='ls -lah --color=auto'
alias nano=micro
PS1='[\u@\h \W]\$ '
EDITOR=/usr/bin/micro
echo -E "PS1='[\u@\h \W]\$ '" >> /home/$varname/.bashrc
echo -E "EDITOR=/usr/bin/micro" >> /home/$varname/.bashrc
echo -E "alias nano=micro" >> /home/$varname/.bashrc
echo -E "alias ls='ls -lah --color=auto'" >> /home/$varname/.bashrc
neofetch
echo "Check the sudoers file using visudo, check the wheel, admin, and sudo groups too. Also check your services."
echo "REMEMBER TO USERDEL -R TO FULLY REMOVE USERS ONCE IT IS CONFIRMED FOR THE FOLLOWING USERS:"
cat /home/$varname/Desktop/usersdel.txt
echo "\nThe following users were removed from an admin account"
cat /home/$varname/Desktop/adminsdel.txt
#Other Notes:
#login.defs
#pam.d/common-password
#find a command to open the editor variable?
#apt-mark showmanual
#/etc/apt/sources.list
#check admin group,remove mail server
