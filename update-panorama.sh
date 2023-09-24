#!/bin/sh

#### !!!!!! Caution !!!!!!  ####
#### No exception handling  ####
#### No commit result check ####
#### No push result check   ####

apikey="please-generate-your-own-api-token-by-user-self"
username="apikey-generated-user"

prikey="/etc/letsencrypt/rsa-live/jal.tw/privkey.pem"
chain="/etc/letsencrypt/rsa-live/jal.tw/fullchain.pem"
path="/etc/letsencrypt/renewal-hooks/post"
full="${path}/jal.tw.full"

panorama="panorama-primary-active.jal.tw"
certname="jal.tw"
tempname="jal.tw.old"

template="PA-VM-100"

# Start combind cert file with key and cert including intermediate certificate
# cat /etc/letsencrypt/live/jal.tw/privkey.pem > jal.tw.full
# cat /etc/letsencrypt/live/jal.tw/fullchain.pem >> jal.tw.full
/bin/cat ${prikey} > ${full}
/bin/cat ${chain} >> ${full}

#### Panorama ####
echo "Panorama - Rename certificate"
curl -k -g "https://${panorama}/api?key=${apikey}&type=config&action=rename&xpath=/config/panorama/certificate/entry[@name='${certname}']&newname=${tempname}"
echo ""

echo "Panorama - Upload certificate to Panorama"
curl -k -F "file=@${full}" "https://${panorama}/api?key=${apikey}&type=import&category=keypair&certificate-name=${certname}&format=pem&passphrase=12345678"
echo ""

echo "Panorama - Change SSL TLS Service Profile"
curl -k -g "https://${panorama}/api?key=${apikey}&type=config&action=edit&xpath=/config/panorama/ssl-tls-service-profile/entry[@name='${certname}-profile']/certificate&element=<certificate>${certname}</certificate>"
echo ""

echo "Panorama - Delete old Certificate"
curl -k -g "https://${panorama}/api?key=${apikey}&type=config&action=delete&xpath=/config/panorama/certificate/entry[@name='${tempname}']"
echo ""
echo ""
echo ""

#### Device Template ####
echo "${template} - Rename certificate"
curl -k -g "https://${panorama}/api?key=${apikey}&type=config&action=rename&xpath=/config/devices/entry[@name='localhost.localdomain']/template/entry[@name='${template}']/config/shared/certificate/entry[@name='${certname}']&newname=${tempname}"
echo ""

echo "${template} - Upload certificate"
curl -k -F "file=@${full}" "https://${panorama}/api?key=${apikey}&type=import&category=keypair&certificate-name=${certname}&format=pem&passphrase=12345678&target-tpl=${template}"
echo ""

echo "${template} - Change SSL TLS Service Profile"
curl -k -g "https://${panorama}/api?key=${apikey}&type=config&action=edit&xpath=/config/devices/entry[@name='localhost.localdomain']/template/entry[@name='${template}']/config/shared/ssl-tls-service-profile/entry[@name='${certname}-profile']/certificate&element=<certificate>${certname}</certificate>"
echo ""

echo "${template} - Delete old Certificate"
curl -k -g "https://${panorama}/api?key=${apikey}&type=config&action=delete&xpath=/config/devices/entry[@name='localhost.localdomain']/template/entry[@name='${template}']/config/shared/certificate/entry[@name='${tempname}']"
echo ""
echo ""
echo ""

#### Commit ####
echo "Finish change - Commit"
echo "Panorama - Commit only change by ${username}"
curl -k -g "https://${panorama}/api?key=${apikey}&type=commit&cmd=<commit><partial><admin><member>${username}</member></admin></partial></commit>"
echo ""
echo ""
echo ""

echo "Sleep for 60 seconds - I'm too lazy to check the result of the commit (aka, you can pull request this part, I'll be very grateful to you)"
sleep 60

#### Push to device from Panorama - commit-all ####
#### Note: Change config in "template", but push "template_stack" in Panorama, also push only change by username. ####
echo "Push - ${template}_stack"
curl -k -g "https://${panorama}/api?key=${apikey}&type=commit&action=all&cmd=<commit-all><template-stack><admin><member>${username}</member></admin><name>${template}_stack</name></template-stack></commit-all>"
echo ""
echo ""
echo ""

