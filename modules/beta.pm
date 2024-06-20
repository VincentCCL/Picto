####### beta.pm ##########

# By Vincent Vandeghinste
# vincent@ccl.kuleuven.be
# Date: 07.10.2013

#---------------------------------------

# This file contains the pictograph set specific info for TextToPicto conversion

#---------------------------------------

$VERSION="1.2.1"; # 29.11.13 Beta pictos have been converted to .png
#$VERSION="1.2"; # 25.11.13 Source language dependent info is put in beta_dutch.pm
#$VERSION="1.1.1"; # GetExtension added
#$VERSION="1.1"; # Better processing of VNW
# Version used in the first release for WAI-NOT

1;

#---------------------------------------
package beta;
#---------------------------------------

@ISA=("picto");

sub getPictoDirs {
    return ("$main::Bin/../beta");
}

sub getURL {
    return "http://text2picto.ccl.kuleuven.be/web/beta/";
}

sub negativePicto {
    return 'geen.png';
}

sub getDictionaryTableName {
    return "beta_dictionary"; 
}

sub getExtension {
    return ".png";
}

