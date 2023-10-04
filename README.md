# paloalto-panos-with-curl
This repository will collect all I wrote or tested API call via Panorama, due to Panorama different with PAN-OS

* CURL Version 8.1.1
* PAN-OS Version 11.0.2


   # certificate-renewal-via-panorama.sh
   # Automated Palo Alto PAN-OS Certificate Renewal with CURL

      Rather than manually replacing certificates in PAN-OS I used this playbook to automate the process.
      This is useful when ustilising Let's Encrypt certificates which are only valid for 90 days.
  
   * Before start, please change your own variable in sh file first.
     The playbook performs the following.

     - Prepared certificate file
       The private key and certificate have to be in the same file for this to work

       (you can use 'cat private.pem fullchain.pem > jal.tw.full' to combine the certificate and the key in one file).

         **NOTE**: PanOS requires that you specify a password for the private key, even if the private key is not encrypted with a password.

     - Work on Panorama

       a) Rename current used certificate name

          Due to API can't upload and overwrite the certificate file in one step.

       b) Upload certificate to Panorama

       c) Update SSL TLS Service Profile in Panorama

       d) Delete old certificate in Panorama

     - Work on firewall template

       a) Rename current used certificate name in device template

       b) Upload certificate to device template

       c) Update SSL TLS Service Profile in device template

       d) Delete old certificate in device template

     - Repeat step 3 on different device template
     - Commit only change by username
     - Push to device (device stack)
