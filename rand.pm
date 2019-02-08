####### rand.pm ##########

# By Vincent Vandeghinste
# vincent@ccl.kuleuven.be
# Date: 07.10.2013
# sclera.pm converted into rand.pm, replacing sclera by rand

#---------------------------------------
# This file contains the pictogram set specific info for 
# TextToPicto conversion
#---------------------------------------

$VERSION="1.2";  # 25.11.13 Source language dependent info is put in rand_dutch.pm
#$VERSION="1.1.1"; # GetExtension added
#$VERSION="1.1"; # Better processing of VNW
# Version used in the first release for WAI-NOT

1;
#---------------------------------------
package rand;
#---------------------------------------

@ISA=("picto");

sub getPictoDirs {
    # $main::Bin is the path from where TextToPicto is called
    # Set the path to the directory containing the Rand pictographs
    return ("/home/obelix/rand");
}

sub getURL {
    # Set the return element to the url of the pictographs
    # (Only used in html output mode)
    return "http://www.pictogrammendatabank.be/wp-content/uploads/2015/11/";
}

sub negativePicto {
    # Contains the pictogram for negation
    return 'kruis-rood.png';
}

sub getDictionaryTableName {
    # Set to the table in the database which contains dictionary information for Rand
    return "rand_dictionary"; 
}

sub getExtension {
    return ".png";
}
