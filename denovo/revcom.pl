## load libraries
use strict; # help 

## variables
my $fasta = $ARGV[0];
my $outfa = $ARGV[1];


my $header;
my $seq;

open (my $out, '>', $outfa) or die "can't open $outfa $!\n";
open (fas, '<', $fasta) or die "can't open $fasta $!\n";
while (my $line = <fas>) {
    chomp $line;
    # if sequence header
    if ($line =~ /^>/) {
        $header = $line;
    }
    # if sequence
    else {
        my @cols = split("", $line);
        my $AA = () = $line =~ /A/gi;
        my $TT = () = $line =~ /T/gi;
        my $GG = () = $line =~ /G/gi;
        my $CC = () = $line =~ /C/gi;
        my $ln = $AA + $TT + $GG + $CC;
        # my $ln = length($line);
        # exclude if empty
        if ($ln > 0) {
            # needs reverse complement 
            if ($AA > $TT) {
                my $revcomp = reverse $line; 
                $revcomp =~ tr/ATGCatgc/TACGtacg/; 
                $seq = $revcomp;
            } 
            # does NOT need reverse complement 
            else {
                $seq = $line;
            }
            print $out "$header\n$seq\n";
        }
    }
}
close $fasta; 
close $outfa;
