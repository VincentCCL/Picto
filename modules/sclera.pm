####### sclera.pm ##########

# By Vincent Vandeghinste
# vincent@ccl.kuleuven.be
# Date: 07.10.2013

#---------------------------------------

# This file contains the pictograph set specific info for TextToPicto conversion

#---------------------------------------

#$VERSION="1.2";  # 25.11.13 Source language dependent info is put in sclera_dutch.pm
#$VERSION="1.1.1"; # GetExtension added
#$VERSION="1.1"; # Better processing of VNW
# Version used in the first release for WAI-NOT

1;

#---------------------------------------
package sclera;
#---------------------------------------

@ISA=("picto");

sub getPictoDirs {
  return undef;
}

sub getURL {
    return "http://text2picto.ccl.kuleuven.be/web/sclera/";
}

sub negativePicto {
    return 'kruis-rood.png';
}

sub getDictionaryTableName {
    return "sclera_dictionary"; 
}

sub getExtension {
    return ".png";
}
