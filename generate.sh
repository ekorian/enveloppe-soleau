# 
# Generate Enveloppe Solo
# 
# K.Edeline
#
# 
if [ "$#" -ne 1 ]
then
   echo "Usage ./generate.sh <usb-partition>"
   exit
fi; 

source config.cfg
USB_DISK="$1"
REPOSITORIES_FILE="repositories.txt"
CONTENT_DIR="content/"
README_FILE=$CONTENT_DIR/"README"
KEYFILE_FILE="keyfile"
PW_FILE="pwfile"
MOUNT_PATH="/mnt/usb-solo"
DATA_ARCHIVE="data.tar.gz"
LATEX_DIR="tex/"
LATEX_FILE="enveloppe-solo.tex"
PDF_FILE="enveloppe-solo.pdf"
LATEX_INPUT_FILE1="src/enveloppe-solo1.tex"
LATEX_INPUT_FILE2="src/enveloppe-solo2.tex"
HASH_FILE="hashfile"
COMPANY_NAME_ESCAPED=$(printf '%s\n' "$SOLEAU_COMPANY_NAME" | sed -e 's/[]\/$*.^[]/\\&/g')

echo "Cloning/Pulling Repositories"
rm -rf $CONTENT_DIR
rm -rf $LATEX_DIR
mkdir -p $CONTENT_DIR
mkdir -p $LATEX_DIR
rm -f $DATA_ARCHIVE
sudo mkdir -p $MOUNT_PATH

for repo in $(cat $REPOSITORIES_FILE); do
   git -C $CONTENT_DIR clone $repo ;
done;

echo "" > $README_FILE
echo "This USB contains repositories owned by ${COMPANY_NAME_ESCAPED}" >> $README_FILE
echo -n "ALL content of this device has been generated on " >> $README_FILE
date >> $README_FILE
echo "Content of this device has been encrypted with veracrypt 1.25.9" >> $README_FILE

echo "Generate Archive"
tar zcf $DATA_ARCHIVE $CONTENT_DIR

echo "Creating encrypted volume in "$USB_DISK
PW_STRING=$(openssl rand -base64 32)
echo $PW_STRING > $PW_FILE
KEYFILE_STRING=$(openssl rand -base64 1024 | tr -d '\n')
echo $KEYFILE_STRING > $KEYFILE_FILE
#extra \n for copy paste safety
veracrypt -t -m=nokernelcrypto -c $USB_DISK --volume-type=normal \
--encryption=aes --hash=sha-512 --filesystem=ext4 --quick \
-p $PW_STRING --pim=0 -k $KEYFILE_FILE --random-source=/dev/urandom
veracrypt -t -k $KEYFILE_FILE -p $(cat $PW_FILE) --pim=0 --protect-hidden=no $USB_DISK $MOUNT_PATH

sudo rm -rf $MOUNT_PATH/*

echo "Transfering content"
sudo cp $DATA_ARCHIVE $MOUNT_PATH
# Unmount
veracrypt -d $USB_PATH

echo "Computing Hashes"
echo "SHA-1" > $HASH_FILE
echo "" >> $HASH_FILE
sha1sum $DATA_ARCHIVE >> $HASH_FILE
echo "" >> $HASH_FILE
echo "SHA-256" >> $HASH_FILE
echo "" >> $HASH_FILE
sha256sum $DATA_ARCHIVE >> $HASH_FILE
echo "" >> $HASH_FILE
echo "MD5" >> $HASH_FILE
echo "" >> $HASH_FILE
md5sum $DATA_ARCHIVE >> $HASH_FILE
echo "" >> $HASH_FILE

echo "Generate PDF"
cat $LATEX_INPUT_FILE1 | sed -e "s/SOLEAU-COMPANY-NAME/$COMPANY_NAME_ESCAPED/g" > $LATEX_DIR$LATEX_FILE
echo $KEYFILE_STRING >> $LATEX_DIR$LATEX_FILE
cat $LATEX_INPUT_FILE2 >> $LATEX_DIR$LATEX_FILE
cd $LATEX_DIR
pdflatex $LATEX_FILE
cd ..
cp $LATEX_DIR$PDF_FILE .

# cleanup
rm $KEYFILE_FILE
rm $HASH_FILE
rm $PW_FILE
rm $DATA_ARCHIVE
rm -rf $CONTENT_DIR
rm -rf $LATEX_DIR





