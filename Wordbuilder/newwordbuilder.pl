use DB_File;
tie %CGN,"DB_File","/home/pricie/vincent/Lingware/Data/Lexical/DB/CGN_for_WB.db"; 

$input=$ARGV[0];
chomp($input);
my @input=split(/,/,$input);

