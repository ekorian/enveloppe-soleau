# Git Repository Timestamping with Enveloppe Soleau

The purpose of an enveloppe soleau is to legally assert the state of a document at a specific time.
This script extends that concept to git repositories.

The script encrypts the entire git repository and writes it to a USB key. It also generates a PDF containing hashes, a timestamp, and decryption keys.

The script produces the following:

- An encrypted USB volume containing the git repositories.
- A PDF document that includes the decryption keys, a timestamp, and multiple hashes of the archive containing the git repository. This document can be legally certified to prove that your repository was in a specific state at a given time.


NOTE: I am not a legal advisor, please consult a legal advisor of your jurisdiction.


## How to certify the PDF document ?

### Enveloppe Soleau

[Enveloppe Soleau](https://www.inpi.fr/proteger-vos-creations/lenveloppe-soleau/portail-soleau) is a service provided by the French government. Although this service is used here, ensure it is recognized in your jurisdiction. Similar services exist in other countries.


### Notary

A notary can also certify a document, but this option may be more expensive than using the Enveloppe Soleau service.


## Dependencies

Veracrypt 1.25.9, git, texlive-full


## Hash functions

SHA-1, SHA-256, MD5


## HOW TO ENCRYPT

CAUTION: Ensure that there is no data on the USB key or the data has been
backed up and backup confirmed. The process will wipe the partition clean
and you will loose all data, if any was stored in it.

- Add your ssh key to git
- (facultative) connect to your git VPN
- Add `ssh` URLs of your git repositories to `repositories.txt`. One per line.
- UNMOUNT USB key
- unplug/re-plug USB key
- UNMOUNT AGAIN
- Run generate.sh <path-to-usb-partition> (e.g., /dev/sda1)
  !!! CAUTION !!!: do not confuse USB mount point with your own disks
- You should see "The VeraCrypt volume has been successfully created." in the console logs, if not you messed something up.
- `enveloppe-solo.pdf` is created in the current directory
- Print the PDF
- DELETE the PDF file
- Timestamp/Certify the printed PDF
- Store the USB key in a vault


## HOW TO DECRYPT

- You need both the USB key and the associated PDF
- Write Keyfile to a text file without spaces nor carriage returns/line breaks. 
- Plug USB key
- Open Veracrypt
- Right click on a slot and click "Select Device and Mount ..."
- Select your USB key
- Click on "Keyfiles", then "Add file", and select the keyfile that you created in step 2. Click OK.
- Write the password
- Click OK
- The USB key is now deciphered.


