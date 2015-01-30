script_directory=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

sudo apt-get install ruby1.9.1-dev zlib1g-dev -y
sudo gem install sonos

cd $HOME && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -

ifttt_sonos_job="@reboot cd $script_directory ; ruby ifttt_dropbox_sonos.rb >> $script_directory/ifttt.log"
dropboxd_job="@reboot $HOME/.dropbox-dist/dropboxd"
(crontab -l ; echo $ifttt_sonos_job) | sort - | uniq - | crontab -
(crontab -l ; echo $dropboxd_job) | sort - | uniq - | crontab -

echo "Please reboot after linking dropbox account..."
sleep 4

bash $HOME/.dropbox-dist/dropboxd
