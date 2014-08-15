#!/bin/bash

# Create a temporary directory where we can do what we please
tmp_dir=$(mktemp -d)
cd $tmp_dir


# Install the tahoma font
mkdir tahoma
cd tahoma
wget http://download.microsoft.com/download/ie6sp1/finrel/6_sp1/W98NT42KMeXP/EN-US/IELPKTH.CAB
if [ "$?" -eq "0" ] ; then
    # Extract the entire cab file
    cabextract IELPKTH.CAB

    # Copy all the extracted fonts in the msttcorefonts fonts folder
    cp *.ttf /usr/share/fonts/truetype/msttcorefonts/
fi
cd ..

# Install Calibri, Cambria, ..
mkdir pptfonts
cd pptfonts
wget http://download.microsoft.com/download/f/5/a/f5a3df76-d856-4a61-a6bd-722f52a5be26/PowerPointViewer.exe
if [ "$?" -eq "0" ] ; then
    # Extract the ppviewer.cab file from the exe
    cabextract -L -F ppviewer.cab -d . PowerPointViewer.exe

    # Extract the ttf files from the cab file
    cabextract -L -F '*.TT[FC]' -d . ppviewer.cab

    mv cambria.ttc cambria.ttf
    chmod 600 calibri{,b,i,z}.ttf cambria{,b,i,z}.ttf candara{,b,i,z}.ttf consola{,b,i,z}.ttf constan{,b,i,z}.ttf corbel{,b,i,z}.ttf

    # Copy all the extracted fonts in the msttcorefonts fonts folder
    cp *.ttf /usr/share/fonts/truetype/msttcorefonts
fi
cd ..

# Install any custom fonts that we can't get from anywhere else
mkdir oae
cd oae
mkdir fonts
wget https://s3-eu-west-1.amazonaws.com/oae-files/fonts.tar.gz
tar -xzvf fonts.tar.gz -C fonts
cp fonts/* /usr/share/fonts/truetype/msttcorefonts

# Rebuild the font-cache
fc-cache -fv

# Clean it all up
cd ~
rm -rf $tmp_dir
