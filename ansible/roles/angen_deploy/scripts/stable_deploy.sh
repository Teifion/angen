# Setup folders
echo "Starting release"

# Remove previous release
rm -rf /tmp/angen_release
mkdir -p /tmp/angen_release
cd /tmp/angen_release

echo "Decompressing"
tar mxfz /home/deploy/releases/angen_stable.tar.gz

echo "Backup existing"
rm -rf /apps/angen_backup
mv /apps/angen /apps/angen_backup

echo "Stopping service"
/apps/angen_backup/bin/angen stop

echo "Remove existing binary"
sudo rm -rf /apps/angen

echo "Relocate binary"
cp -r /tmp/angen_release/opt/build/_build/prod/rel/angen /apps

echo "Rotate logs"
rm /var/log/angen/error_old.log
rm /var/log/angen/info_old.log

cp /var/log/angen/error.log /var/log/angen/error_old.log
cp /var/log/angen/info.log /var/log/angen/info_old.log

echo "Clear logs"
> /var/log/angen/error.log
> /var/log/angen/info.log

# Settings and vars
sudo chmod o+rw /apps/angen/releases/0.0.1/env.sh
cat /apps/angen.vars >> /apps/angen/releases/0.0.1/env.sh

# Reset permissions
sudo chown -R deploy:deploy /apps/angen
sudo chown -R deploy:deploy /var/log/angen

echo "Starting service"
sudo systemctl restart angen.service
